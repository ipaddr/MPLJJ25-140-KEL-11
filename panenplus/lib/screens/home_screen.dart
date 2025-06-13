import 'package:flutter/material.dart';
import 'mart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xffC5DDBF),
          title: const Text(
            'PanenPlus',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.notifications_none,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Color.fromARGB(255, 55, 94, 57),
            labelColor: Color.fromARGB(255, 0, 0, 0),
            unselectedLabelColor: Colors.black54,
            tabs: [Tab(text: 'Bisnis'), Tab(text: 'Mart')],
          ),
        ),
        body: TabBarView(children: [_buildBisnisTab(context), const MartTab()]),
      ),
    );
  }

  Widget _buildBisnisTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _IconMenu(icon: Icons.search, label: 'Cari'),
              _IconMenu(icon: Icons.shopping_cart, label: 'Keranjang'),
              _IconMenu(icon: Icons.list_alt, label: 'Pesanan'),
              _IconMenu(icon: Icons.store, label: 'Toko Saya'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 243, 216),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Selamat siang, NL!\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 16,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Hasil panen langsung dari kebun petani lokal kami. Dipanen setiap pagi untuk menjaga kesegaran dan kandungan nutrisinya. Tanaman tumbuh tanpa pestisida kimia, menggunakan pupuk organik alami, dan diproses secara higienis.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ImageCard(imagePath: 'assets/1.png'),
                _ImageCard(imagePath: 'assets/2.png'),
                _ImageCard(imagePath: 'assets/3.png'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Upload Produk ke PanenPlus',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _CategoryCard(label: 'Makanan pokok'),
              _CategoryCard(label: 'Sayuran'),
              _CategoryCard(label: 'Buah-buahan'),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconMenu extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconMenu({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: const Color.fromARGB(255, 255, 255, 255)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;

  const _ImageCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;

  const _CategoryCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 66, 61, 61),
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.rice_bowl, color: Color.fromARGB(255, 94, 79, 79)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
