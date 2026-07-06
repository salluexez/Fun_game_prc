const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const http = require('http');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Serving the admin static dashboard from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Configure PostgreSQL connection pool.
// Fallback to local defaults (adjust as needed for pgAdmin 4 connection)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgresql://mohdsalauddin@localhost:5432/postgres'
});

// Test connection and auto-initialize tables if schema.sql was not run
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Error connecting to PostgreSQL database:', err.message);
    console.log('Please ensure PostgreSQL is running and connection string is correct.');
  } else {
    console.log('Connected to PostgreSQL database at:', res.rows[0].now);
    initializeDatabase();
  }
});

async function initializeDatabase() {
  try {
    // Basic verification check of users table to see if initialization is needed
    const checkTable = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_name = 'users'
      );
    `);
    
    if (!checkTable.rows[0].exists) {
      console.log('Initializing database tables...');
      const schema = `
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

        CREATE TABLE IF NOT EXISTS users (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            phone_number VARCHAR(15) UNIQUE NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended'))
        );

        CREATE TABLE IF NOT EXISTS wallets (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            balance DECIMAL(15, 2) NOT NULL DEFAULT 2.03 CHECK (balance >= 0.00),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS transactions (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0.00),
            type VARCHAR(20) NOT NULL CHECK (type IN ('deposit', 'withdrawal')),
            status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
            receipt_image_url VARCHAR(512),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            resolved_at TIMESTAMP WITH TIME ZONE
        );

        CREATE TABLE IF NOT EXISTS game_periods (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            period_id VARCHAR(32) NOT NULL,
            game_type VARCHAR(20) NOT NULL CHECK (game_type IN ('wingo', 'k3', '5d', 'trx_wingo')),
            duration_minutes INT NOT NULL,
            result_value VARCHAR(64),
            hash_value VARCHAR(64),
            block_height INT,
            is_manual BOOLEAN DEFAULT FALSE,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            ended_at TIMESTAMP WITH TIME ZONE,
            CONSTRAINT unique_period_per_game UNIQUE (period_id, game_type)
        );

        CREATE TABLE IF NOT EXISTS bets (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            game_period_id UUID NOT NULL REFERENCES game_periods(id) ON DELETE CASCADE,
            choice VARCHAR(50) NOT NULL,
            bet_amount DECIMAL(15, 2) NOT NULL CHECK (bet_amount > 0.00),
            service_fee DECIMAL(15, 2) NOT NULL,
            contract_amount DECIMAL(15, 2) NOT NULL,
            status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'won', 'lost')),
            payout DECIMAL(15, 2) DEFAULT 0.00,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );

        CREATE TABLE IF NOT EXISTS system_settings (
            key VARCHAR(50) PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );

        INSERT INTO system_settings (key, value)
        VALUES ('offline_deposit_qr_url', 'https://images.unsplash.com/photo-1595079676339-1534801ad6cf?w=500&q=80')
        ON CONFLICT (key) DO NOTHING;
      `;
      await pool.query(schema);
      console.log('Database tables successfully initialized!');
    }
    
    // Ensure UPI columns are present in the users table for existing databases
    await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS upi_address VARCHAR(100);');
    await pool.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS upi_name VARCHAR(100);');
  } catch (error) {
    console.error('Failed to initialize database tables:', error.message);
  }
}

// -------------------------------------------------------------
// REST API ROUTES
// -------------------------------------------------------------

// 1. Authentication
app.post('/api/auth/register', async (req, res) => {
  const { phoneNumber, password } = req.body;
  if (!phoneNumber || !password) {
    return res.status(400).json({ error: 'Phone number and password required' });
  }

  try {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      
      const insertUser = await client.query(
        'INSERT INTO users (phone_number, password_hash) VALUES ($1, $2) RETURNING id, phone_number, status',
        [phoneNumber, password]
      );
      
      const userId = insertUser.rows[0].id;
      
      await client.query(
        'INSERT INTO wallets (user_id, balance) VALUES ($1, 2.03)',
        [userId]
      );

      await client.query('COMMIT');
      res.json(insertUser.rows[0]);
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error(err);
    if (err.message.includes('unique constraint')) {
      res.status(400).json({ error: 'Phone number already registered' });
    } else {
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { phoneNumber, password } = req.body;
  if (!phoneNumber || !password) {
    return res.status(400).json({ error: 'Phone number and password required' });
  }

  try {
    const query = await pool.query(
      'SELECT id, phone_number, password_hash, status FROM users WHERE phone_number = $1',
      [phoneNumber]
    );

    if (query.rows.length === 0) {
      return res.status(400).json({ error: 'User not found' });
    }

    const user = query.rows[0];
    if (user.password_hash !== password) {
      return res.status(400).json({ error: 'Incorrect password' });
    }

    if (user.status === 'suspended') {
      return res.status(403).json({ error: 'Your account has been suspended by Admin' });
    }

    res.json({ id: user.id, phoneNumber: user.phone_number, status: user.status });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/api/user/profile', async (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const query = await pool.query(
      'SELECT id, phone_number, upi_address, upi_name, status FROM users WHERE id = $1',
      [userId]
    );

    if (query.rows.length === 0) {
      return res.status(400).json({ error: 'User not found' });
    }

    const user = query.rows[0];
    res.json({
      id: user.id,
      phoneNumber: user.phone_number,
      upiAddress: user.upi_address || '',
      upiName: user.upi_name || '',
      status: user.status
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/user/upi', async (req, res) => {
  const { userId, upiAddress, upiName } = req.body;
  if (!userId || !upiAddress || !upiName) {
    return res.status(400).json({ error: 'userId, upiAddress and upiName required' });
  }

  try {
    await pool.query(
      'UPDATE users SET upi_address = $1, upi_name = $2 WHERE id = $3',
      [upiAddress, upiName, userId]
    );
    res.json({ success: true, message: 'UPI details updated successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 2. Wallet APIs
app.get('/api/wallet/balance', async (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const query = await pool.query('SELECT balance FROM wallets WHERE user_id = $1', [userId]);
    if (query.rows.length === 0) return res.status(404).json({ error: 'Wallet not found' });
    res.json({ balance: parseFloat(query.rows[0].balance) });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/wallet/deposit', async (req, res) => {
  const { userId, amount, receiptImageUrl } = req.body;
  if (!userId || !amount) return res.status(400).json({ error: 'userId and amount required' });

  try {
    const tx = await pool.query(
      'INSERT INTO transactions (user_id, amount, type, status, receipt_image_url) VALUES ($1, $2, \'deposit\', \'pending\', $3) RETURNING *',
      [userId, amount, receiptImageUrl || '']
    );
    res.json(tx.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/wallet/withdraw', async (req, res) => {
  const { userId, amount } = req.body;
  if (!userId || !amount) return res.status(400).json({ error: 'userId and amount required' });

  try {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      
      const wQuery = await client.query('SELECT balance FROM wallets WHERE user_id = $1 FOR UPDATE', [userId]);
      if (wQuery.rows.length === 0) {
        throw new Error('Wallet not found');
      }
      
      const balance = parseFloat(wQuery.rows[0].balance);
      if (balance < amount) {
        return res.status(400).json({ error: 'Insufficient balance' });
      }

      // Deduct immediately on request
      await client.query('UPDATE wallets SET balance = balance - $1 WHERE user_id = $2', [amount, userId]);
      
      const tx = await client.query(
        'INSERT INTO transactions (user_id, amount, type, status) VALUES ($1, $2, \'withdrawal\', \'pending\') RETURNING *',
        [userId, amount]
      );

      await client.query('COMMIT');
      res.json(tx.rows[0]);
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
});

app.get('/api/wallet/transactions', async (req, res) => {
  const { userId } = req.query;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const query = await pool.query(
      'SELECT id, amount, type, status, created_at, receipt_image_url FROM transactions WHERE user_id = $1 ORDER BY created_at DESC',
      [userId]
    );
    res.json(query.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 3. System Config
app.get('/api/settings/qr', async (req, res) => {
  try {
    const query = await pool.query('SELECT value FROM system_settings WHERE key = \'offline_deposit_qr_url\'');
    res.json({ qrUrl: query.rows.length > 0 ? query.rows[0].value : '' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 4. Game Period Info
app.get('/api/games/active-period', async (req, res) => {
  const { gameType } = req.query;
  if (!gameType) return res.status(400).json({ error: 'gameType is required' });

  try {
    const query = await pool.query(
      'SELECT id, period_id, game_type, duration_minutes, block_height, hash_value FROM game_periods WHERE game_type = $1 AND result_value IS NULL ORDER BY created_at DESC LIMIT 1',
      [gameType]
    );
    if (query.rows.length === 0) return res.status(404).json({ error: 'No active period found' });
    
    // Calculate remaining seconds
    const active = query.rows[0];
    res.json(active);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/api/games/history', async (req, res) => {
  const { gameType } = req.query;
  if (!gameType) return res.status(400).json({ error: 'gameType required' });

  try {
    const query = await pool.query(
      'SELECT period_id as "periodId", block_height as "blockHeight", result_value as "resultValue", hash_value as "hashValue" FROM game_periods WHERE game_type = $1 AND result_value IS NOT NULL ORDER BY created_at DESC LIMIT 100',
      [gameType]
    );
    res.json(query.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 5. Betting APIs
app.post('/api/bets/place', async (req, res) => {
  const { userId, gamePeriodId, choice, betAmount } = req.body;
  if (!userId || !gamePeriodId || !choice || !betAmount) {
    return res.status(400).json({ error: 'userId, gamePeriodId, choice, and betAmount required' });
  }

  const fee = betAmount * 0.02;
  const contractAmt = betAmount * 0.98;

  try {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Check balance and lock wallet row
      const wQuery = await client.query('SELECT balance FROM wallets WHERE user_id = $1 FOR UPDATE', [userId]);
      if (wQuery.rows.length === 0) throw new Error('Wallet not found');

      const balance = parseFloat(wQuery.rows[0].balance);
      if (balance < betAmount) {
        return res.status(400).json({ error: 'Insufficient balance' });
      }

      // Deduct balance
      await client.query('UPDATE wallets SET balance = balance - $1 WHERE user_id = $2', [betAmount, userId]);

      // Write bet
      const insertBet = await client.query(
        'INSERT INTO bets (user_id, game_period_id, choice, bet_amount, service_fee, contract_amount) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
        [userId, gamePeriodId, choice, betAmount, fee, contractAmt]
      );

      await client.query('COMMIT');
      res.json(insertBet.rows[0]);
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
});

app.get('/api/bets/my-history', async (req, res) => {
  const { userId, gameType } = req.query;
  if (!userId || !gameType) return res.status(400).json({ error: 'userId and gameType required' });

  try {
    const query = await pool.query(
      `SELECT b.choice, b.bet_amount as "amount", b.status, b.payout, b.created_at as "timestamp", gp.period_id as "periodId"
       FROM bets b
       JOIN game_periods gp ON b.game_period_id = gp.id
       WHERE b.user_id = $1 AND gp.game_type = $2
       ORDER BY b.created_at DESC LIMIT 100`,
      [userId, gameType]
    );
    res.json(query.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// -------------------------------------------------------------
// ADMIN APIs (Option B Dashboard targets)
// -------------------------------------------------------------
app.get('/api/admin/users', async (req, res) => {
  try {
    const query = await pool.query(
      `SELECT u.id, u.phone_number as "phoneNumber", u.status, w.balance 
       FROM users u 
       JOIN wallets w ON u.id = w.user_id 
       ORDER BY u.created_at DESC`
    );
    res.json(query.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/admin/users/balance', async (req, res) => {
  const { userId, amount } = req.body;
  if (!userId || amount === undefined) return res.status(400).json({ error: 'userId and amount required' });

  try {
    await pool.query('UPDATE wallets SET balance = $1 WHERE user_id = $2', [amount, userId]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/admin/users/status', async (req, res) => {
  const { userId, status } = req.body;
  if (!userId || !status) return res.status(400).json({ error: 'userId and status required' });

  try {
    await pool.query('UPDATE users SET status = $1 WHERE id = $2', [status, userId]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/api/admin/transactions', async (req, res) => {
  try {
    const query = await pool.query(
      `SELECT t.id, t.amount, t.type, t.status, t.receipt_image_url as "receiptImageUrl", t.created_at as "createdAt", u.phone_number as "phoneNumber"
       FROM transactions t
       JOIN users u ON t.user_id = u.id
       ORDER BY t.created_at DESC`
    );
    res.json(query.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/admin/transactions/resolve', async (req, res) => {
  const { transactionId, status } = req.body;
  if (!transactionId || !status) return res.status(400).json({ error: 'transactionId and status required' });

  try {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      const txQuery = await client.query('SELECT * FROM transactions WHERE id = $1 FOR UPDATE', [transactionId]);
      if (txQuery.rows.length === 0) throw new Error('Transaction not found');
      
      const tx = txQuery.rows[0];
      if (tx.status !== 'pending') return res.status(400).json({ error: 'Transaction already resolved' });

      await client.query(
        'UPDATE transactions SET status = $1, resolved_at = NOW() WHERE id = $2',
        [status, transactionId]
      );

      if (tx.type === 'deposit' && status === 'approved') {
        // Increment wallet balance
        await client.query('UPDATE wallets SET balance = balance + $1 WHERE user_id = $2', [tx.amount, tx.user_id]);
      } else if (tx.type === 'withdrawal' && status === 'rejected') {
        // Return money back to wallet balance
        await client.query('UPDATE wallets SET balance = balance + $1 WHERE user_id = $2', [tx.amount, tx.user_id]);
      }

      await client.query('COMMIT');
      res.json({ success: true });
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || 'Internal server error' });
  }
});

app.post('/api/admin/settings/qr', async (req, res) => {
  const { qrUrl } = req.body;
  if (!qrUrl) return res.status(400).json({ error: 'qrUrl required' });

  try {
    await pool.query('UPDATE system_settings SET value = $1 WHERE key = \'offline_deposit_qr_url\'', [qrUrl]);
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/admin/override-result', async (req, res) => {
  const { gamePeriodId, resultValue } = req.body;
  if (!gamePeriodId || resultValue === undefined) {
    return res.status(400).json({ error: 'gamePeriodId and resultValue required' });
  }

  try {
    await pool.query(
      'UPDATE game_periods SET result_value = $1, is_manual = TRUE WHERE id = $2',
      [resultValue, gamePeriodId]
    );
    res.json({ success: true });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// -------------------------------------------------------------
// BACKGROUND GAME TIMERS & RESOLUTION ENGINE
// -------------------------------------------------------------
const gameTypes = ['wingo', 'k3', '5d', 'trx_wingo'];
const activePeriods = {};
let trxBlockIndex = 84144500;

function startDaemon() {
  setInterval(tickGameEngine, 1000);
}

async function tickGameEngine() {
  const now = new Date();
  
  for (const game of gameTypes) {
    const isTrx = game === 'trx_wingo';
    const durationSec = isTrx ? 60 : 60; // We keep game rounds synchronized to 60 seconds (1 Min modes)
    const timeSec = now.getSeconds();
    const remaining = durationSec - timeSec;

    // Check if period needs initialization
    if (!activePeriods[game]) {
      await initializeNewPeriod(game, now);
    }

    // At 0 (boundary), resolve previous round and spawn next!
    if (remaining === durationSec) {
      const resolving = activePeriods[game];
      if (resolving) {
        resolvePeriodBets(resolving);
      }
      await initializeNewPeriod(game, now);
    }
  }
}

async function initializeNewPeriod(game, dt) {
  const yyyyMMdd = `${dt.getFullYear()}${(dt.getMonth() + 1).toString().padLeft(2, '0')}${dt.getDate().toString().padLeft(2, '0')}`;
  const totalSeconds = dt.getHours() * 3600 + dt.getMinutes() * 60 + dt.getSeconds();
  const periodIndex = Math.floor(totalSeconds / 60) + 1;
  const gameCode = game === 'trx_wingo' ? '01' : game === '5d' ? '5d' : game === 'k3' ? 'k3' : 'wi';
  const periodId = `${yyyyMMdd}${gameCode}${periodIndex.toString().padLeft(4, '0')}`;

  try {
    let blockHeight = null;
    let hashValue = null;

    if (game === 'trx_wingo') {
      trxBlockIndex++;
      blockHeight = trxBlockIndex;
      hashValue = generateSimulatedHash();
    }

    const check = await pool.query(
      'SELECT id FROM game_periods WHERE period_id = $1 AND game_type = $2',
      [periodId, game]
    );

    if (check.rows.length === 0) {
      const insert = await pool.query(
        'INSERT INTO game_periods (period_id, game_type, duration_minutes, block_height, hash_value) VALUES ($1, $2, 1, $3, $4) RETURNING *',
        [periodId, game, blockHeight, hashValue]
      );
      activePeriods[game] = insert.rows[0];
    } else {
      activePeriods[game] = check.rows[0];
    }
  } catch (err) {
    console.error(`Failed to initialize new period for ${game}:`, err.message);
  }
}

async function resolvePeriodBets(period) {
  try {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Fetch row again to see if admin manually selected result
      const fetchPeriod = await client.query('SELECT * FROM game_periods WHERE id = $1 FOR UPDATE', [period.id]);
      const current = fetchPeriod.rows[0];
      
      let finalResult = current.result_value;
      let finalHash = current.hash_value;
      let blockHt = current.block_height;

      // If not overridden, generate result dynamically
      if (!finalResult) {
        if (current.game_type === 'trx_wingo') {
          if (!finalHash) {
            finalHash = generateSimulatedHash();
          }
          const numericDigit = parseLastNumericDigit(finalHash);
          finalResult = numericDigit.toString();
        } else if (current.game_type === 'wingo') {
          finalResult = Math.floor(Math.random() * 10).toString();
        } else if (current.game_type === '5d') {
          // 5 digits
          const d1 = Math.floor(Math.random() * 10);
          const d2 = Math.floor(Math.random() * 10);
          const d3 = Math.floor(Math.random() * 10);
          const d4 = Math.floor(Math.random() * 10);
          const d5 = Math.floor(Math.random() * 10);
          finalResult = `${d1},${d2},${d3},${d4},${d5}`;
        } else if (current.game_type === 'k3') {
          // 3 dice
          const di1 = Math.floor(Math.random() * 6) + 1;
          const di2 = Math.floor(Math.random() * 6) + 1;
          const di3 = Math.floor(Math.random() * 6) + 1;
          finalResult = `${di1},${di2},${di3}`;
        }
        
        await client.query(
          'UPDATE game_periods SET result_value = $1, hash_value = $2, ended_at = NOW() WHERE id = $3',
          [finalResult, finalHash, current.id]
        );
      } else {
        await client.query(
          'UPDATE game_periods SET ended_at = NOW() WHERE id = $3',
          [current.id]
        );
      }

      // Fetch bets placed on this round
      const betsQuery = await client.query('SELECT * FROM bets WHERE game_period_id = $1 FOR UPDATE', [current.id]);
      
      for (const bet of betsQuery.rows) {
        const isWon = checkBetWin(current.game_type, bet.choice, finalResult);
        const status = isWon ? 'won' : 'lost';
        const payout = isWon ? calculatePayoutAmount(current.game_type, bet.choice, parseFloat(bet.bet_amount), finalResult) : 0.00;

        await client.query(
          'UPDATE bets SET status = $1, payout = $2 WHERE id = $3',
          [status, payout, bet.id]
        );

        if (isWon && payout > 0) {
          await client.query(
            'UPDATE wallets SET balance = balance + $1 WHERE user_id = $2',
            [payout, bet.user_id]
          );
        }
      }

      await client.query('COMMIT');
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
  } catch (err) {
    console.error(`Failed to resolve bets for period ${period.id}:`, err.message);
  }
}

// Helper evaluations
function generateSimulatedHash() {
  const chars = '0123456789abcdef';
  let hash = '';
  for (let i = 0; i < 64; i++) {
    hash += chars[Math.floor(Math.random() * 16)];
  }
  return hash;
}

function parseLastNumericDigit(hash) {
  for (let i = hash.length - 1; i >= 0; i--) {
    const code = hash.charCodeAt(i);
    if (code >= 48 && code <= 57) {
      return code - 48;
    }
  }
  return 0;
}

function checkBetWin(game, choice, result) {
  if (game === 'wingo' || game === 'trx_wingo') {
    const num = parseInt(result);
    if (choice === 'Green') return [1, 3, 5, 7, 9].includes(num);
    if (choice === 'Red') return [0, 2, 4, 6, 8].includes(num);
    if (choice === 'Violet') return [0, 5].includes(num);
    if (choice === 'Big') return num >= 5;
    if (choice === 'Small') return num < 5;
    return choice === result;
  }
  if (game === '5d') {
    const digits = result.split(',').map(Number);
    const parts = choice.split('_'); // Format: "A_Big", "SUM_Small", "B_5"
    if (parts.length < 2) return false;
    const target = parts[0];
    const option = parts[1];

    if (target === 'SUM') {
      const sum = digits.reduce((a, b) => a + b, 0);
      if (option === 'Big') return sum >= 23;
      if (option === 'Small') return sum < 23;
      if (option === 'Odd') return sum % 2 !== 0;
      if (option === 'Even') return sum % 2 === 0;
      return false;
    }
    
    const posIdx = ['A', 'B', 'C', 'D', 'E'].indexOf(target);
    if (posIdx === -1) return false;
    const digit = digits[posIdx];

    if (option === 'Big') return digit >= 5;
    if (option === 'Small') return digit < 5;
    if (option === 'Odd') return digit % 2 !== 0;
    if (option === 'Even') return digit % 2 === 0;
    return option === digit.toString();
  }
  if (game === 'k3') {
    const dice = result.split(',').map(Number);
    const sum = dice.reduce((a, b) => a + b, 0);
    
    if (choice === 'Big') return sum >= 11;
    if (choice === 'Small') return sum < 11;
    if (choice === 'Odd') return sum % 2 !== 0;
    if (choice === 'Even') return sum % 2 === 0;
    
    // Triple choice e.g. "Triple_3"
    if (choice.startsWith('Triple_')) {
      const val = parseInt(choice.split('_')[1]);
      return dice.every(d => d === val);
    }
    if (choice === 'AnyTriple') {
      return dice[0] === dice[1] && dice[1] === dice[2];
    }
    // Specific sum bet e.g. "Sum_12"
    if (choice.startsWith('Sum_')) {
      const val = parseInt(choice.split('_')[1]);
      return sum === val;
    }
    return false;
  }
  return false;
}

function calculatePayoutAmount(game, choice, betAmt, result) {
  const contractAmt = betAmt * 0.98;
  if (game === 'wingo' || game === 'trx_wingo') {
    const num = parseInt(result);
    if (choice === 'Green') return num === 5 ? contractAmt * 1.5 : contractAmt * 2.0;
    if (choice === 'Red') return num === 0 ? contractAmt * 1.5 : contractAmt * 2.0;
    if (choice === 'Violet') return contractAmt * 4.5;
    if (choice === 'Big' || choice === 'Small') return contractAmt * 2.0;
    return contractAmt * 9.0;
  }
  if (game === '5d') {
    const parts = choice.split('_');
    const option = parts[1];
    if (['Big', 'Small', 'Odd', 'Even'].includes(option)) return contractAmt * 2.0;
    return contractAmt * 9.0;
  }
  if (game === 'k3') {
    if (['Big', 'Small', 'Odd', 'Even'].includes(choice)) return contractAmt * 2.0;
    if (choice === 'AnyTriple') return contractAmt * 30.0;
    if (choice.startsWith('Triple_')) return contractAmt * 180.0;
    if (choice.startsWith('Sum_')) {
      const sum = diceSum(result);
      // Payout multiplier shifts based on sum probability
      if (sum === 4 || sum === 17) return contractAmt * 50.0;
      if (sum === 5 || sum === 16) return contractAmt * 30.0;
      if (sum === 6 || sum === 15) return contractAmt * 18.0;
      if (sum === 7 || sum === 14) return contractAmt * 12.0;
      if (sum === 8 || sum === 13) return contractAmt * 8.0;
      if (sum === 9 || sum === 12) return contractAmt * 6.0;
      return contractAmt * 5.0;
    }
  }
  return 0.00;
}

function diceSum(res) {
  return res.split(',').map(Number).reduce((a, b) => a + b, 0);
}

// String padding helper
String.prototype.padLeft = function(length, character) {
  return this.length >= length ? this : (new Array(length - this.length + 1).join(character || ' ') + this);
};

// Start the core services
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend server successfully listening on port ${PORT}`);
  startDaemon();
});
