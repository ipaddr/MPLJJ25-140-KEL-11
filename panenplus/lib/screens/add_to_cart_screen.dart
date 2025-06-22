// lib/screens/add_to_cart_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panenplus/services/firestore_service.dart';

class AddToCartScreen extends StatefulWidget {
  // 1. Tambahkan properti untuk menerima data
  final Map<String, dynamic>? productData;
  // 2. Modifikasi constructor untuk menerima data
  const AddToCartScreen({super.key, this.productData});

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
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Ambil data dari WIDGET, bukan ModalRoute
      final Map<String, dynamic>? product = widget.productData;

      if (product == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk tidak ditemukan.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final double parsedPrice =
          double.tryParse(
            product['price']
                .toString()
                .replaceAll('Rp ', '')
                .replaceAll(',', ''),
          ) ??
          0.0;

      Map<String, dynamic> cartItem = {
        'productId': product['productId'],
        'name': product['name'],
        'price': parsedPrice,
        'image': product['image'],
        'qty': _quantity,
        'notes': _notesController.text.trim(),
        'sellerId': product['sellerId'],
        'sellerName': product['sellerName'],
      };

      await _firestoreService.updateCartItem(
        currentUser.uid,
        product['productId'],
        cartItem,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_quantity ${product['name']} ditambahkan ke keranjang!',
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan ke keranjang: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
    // 4. Ambil data dari WIDGET, bukan ModalRoute
    final Map<String, dynamic>? product = widget.productData;

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Produk tidak ditemukan.')),
      );
    }

    final String productName = product['name'] ?? 'Produk Tidak Dikenal';
    // Ambil harga dari argumen, pastikan tipenya benar (String atau num)
    final String productPriceString = product['price']?.toString() ?? '0';
    final String productImage =
        product['image'] ?? 'assets/images/product_placeholder.png';

    final double parsedPrice =
        double.tryParse(
          productPriceString.replaceAll(
            RegExp(r'[^0-9]'),
            '',
          ), // Hanya ambil angka
        ) ??
        0.0;
    final num currentTotal = parsedPrice * _quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah ke Keranjang'),
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
                          )
                          : Image.asset(
                            productImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
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
                        'Rp ${parsedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('per satuan', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Kuantitas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Catatan (Opsional)',
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Tambah Keranjang - Rp ${currentTotal.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
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
    );
  }
}
