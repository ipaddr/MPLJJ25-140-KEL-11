import 'package:flutter/material.dart';

class PesanScreen extends StatelessWidget {
  const PesanScreen({super.key});

  Widget buildMenuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF7C5E1E)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Color(0xFFC7D9C7),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Panen',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: 'Plus',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          buildMenuItem(
            Icons.chat_bubble_outline,
            'Chat',
            'Percakapan pribadi saya',
          ),
          buildMenuItem(
            Icons.group_outlined,
            'Grup chat',
            'Percakapan grup saya',
          ),
          buildMenuItem(
            Icons.handshake_outlined,
            'Negosiasi',
            'Percakapan untuk transaksi',
          ),
          buildMenuItem(
            Icons.local_shipping_outlined,
            'Jasa Pengiriman',
            'Percakapan untuk jasa pengiriman',
          ),
          buildMenuItem(
            Icons.star_outline,
            'Ulasan',
            'Berikan penilaian dan ulasan',
          ),
          buildMenuItem(
            Icons.help_outline,
            'Pusat Bantuan',
            'Pantau status bantuan dan pengaduan',
          ),
        ],
      ),
    );
  }
}
