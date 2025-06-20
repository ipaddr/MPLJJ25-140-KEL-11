// lib/screens/add_to_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panenplus/services/firestore_service.dart';

class AddToCartScreen extends StatefulWidget {
  const AddToCartScreen({super.key});

  @override
  State<AddToCartScreen> createState() => _AddToCartScreenState();
}

class _AddToCartScreenState extends State<AddToCartScreen> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  Future<void> _addToCart() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login untuk menambahkan ke keranjang.'),
            duration: Duration(seconds: 2), // Durasi lebih lama
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic>? product =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (product == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk tidak ditemukan.')),
          );
        }
        return;
      }

      // Pastikan parsedPrice aman
      final double parsedPrice =
          double.tryParse(
            product['price']
                .toString()
                .replaceAll('Rp ', '')
                .replaceAll(',', ''),
          ) ??
          0.0;

      // Buat item keranjang
      Map<String, dynamic> cartItem = {
        'productId': product['productId'], // ID produk dari Firestore
        'name': product['name'],
        'price': parsedPrice,
        'image': product['image'],
        'qty': _quantity,
        'notes': _notesController.text.trim(),
        'sellerId': product['sellerId'], // ID penjual
        'sellerName': product['sellerName'], // Nama penjual
      };

      await _firestoreService.updateCartItem(
        currentUser.uid,
        product['productId'], // Menggunakan productId sebagai document ID di sub-koleksi cart
        cartItem,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_quantity ${product['name']} ditambahkan ke keranjang!',
            ),
            duration: const Duration(
              seconds: 2,
            ), // Tampilkan SnackBar lebih lama
          ),
        );
        // Tambahkan jeda singkat sebelum pop agar pengguna sempat membaca SnackBar
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context); // Kembali ke MartScreen
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan ke keranjang: $e'),
            duration: const Duration(seconds: 3), // Durasi error lebih lama
          ),
        );
      }
    } finally {
      if (mounted) {
        // Pastikan mounted sebelum setState di finally
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? product =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    final String productName = product['name'] ?? 'Produk Tidak Dikenal';
    final String productPrice = product['price'] ?? '0';
    final String productImage =
        product['image'] ?? 'assets/images/product_placeholder.png';
    // Hati-hati dengan parsing harga jika formatnya "Rp 10.000,00"
    final double parsedPrice =
        double.tryParse(
          productPrice
              .replaceAll('Rp ', '')
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0.0; // Mengganti koma jadi titik untuk parsing
    final num currentTotal = parsedPrice * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xffC5DDBF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informasi Produk
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      productImage.startsWith('http')
                          ? Image.network(
                            productImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  width: 100,
                                  height: 100,
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Image.asset(
                            productImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  width: 100,
                                  height: 100,
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${productPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'dalam satuan kg',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // Bagian Kuantitas
            const Text(
              'Kuantitas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.black),
                        onPressed: _decrementQuantity,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.black),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  'Total untuk item ini: Rp ${currentTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Catatan Pesanan
            const Text(
              'Catatan Tambahan (opsional):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: "Minta tomat yang agak hijau"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 30),

            // Tombol "Tambah ke Keranjang"
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addToCart, // Panggil fungsi _addToCart
                    icon: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Tambah ke Keranjang',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
