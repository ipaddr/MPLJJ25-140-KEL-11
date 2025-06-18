import 'package:flutter/material.dart';
import '../screens/toko_saya_screen.dart'; // Pastikan path ini benar

// import 'package:cloud_firestore/cloud_firestore.dart'; // Hapus import ini jika tidak ada lagi kebutuhan Firestore di file ini

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  // Variabel state untuk data pengguna (sekarang diisi manual)
  String _username = 'Laudya & Nilam';
  String _email =
      'Mobile Programming Lanjut'; // Menggunakan ini sebagai deskripsi di mockup
  String _profileImageUrl =
      ''; // Biarkan kosong jika tidak ada gambar profil manual

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengisi data secara manual
    _loadManualUserData();
  }

  // Fungsi untuk mengisi data pengguna secara manual
  void _loadManualUserData() {
    setState(() {
      _username = 'Laudya & Nilam'; // Data manual
      _email = 'Mobile Programming Lanjut'; // Data manual
      _profileImageUrl =
          ''; // Atau 'assets/images/user_avatar.png' jika Anda memiliki gambar manual
    });
  }

  Widget _buildOrderItem(String title) {
    return Expanded(
      child: Column(
        children: [
          // Ini tetap 0, karena Anda belum terhubung ke database pesanan
          Text(
            "0",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPromoCard(Color bgColor, String title, String desc) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // TODO: Navigasi atau fungsi untuk detail promo
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Promo "${title}" diklik!')));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: const Color(0xFFCDE2C4),
          elevation: 2,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
            child: Row(
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Panen',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Plus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Halaman Notifikasi belum diimplementasikan!',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Text(
              'AKUN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person, color: Colors.green[800]),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username, // Menampilkan username manual
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _email, // Menampilkan email manual
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TokoSayaScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF6ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_border,
                        color: Colors.green[900],
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Toko Saya',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Pesanan Saya",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOrderItem('Pesanan Saya'),
                _buildOrderItem('Dikemas'),
                _buildOrderItem('Dikirim'),
                _buildOrderItem('Beri Penilaian'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildPromoCard(
                const Color(0xFFFFC8C8),
                'PROMO\nPOTONGAN HARGA!',
                'Cek selengkapnya untuk PROMO POTONGAN HARGA...',
              ),
              _buildPromoCard(
                const Color(0xFFCDE2C4),
                'PROMO\nGRATIS ONGKIR!',
                'Cek selengkapnya untuk PROMO GRATIS ONGKIR...',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
