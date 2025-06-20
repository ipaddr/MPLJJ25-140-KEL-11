import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panenplus/screens/chat_screen.dart'; // Pastikan import ini ada

class DetailTokoScreen extends StatefulWidget {
  const DetailTokoScreen({super.key});

  @override
  State<DetailTokoScreen> createState() => _DetailTokoScreenState();
}

class _DetailTokoScreenState extends State<DetailTokoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  Map<String, dynamic>? _productData;
  Map<String, dynamic>? _sellerData;

  String _productName = 'Loading...';
  String _productPrice = 'Loading...';
  String _productImage = ''; // Default kosong agar bisa menampilkan placeholder
  String _productDescription = 'Loading...';
  String _productStock = 'Loading...';
  String _sellerName = 'Loading...';
  String _sellerProfileImage = ''; // Untuk foto profil penjual

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_productData == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['productId'] != null) {
        _fetchProductAndSellerData(args['productId'] as String);
      } else {
        _updateUIWithArgs(args);
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateUIWithArgs(Map<String, dynamic>? args) {
    setState(() {
      _productName = args?['productName'] ?? 'Nama Produk';
      _productPrice = args?['price'] ?? 'Rp 0';
      _productImage = args?['imageUrl'] ?? '';
      _productDescription = args?['description'] ?? 'Tidak ada deskripsi.';
      _productStock = args?['stock'] ?? '0';
      _sellerName = args?['storeName'] ?? 'Nama Toko Penjual';
    });
  }

  Future<void> _fetchProductAndSellerData(String productId) async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot? productDoc = await _firestoreService.getProductDetails(
        productId,
      );
      if (productDoc.exists) {
        _productData = productDoc.data() as Map<String, dynamic>;

        String sellerId = _productData?['sellerId'] ?? '';
        if (sellerId.isNotEmpty) {
          DocumentSnapshot sellerDoc = await _firestoreService.getUserData(
            sellerId,
          );
          if (sellerDoc.exists) {
            _sellerData = sellerDoc.data() as Map<String, dynamic>;
          }
        }

        if (mounted) {
          setState(() {
            _productName = _productData?['productName'] ?? 'Nama Produk';
            _productPrice =
                'Rp ${_productData?['price']?.toStringAsFixed(0) ?? '0'}';
            _productImage = _productData?['imageUrl'] ?? '';
            _productDescription =
                _productData?['description'] ?? 'Tidak ada deskripsi.';
            _productStock = _productData?['stock']?.toString() ?? '0';
            _sellerName =
                _sellerData?['username'] ??
                _productData?['sellerName'] ??
                'Penjual';
            _sellerProfileImage = _sellerData?['profileImageUrl'] ?? '';
          });
        }
      } else {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        _updateUIWithArgs(args);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail produk: $e')),
        );
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        _updateUIWithArgs(args);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  // --- AppBar dengan Gambar Produk ---
                  SliverAppBar(
                    expandedHeight: 300.0,
                    pinned: true,
                    backgroundColor: const Color(0xffC5DDBF),
                    leading: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background:
                          _productImage.isNotEmpty
                              ? Image.network(
                                _productImage,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 100,
                                            color: Colors.white,
                                          ),
                                        ),
                              )
                              : Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                    ),
                  ),
                  // --- Konten Detail Produk ---
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // --- Informasi Nama & Harga ---
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _productName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _productPrice,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stok: $_productStock',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- Informasi Penjual ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        color: Colors.white,
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  _sellerProfileImage.isNotEmpty
                                      ? NetworkImage(_sellerProfileImage)
                                      : null,
                              backgroundColor: Colors.green.shade100,
                              child:
                                  _sellerProfileImage.isEmpty
                                      ? Icon(
                                        Icons.store,
                                        color: Colors.green[800],
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _sellerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              onPressed:
                                  () => Navigator.pushNamed(
                                    context,
                                    '/toko_saya',
                                  ),
                              child: const Text('Kunjungi Toko'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- Deskripsi Produk ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _productDescription,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
      bottomNavigationBar: _buildActionBottomBar(),
    );
  }

  // --- Bottom Bar untuk Tombol Aksi ---
  Widget _buildActionBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          // --- Tombol Chat ---
          OutlinedButton(
            onPressed: () {
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Anda harus login untuk memulai chat."),
                  ),
                );
                return;
              }
              if (_productData == null) return;
              if (currentUser.uid == _productData!['sellerId']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Anda tidak bisa chat dengan toko sendiri."),
                  ),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChatScreen(
                        sellerId: _productData!['sellerId'],
                        sellerName: _sellerName,
                        buyerId: currentUser.uid,
                        buyerName: currentUser.displayName ?? 'Pembeli',
                      ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.chat_bubble_outline, color: Colors.green[800]),
          ),
          const SizedBox(width: 12),
          // --- Tombol Tambah Keranjang ---
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (_productData != null) {
                  Navigator.pushNamed(
                    context,
                    '/add_to_cart',
                    arguments: {
                      'productId': _productData!['productId'] ?? '',
                      'name': _productData!['productName'],
                      'price': _productData!['price']?.toString(),
                      'image': _productData!['imageUrl'],
                      'sellerId': _productData!['sellerId'],
                      'sellerName': _productData!['sellerName'],
                      'stock': _productData!['stock'],
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[900],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Tambah Keranjang'),
            ),
          ),
          const SizedBox(width: 12),
          // --- Tombol Beli Sekarang ---
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Fitur Beli Sekarang belum diimplementasikan.',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Beli Sekarang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }
}
