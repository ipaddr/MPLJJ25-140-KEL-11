import 'package:flutter/material.dart';
import 'mart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(
            kToolbarHeight + kTextTabBarHeight + 16.0,
          ),
          child: AppBar(
            backgroundColor: const Color(0xFFCDE2C4),
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8.0,
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 35,
                        errorBuilder:
                            (context, error, stackTrace) => const Text(
                              'PanenPlus',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0xFF558B2F),
                              ),
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(0xFF8BC34A),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 55, 94, 57),
              labelColor: Color.fromARGB(255, 0, 0, 0),
              unselectedLabelColor: Colors.black54,
              tabs: [Tab(text: 'Bisnis'), Tab(text: 'Mart')],
            ),
          ),
        ),
        body: TabBarView(
          // HAPUS 'const' DI SINI SAAT MEMANGGIL MartTab()
          children: [_buildBisnisTab(context), MartTab()],
        ),
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
            children: [
              _IconMenu(
                icon: Icons.search,
                label: 'Cari',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur Cari belum diimplementasikan!'),
                    ),
                  );
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
              _IconMenu(
                icon: Icons.shopping_cart,
                label: 'Keranjang',
                onTap: () {
                  Navigator.pushNamed(context, '/addToCart');
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
              _IconMenu(
                icon: Icons.chat,
                label: 'Chat',
                onTap: () {
                  Navigator.pushNamed(context, '/chat');
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
              _IconMenu(
                icon: Icons.store,
                label: 'Toko Saya',
                onTap: () {
                  Navigator.pushNamed(context, '/toko_saya');
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFCE9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
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
                _ImageCard(
                  imagePath: 'assets/1.png',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Detail promo 1 belum diimplementasikan!',
                        ),
                      ),
                    );
                  },
                ),
                _ImageCard(
                  imagePath: 'assets/2.png',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Detail promo 2 belum diimplementasikan!',
                        ),
                      ),
                    );
                  },
                ),
                _ImageCard(
                  imagePath: 'assets/3.png',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Detail promo 3 belum diimplementasikan!',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/upload');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Upload Produk ke PanenPlus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CategoryCard(
                label: 'Makanan pokok',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Filter Makanan pokok belum diimplementasikan!',
                      ),
                    ),
                  );
                },
                icon: Icons.rice_bowl,
              ),
              _CategoryCard(
                label: 'Sayuran',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Filter Sayuran belum diimplementasikan!'),
                    ),
                  );
                },
                icon: Icons.local_florist,
              ),
              _CategoryCard(
                label: 'Buah-buahan',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Filter Buah-buahan belum diimplementasikan!',
                      ),
                    ),
                  );
                },
                icon: Icons.apple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _IconMenu, _ImageCard, _CategoryCard tetap sama seperti terakhir Anda miliki
class _IconMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;

  const _IconMenu({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
    this.backgroundColor = const Color(0xFF6B8E23),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: backgroundColor,
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _ImageCard({required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: Text(
                    'Gambar tidak ditemukan: $imagePath',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final String? imagePath;

  const _CategoryCard({
    required this.label,
    required this.onTap,
    required this.icon,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null && imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(icon, color: const Color(0xFF424242)),
                ),
              )
            else
              Icon(icon, color: const Color(0xFF424242)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
