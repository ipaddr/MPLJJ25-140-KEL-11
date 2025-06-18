import 'package:flutter/material.dart';

class InformasiPage extends StatelessWidget {
  const InformasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Informasi",
          style: TextStyle(color: Colors.grey),
        ),
      ),
      body: Column(
        children: [
          // Header PanenPlus
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFCFE3C3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Panen',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      TextSpan(
                        text: 'Plus',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),

          // Ruang Konsultasi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(Icons.chat_bubble_outline, size: 32, color: Colors.brown[400]),
                title: const Text(
                  "Ruang Konsultasi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Percakapan konsultasi saya"),
                onTap: () {
                  // Aksi ketika ditekan
                },
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: "Pesan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.green[700],
      ),
    );
  }
}
