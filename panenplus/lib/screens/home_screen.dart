import 'package:flutter/material.dart';
import 'mart_screen.dart';
//import 'notifications_screen.dart';
//import 'orders_screen.dart';
import 'toko_saya_screen.dart';
import 'unggah_produk_screen.dart';
import 'cart_screen.dart'; // Import cart_screen.dart untuk navigasi ke Keranjang

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            Colors.grey[50], // Sedikit off-white untuk background keseluruhan
        // AppBar kustom agar sesuai dengan desain PanenPlus di Dashboard.png
        appBar: PreferredSize(
          // Tinggi PreferredSize yang disesuaikan
          // kToolbarHeight adalah tinggi default AppBar (56.0)
          // kTextTabBarHeight adalah tinggi default TabBar (48.0)
          // Menambahkan sedikit extra padding (misal 10.0 atau 16.0) untuk visual separation
          preferredSize: const Size.fromHeight(
            kToolbarHeight + kTextTabBarHeight + 16.0,
          ),
          child: AppBar(
            backgroundColor: const Color(
              0xFFC7D9C7,
            ), // Warna AppBar dari Dashboard.png
            elevation: 0, // Tanpa bayangan
            automaticallyImplyLeading:
                false, // Jangan tampilkan tombol back default
            flexibleSpace: Padding(
              // Padding atas disesuaikan untuk memperhitungkan status bar
              // dan memberikan ruang yang lebih baik
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(
                      context,
                    ).padding.top, // Tambahkan padding.top dari sistem
                left: 16.0,
                right: 16.0,
                bottom: 8.0, // Jarak ke TabBar
              ),
              child: Column(
                // Gunakan Column untuk menata logo dan TabBar
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menggunakan Image.asset untuk logo teks PanenPlus agar sesuai dengan gambar
                      Image.asset(
                        'assets/logo.png', // Pastikan path ini benar di assets Anda
                        height: 110, // Sesuaikan tinggi sesuai gambar
                        errorBuilder:
                            (context, error, stackTrace) => const Text(
                              'PanenPlus', // Fallback text jika gambar tidak ditemukan
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color.fromARGB(
                                  255,
                                  40,
                                  47,
                                  36,
                                ), // Warna hijau gelap jika fallback
                              ),
                            ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Color(
                            0xFF8BC34A,
                          ), // Warna hijau sedikit lebih terang untuk ikon notifikasi
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      ),
                    ],
                  ),
                  // TabBar diletakkan di sini, di bagian bawah Column flexibleSpace
                  // Sudah ada di dalam AppBar.bottom, jadi tidak perlu di sini lagi
                  // TabBar ini akan diganti dengan yang di AppBar.bottom
                ],
              ),
            ),
            bottom: const TabBar(
              // TabBar ini yang akan ditampilkan
              indicatorColor: Color.fromARGB(
                255,
                55,
                94,
                57,
              ), // Warna indikator dari Anda
              labelColor: Color.fromARGB(
                255,
                0,
                0,
                0,
              ), // Warna label yang dipilih
              unselectedLabelColor:
                  Colors.black54, // Warna label yang tidak dipilih
              tabs: [Tab(text: 'Bisnis'), Tab(text: 'Mart')],
            ),
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
          // Baris Menu Ikon (Cari, Keranjang, Pesanan, Toko Saya)
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
                iconColor: const Color(0xFF558B2F), // Hijau gelap
                backgroundColor: Colors.white, // Background putih
              ),
              _IconMenu(
                icon: Icons.shopping_cart,
                label: 'Keranjang',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/cart',
                  ); // Navigasi ke CartScreen
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
              _IconMenu(
                icon: Icons.list_alt,
                label: 'Pesanan',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/orders',
                  ); // Navigasi ke OrdersScreen
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
              _IconMenu(
                icon: Icons.store,
                label: 'Toko Saya',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/toko_saya',
                  ); // Navigasi ke TokoSayaScreen
                },
                iconColor: const Color(0xFF558B2F),
                backgroundColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Banner "Selamat siang, NL!"
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF4D5,
              ), // Warna kuning sangat pucat, mendekati off-white di gambar
              borderRadius: BorderRadius.circular(12),
              // Tambahkan shadow halus
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

          // Horizontal Image Cards (Promo/Banner)
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ImageCard(
                  imagePath:
                      'assets/1.png', // Pastikan path ini benar di assets Anda
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

          // "Upload Produk ke PanenPlus" Section
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/upload',
              ); // Navigasi ke halaman Upload
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

          // Category Cards
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
                icon: Icons.rice_bowl, // Fallback icon jika gambar tidak ada
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
                icon: Icons.local_florist, // Fallback icon
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
                icon: Icons.apple, // Fallback icon
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// _IconMenu disesuaikan agar bisa dikustomisasi warna ikon dan backgroundnya
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
    this.iconColor = Colors.white, // Default putih
    this.backgroundColor = const Color(0xFF6B8E23), // Default hijau gelap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28, // Ukuran ikon menu sesuai Dashboard.png
            backgroundColor:
                backgroundColor, // Background yang bisa dikustomisasi
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ), // Warna ikon yang bisa dikustomisasi
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14)), // Font size 14
        ],
      ),
    );
  }
}

// _ImageCard disesuaikan agar gambar dimuat dari asset dan bisa diklik
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
          // Menggunakan Image.asset karena path yang Anda berikan adalah aset lokal
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          // Tambahkan shadow untuk efek 'floating'
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // Bayangan ke bawah
            ),
          ],
        ),
        // Tambahkan child ini agar errorBuilder berfungsi jika gambar tidak ditemukan
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

// _CategoryCard disesuaikan agar bisa diklik dan ikonnya dinamis
class _CategoryCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon; // Tambahkan parameter ikon fallback
  final String? imagePath; // Tambahkan parameter untuk gambar kategori

  const _CategoryCard({
    required this.label,
    required this.onTap,
    required this.icon, // Ikon tetap wajib untuk fallback
    this.imagePath, // Image path opsional
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
              color: Colors.grey.withOpacity(0.2), // Shadow lebih halus
              blurRadius: 4,
              offset: const Offset(0, 2), // Bayangan ke bawah
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan gambar jika ada, jika tidak, tampilkan ikon
            if (imagePath != null && imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(
                  8,
                ), // Sedikit rounded corner untuk gambar kategori
                child: Image.asset(
                  imagePath!,
                  width: 50, // Ukuran gambar kategori
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(
                        icon,
                        color: const Color(0xFF424242),
                      ), // Fallback ke ikon
                ),
              )
            else
              Icon(
                icon,
                color: const Color(0xFF424242),
              ), // Warna ikon abu-abu gelap
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
