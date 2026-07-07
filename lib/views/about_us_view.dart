import 'package:flutter/material.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About us',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            // Zonex Logo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix([
                  0.9, 0, 0, 0, 0,
                  0, 0.2, 0, 0, 0,
                  0, 0, 0.2, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Image.asset(
                  'assets/images/logo/Zonex.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.sports_esports, size: 80, color: Color(0xFFF34C43)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Zonex Games',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0 (Premium Edition)',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 32),
            // Information Card 1: Platform Overview
            _buildAboutCard(
              title: 'Welcome to Zonex',
              subtitle: 'The ultimate next-generation gaming hub designed to offer you the most thrilling, fair, and secure entertainment experience. Zonex brings together your favorite games like Wingo Lottery, K3, 5D, and high-flying Aviator under a single unified dashboard.',
              icon: Icons.stars,
            ),
            const SizedBox(height: 16),
            // Information Card 2: Features
            _buildAboutCard(
              title: 'Key Advantages',
              subtitle: '• Provably Fair Game Algorithms & Real-Time Period Draws\n• Secure Transaction Logs with Local PostgreSQL Database\n• 24/7 Dedicated Support desk & Smooth Fluid UI Animations\n• High Security Encryption for User Wallets & Logs',
              icon: Icons.shield,
            ),
            const SizedBox(height: 16),
            // Information Card 3: Our Mission
            _buildAboutCard(
              title: 'Our Vision',
              subtitle: 'At Zonex, we strive to build a community where entertainment meets trust. We implement state-of-the-art encryption protocols and strict security measures to ensure every single bet, deposit, and withdrawal is processed with complete integrity.',
              icon: Icons.lightbulb,
            ),
            const SizedBox(height: 40),
            Text(
              '© 2026 Zonex Games. All rights reserved.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFF34C43), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
