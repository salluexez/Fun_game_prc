import 'package:flutter/material.dart';

class LanguageView extends StatefulWidget {
  const LanguageView({super.key});

  @override
  State<LanguageView> createState() => _LanguageViewState();
}

class _LanguageViewState extends State<LanguageView> {
  String _selectedLangCode = 'en'; // default 'en' for English

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
          'Language',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. English
            _buildLanguageCard(
              title: 'English',
              langCode: 'en',
              flagUrl: 'https://flagcdn.com/w80/us.png',
            ),
            const SizedBox(height: 12),
            // 2. Hindi
            _buildLanguageCard(
              title: 'हिंदी',
              langCode: 'hi',
              flagUrl: 'https://flagcdn.com/w80/in.png',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required String title,
    required String langCode,
    required String flagUrl,
  }) {
    final bool isSelected = _selectedLangCode == langCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLangCode = langCode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Flag
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  flagUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Language Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Checkbox indicator
            isSelected
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF34C43),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
