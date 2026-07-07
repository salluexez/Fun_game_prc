import 'package:flutter/material.dart';

class AnnouncementView extends StatelessWidget {
  const AnnouncementView({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = [
      {
        'title': 'ANNOUNCEMENT ! ! !',
        'content': 'The website upgrade is complete. Before logging in, clear the browser cache. Add member betting rewards and VIP level rewards',
        'date': '2023-08-08 22:19:25',
      },
      {
        'title': '⭐Official Website⭐',
        'content': 'To visit our official website, be sure to use the link below: https://www.zonexgames.com/ Please remember! Make sure to not provide personal data and personal transactions in any form and for any reason to other parties on behalf of Zonex. Our side does not make private chats or calls to all members. Please inform all Referrals/other Members about this to avoid fraud. Thank you for your attention and cooperation.',
        'date': '2023-01-27 13:33:00',
      },
      {
        'title': 'Safe Recharge Tips',
        'content': 'All Recharge payment methods on the Zonex site are only available in the Recharge menu on the official website. Make sure to make a Recharge only through our official website and don\'t trust any party on behalf of Zonex. If you find any discrepancies or suspicious behavior, please contact our customer service immediately for confirmation. We urge all members not to believe or be tempted by other promotions outside our site, Thank You',
        'date': '2022-05-28 12:49:52',
      },
      {
        'title': 'Authorized Customer Service',
        'content': 'Attention ! Attention ! To all Zonex members, you can only contact Zonex Customer Service directly from the Account Tab on the App, select 24/7 Customer Service and select the option base on your concern. Do not entertain Private messages claiming to be from Zonex, NEVER provide personal data and transactions outside the application or website for deposits, withdrawals and Bank information. Please be careful with those acting on behalf of Zonex.',
        'date': '2024-04-14 00:44:02',
      },
      {
        'title': 'Protect your accounts from hacking',
        'content': 'Here are the TIPS on how to prevent your account from being hacked:\n1. Secure your password: it should be difficult to guess but easy for you to remember, and do not share your password with anyone.\n2. Make sure you\'re logging in on the correct website address. If you\'re using a web browser to access your Zonex account, make sure the address bar says zonexgames.in. Be vigilant against phishing attempts.',
        'date': '2024-05-10 11:24:15',
      },
    ];

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
          'Announcement',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final ann = announcements[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.campaign,
                      color: Color(0xFFF34C43),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ann['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ann['content']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  ann['date']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
