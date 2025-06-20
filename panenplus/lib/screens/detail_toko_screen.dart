import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart'; // Import FirestoreService

class DetailTokoScreen extends StatefulWidget {
  const DetailTokoScreen({super.key});

  @override
  State<DetailTokoScreen> createState() => _DetailTokoScreenState();
}

class _DetailTokoScreenState extends State<DetailTokoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  Map<String, dynamic>? _productData; // Data produk yang diambil
  Map<String, dynamic>? _sellerData; // Data penjual yang diambil

  String _productName = 'Loading...';
  String _productPrice = 'Loading...';
  String _productImage = 'assets/images/product_placeholder.png';
  String _productDescription = 'Loading...';
  String _productStock = 'Loading...';
  String _sellerName = 'Loading...';

  @override
  void initState() {
    super.initState();
    // Data produk akan dimuat setelah argumen tersedia di didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_productData == null) {
      // Muat hanya sekali
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['productId'] != null) {
        _fetchProductAndSellerData(args['productId'] as String);
      } else {
        // Jika tidak ada productId, gunakan data dari argumen dan jangan load
        _updateUIWithArgs(args);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateUIWithArgs(Map<String, dynamic>? args) {
    setState(() {
      _productName = args?['productName'] ?? 'Nama Produk';
      _productPrice = args?['price'] ?? 'Rp 0';
      _productImage =
          args?['imageUrl'] ?? 'assets/images/product_placeholder.png';
      _productDescription = args?['description'] ?? 'Tidak ada deskripsi.';
      _productStock = args?['stock'] ?? '0';
      _sellerName = args?['storeName'] ?? 'Nama Toko Penjual';
    });
  }

  Future<void> _fetchProductAndSellerData(String productId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot productDoc = await _firestoreService.getProductDetails(
        productId,
      );
      if (productDoc.exists) {
        _productData = productDoc.data() as Map<String, dynamic>;

        // Fetch seller data
        String sellerId = _productData?['sellerId'] ?? '';
        if (sellerId.isNotEmpty) {
          DocumentSnapshot sellerDoc = await _firestoreService.getUserData(
            sellerId,
          );
          if (sellerDoc.exists) {
            _sellerData = sellerDoc.data() as Map<String, dynamic>;
          }
        }

        setState(() {
          _productName = _productData?['productName'] ?? 'Nama Produk';
          _productPrice =
              'Rp ${_productData?['price']?.toStringAsFixed(0) ?? '0'}';
          _productImage =
              _productData?['imageUrl'] ??
              'assets/images/product_placeholder.png';
          _productDescription =
              _productData?['description'] ?? 'Tidak ada deskripsi.';
          _productStock = _productData?['stock']?.toString() ?? '0';
          _sellerName =
              _sellerData?['username'] ??
              _productData?['sellerName'] ??
              'Penjual';
        });
      } else {
        // Product not found in Firestore, fallback to args if any
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        _updateUIWithArgs(args);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail produk: $e')),
        );
      }
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _updateUIWithArgs(args); // Fallback to args on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Produk'), // Judul sesuai fungsi layar
        backgroundColor: const Color(0xffC5DDBF), // Warna AppBar konsisten
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Produk
                    if (_productImage.startsWith('http'))
                      Image.network(
                        _productImage,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: _imageErrorBuilder,
                      )
                    else
                      Image.asset(
                        _productImage,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: _imageErrorBuilder,
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _productName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _productPrice,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.store, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _sellerName, // Nama penjual
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Navigasi ke halaman toko penjual ini
                                  // Pastikan _productData memiliki 'sellerId' untuk ini
                                  Navigator.pushNamed(
                                    context,
                                    '/toko_saya',
                                  ); // Atau rute spesifik ke toko penjual
                                },
                                icon: const Icon(Icons.storefront),
                                label: const Text('Kunjungi Toko'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  foregroundColor: Colors.black87,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Deskripsi Produk:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _productDescription,
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Stok: $_productStock',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Navigasi ke AddToCartScreen untuk menambah/mengatur kuantitas
                                    // Asumsi AddToCartScreen menerima data produk
                                    if (_productData != null) {
                                      Navigator.pushNamed(
                                        context,
                                        '/add_to_cart',
                                        arguments: {
                                          'productId':
                                              _productData!['productId'] ??
                                              '', // Pastikan ada ID produk
                                          'name': _productData!['productName'],
                                          'price':
                                              _productData!['price']
                                                  ?.toString(), // Kirim harga sebagai string
                                          'image': _productData!['imageUrl'],
                                          'sellerId': _productData!['sellerId'],
                                          'sellerName':
                                              _productData!['sellerName'],
                                          'stock': _productData!['stock'],
                                        },
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Detail produk tidak lengkap.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.green,
                                  ),
                                  label: const Text(
                                    'Tambah Keranjang',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    side: const BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fitur Beli Sekarang belum diimplementasikan.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Beli Sekarang',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 50, color: Colors.grey),
      ),
    );
  }
}
