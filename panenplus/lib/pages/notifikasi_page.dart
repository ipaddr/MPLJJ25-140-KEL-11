import 'package:flutter/material.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildAktivitasTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_none, size: 32, color: Colors.grey),
          title: const Text("Panen Hari ini"),
        ),
        ListTile(
          leading: Icon(Icons.chat_bubble_outline, size: 32, color: Colors.brown[400]),
          title: const Text("Hasil Panen"),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String text) {
    return Center(child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.grey)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Notifikasi", style: TextStyle(color: Colors.grey)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
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

              // Tab Bar
              TabBar(
                controller: _tabController,
                labelColor: Colors.green[800],
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.green[800],
                tabs: const [
                  Tab(text: "Aktivitas"),
                  Tab(text: "Transaksi"),
                  Tab(text: "Update"),
                ],
              ),
            ],
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAktivitasTab(),
          _buildPlaceholderTab("Belum ada transaksi."),
          _buildPlaceholderTab("Belum ada update."),
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
