import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart'; // Import FirestoreService

class TokoSayaScreen extends StatefulWidget {
  const TokoSayaScreen({super.key});

  @override
  State<TokoSayaScreen> createState() => _TokoSayaScreenState();
}

class _TokoSayaScreenState extends State<TokoSayaScreen> {
  String _storeName = 'Loading...';
  String _storeDescription = 'Loading...';
  String _profileImageUrl = '';
  num _totalRevenue = 0; // Inisialisasi total pemasukan
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    _fetchTotalRevenue(); // Panggil fungsi untuk mengambil pemasukan
  }

  Future<void> _fetchStoreData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestoreService.getUserData(
          currentUser.uid,
        );
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _storeName =
                userData['username'] ??
                currentUser.displayName ??
                'Nama Toko Anda';
            _storeDescription =
                userData['storeDescription'] ?? 'Penjual Produk Pertanian';
            _profileImageUrl = userData['profileImageUrl'] ?? '';
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat data toko: $e')));
        }
      }
    } else {
      setState(() {
        _storeName = 'Toko Tamu';
        _storeDescription = 'Login untuk melihat toko Anda';
      });
    }
  }

  Future<void> _fetchTotalRevenue() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Query ke koleksi 'orders'
      // Ini adalah contoh, Anda mungkin perlu menyesuaikan struktur data order Anda
      // Asumsi: Setiap order memiliki array 'items' yang berisi map produk,
      // dan setiap item produk memiliki 'sellerId' dan 'subtotal'
      QuerySnapshot ordersSnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .where(
                'sellerIdsInOrder',
                arrayContains: currentUser.uid,
              ) // Asumsi field ini ada
              .get();

      num sumRevenue = 0;
      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        List<dynamic> items =
            orderData['items'] ?? []; // Asumsi ada field 'items'
        for (var item in items) {
          if (item['sellerId'] == currentUser.uid) {
            sumRevenue +=
                (item['price'] * item['qty']) ??
                0; // Hitung pendapatan dari item ini
          }
        }
      }
      setState(() {
        _totalRevenue = sumRevenue;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat pemasukan: $e')));
      }
      setState(() {
        _totalRevenue = 0; // Set ke 0 jika gagal
      });
    }
  }

  Widget _buildStatusItem(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFC7D9C7),
        title: const Text('Toko Saya', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Info Toko
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade100,
                        backgroundImage:
                            _profileImageUrl.isNotEmpty
                                ? NetworkImage(_profileImageUrl)
                                    as ImageProvider
                                : null,
                        child:
                            _profileImageUrl.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.green[800],
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _storeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _storeDescription,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toko menjual berbagai bahan makanan pokok, sayuran, buah-buahan...',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Status Pesanan (tetap statis untuk saat ini)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem('0', 'Perlu dikirim'),
                  _buildStatusItem('0', 'Pembatalan'),
                  _buildStatusItem('0', 'Pengembalian'),
                  _buildStatusItem('0', 'Penilaian\nPerlu Dibalas'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Etalase Toko
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Etalase Toko', // Ubah teks agar lebih umum
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  // Mengambil produk dari Firestore
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        currentUser != null
                            ? _firestoreService.getProductsBySeller(
                              currentUser.uid,
                            )
                            : null, // Stream null jika user belum login
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Belum ada produk di etalase Anda.'),
                        );
                      }

                      // Tampilkan produk dalam Wrap
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:
                            snapshot.data!.docs.map((document) {
                              Map<String, dynamic> data =
                                  document.data() as Map<String, dynamic>;
                              String productId = document.id;

                              return _ProductItem(
                                productId: productId,
                                name: data['productName'] ?? 'Nama Produk',
                                price:
                                    'Rp ${data['price']?.toStringAsFixed(0) ?? '0'}',
                                stock:
                                    (data['stock'] ?? 0)
                                        .toString(), // Pastikan stok adalah int
                                image:
                                    data['imageUrl'] ??
                                    'assets/images/product_placeholder.png',
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/detail_toko',
                                    arguments: {
                                      'productId': productId,
                                      'productName': data['productName'],
                                      'price': data['price']?.toStringAsFixed(
                                        0,
                                      ),
                                      'imageUrl': data['imageUrl'],
                                      'description': data['description'],
                                      'storeName': _storeName,
                                      'stock': data['stock']?.toString() ?? '0',
                                    },
                                  );
                                },
                                onEdit: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/upload',
                                    arguments: {'productId': productId},
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Edit produk: ${data['productName']}',
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await _firestoreService.deleteProduct(
                                    productId,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${data['productName']} berhasil dihapus',
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/upload');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Tambah Produk Baru"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Halaman Pesanan Masuk belum diimplementasikan',
                              ),
                            ),
                          );
                        },
                        child: const Text("Pesanan Masuk"),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Halaman Histori Pesanan belum diimplementasikan',
                              ),
                            ),
                          );
                        },
                        child: const Text("Histori Pesanan"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total Pemasukan\nRp${_totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String productId;
  final String name;
  final String price;
  final String stock;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Gambar Produk
            if (image.startsWith('http')) // Gambar dari URL
              Image.network(
                image,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: _imageErrorBuilder,
              )
            else // Gambar dari asset (placeholder)
              Image.asset(
                image,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: _imageErrorBuilder,
              ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(price, style: const TextStyle(color: Colors.black87)),
            Text('Stok: $stock', style: const TextStyle(color: Colors.grey)),
            // Opsi edit/hapus
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit, size: 20, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete, size: 20, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      height: 60,
      width: 60,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 30, color: Colors.grey),
    );
  }
}
