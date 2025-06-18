import 'package:flutter/material.dart';

// Model: Item dalam daftar pesan
class PesanItem {
  final IconData icon;
  final String title;
  final String subtitle;

  PesanItem(this.icon, this.title, this.subtitle);
}

// Widget: Tampilan satu tile pesan
class PesanTile extends StatelessWidget {
  final PesanItem item;
  final VoidCallback onTap;

  const PesanTile({required this.item, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: Colors.brown[700]),
      title: Text(item.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(item.subtitle),
      onTap: onTap,
    );
  }
}

// Halaman Pesan
class PesanPage extends StatelessWidget {
  final List<PesanItem> items = [
    PesanItem(Icons.chat_bubble_outline, 'Chat', 'Percakapan pribadi saya'),
    PesanItem(Icons.groups_outlined, 'Grup chat', 'Percakapan grup saya'),
    PesanItem(
      Icons.handshake_outlined,
      'Negosiasi',
      'Percakapan untuk transaksi',
    ),
    PesanItem(
      Icons.local_shipping_outlined,
      'Jasa Pengiriman',
      'Percakapan untuk jasa pengiriman',
    ),
    PesanItem(Icons.reviews_outlined, 'Ulasan', 'Berikan penilaian dan ulasan'),
    PesanItem(
      Icons.help_outline,
      'Pusat Bantuan',
      'Pantau status bantuan dan pengaduan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan', style: TextStyle(color: Colors.grey[600])),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFFEDF6ED),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Panen',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green[900],
                        ),
                      ),
                      TextSpan(
                        text: 'Plus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Icon(Icons.notifications_none, color: Colors.grey[600]),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return PesanTile(
                  item: items[index],
                  onTap: () {
                    // Aksi ketika item ditekan
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
