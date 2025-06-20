// lib/screens/akun_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';
import '../screens/toko_saya_screen.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunPage> {
  String _username = 'Loading...';
  String _email = 'Loading...';
  // String _phone = 'Loading...'; // Dihapus karena tidak digunakan di UI ini (sesuai peringatan)
  String _profileImageUrl = '';
  String _storeDescription =
      'Loading...'; // Tambahkan dan akan diisi dari Firestore
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    // print('DEBUG: _loadUserData dipanggil.'); // Hapus print di produksi
    if (currentUser != null) {
      // print('DEBUG: User saat ini ada. UID: ${currentUser.uid}'); // Hapus print
      try {
        DocumentSnapshot userDoc = await _firestoreService.getUserData(
          currentUser.uid,
        );
        // print('DEBUG: Dokumen user diambil dari Firestore.'); // Hapus print

        if (userDoc.exists) {
          // print('DEBUG: Dokumen user ditemukan di Firestore.'); // Hapus print
          final userData = userDoc.data() as Map<String, dynamic>;
          // print('DEBUG: Data user dari Firestore: $userData'); // Hapus print
          setState(() {
            _username =
                userData['username'] ??
                currentUser.displayName ??
                'Pengguna PanenPlus';
            _email =
                userData['email'] ?? currentUser.email ?? 'Tidak ada email';
            // _phone = userData['phone'] ?? 'Tidak ada nomor telepon'; // Baris ini tidak terpakai di UI Akun, jadi dihapus.
            _profileImageUrl = userData['profileImageUrl'] ?? '';
            _storeDescription =
                userData['storeDescription'] ??
                'Pengguna Aplikasi'; // Ambil deskripsi toko
            // print('DEBUG: State diperbarui. Username: $_username'); // Hapus print
          });
        } else {
          // print('DEBUG: Dokumen user TIDAK ditemukan di Firestore. Membuat dokumen baru...'); // Hapus print
          await _firestoreService.saveNewUser(
            currentUser.uid,
            currentUser.displayName ?? '',
            currentUser.email ?? '',
            '', // Nomor telepon kosong
          );
          if (mounted) {
            // print('DEBUG: Dokumen baru dibuat. Memanggil _loadUserData() lagi.'); // Hapus print
            _loadUserData(); // Rekursif untuk me-reload data yang baru dibuat
          }
        }
      } catch (e) {
        // print('DEBUG: Error saat memuat data profil: $e'); // Hapus print
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data profil: $e')),
          );
        }
        setState(() {
          _username = currentUser.displayName ?? 'Error';
          _email = currentUser.email ?? 'Error';
          // _phone = 'Error'; // Baris ini tidak terpakai di UI Akun, jadi dihapus.
          _storeDescription = 'Error';
        });
      }
    } else {
      // print('DEBUG: User belum login.'); // Hapus print
      setState(() {
        _username = 'Tamu';
        _email = 'Silakan login';
        // _phone = ''; // Baris ini tidak terpakai di UI Akun, jadi dihapus.
        _storeDescription = '';
      });
    }
  }

  Widget _buildOrderItem(String title) {
    return Expanded(
      child: Column(
        children: [
          const Text(
            "0", // Ini masih manual, butuh query ke koleksi orders
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          if (!mounted)
            return; // Tambahkan cek mounted di awal scope yang menggunakan context
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Promo "$title" diklik!'),
            ), // Perbaikan interpolasi string
          );
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
              // Tampilkan gambar profil dari Firestore atau ikon default
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green.shade100,
                backgroundImage:
                    _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                            as ImageProvider // Cast ke ImageProvider
                        : null,
                child:
                    _profileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 28, color: Colors.green[800])
                        : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _username, // Menampilkan username dari Firestore
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    // INI PERBAIKANNYA: Menggunakan _storeDescription
                    _storeDescription, // Menampilkan deskripsi toko/profil dari Firestore
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
                await FirebaseAuth.instance.signOut();
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
