-- PostgreSQL Database Schema Initialization

-- Enable UUID extension for secure primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended'))
);

-- 2. WALLETS TABLE
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(15, 2) NOT NULL DEFAULT 2.03 CHECK (balance >= 0.00),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. TRANSACTIONS TABLE (Deposits & Withdrawals)
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

-- 4. GAME PERIODS TABLE
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

-- 5. BETS TABLE
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

-- 6. SYSTEM SETTINGS TABLE
CREATE TABLE IF NOT EXISTS system_settings (
    key VARCHAR(50) PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert Default Config settings if not exists
INSERT INTO system_settings (key, value)
VALUES ('offline_deposit_qr_url', 'https://images.unsplash.com/photo-1595079676339-1534801ad6cf?w=500&q=80')
ON CONFLICT (key) DO NOTHING;
