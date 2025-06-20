// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart'; // Import FirestoreService

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirestoreService _firestoreService =
      FirestoreService(); // Inisialisasi service
  String _customerName = 'Loading...';
  String _customerPhone = 'Loading...';
  String _customerAddress = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadCustomerAddress();
  }

  Future<void> _loadCustomerAddress() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestoreService.getUserData(
          currentUser.uid,
        );
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _customerName =
                userData['username'] ?? currentUser.displayName ?? 'Pengguna';
            _customerPhone = userData['phone'] ?? 'Tidak ada nomor telepon';
            _customerAddress = userData['address'] ?? 'Tidak ada alamat';
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat alamat: $e')));
        }
      }
    }
  }

  // Fungsi untuk memperbarui kuantitas di Firestore
  void _updateQuantityInCart(
    String productId,
    String cartItemId,
    int delta,
    int currentQty,
  ) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    int newQty = currentQty + delta;

    try {
      if (newQty > 0) {
        await _firestoreService.updateCartItem(currentUser.uid, productId, {
          'qty': newQty,
        });
      } else {
        await _firestoreService.removeCartItem(currentUser.uid, productId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui kuantitas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Keranjang Belanja')),
        body: const Center(
          child: Text('Silakan login untuk melihat keranjang Anda.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          color: const Color(0xFFCDE2C4),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 40.0,
              left: 16.0,
              right: 16.0,
              bottom: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getCartItems(
          currentUser.uid,
        ), // Ambil item keranjang dari Firestore
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Keranjang Anda kosong.'));
          }

          List<Map<String, dynamic>> displayedItems =
              snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['cartItemId'] = doc.id; // Simpan ID dokumen keranjang
                return data;
              }).toList();

          num grandTotal = displayedItems.fold(
            0,
            (sum, item) => sum + (item['qty'] * item['price']),
          );

          return Column(
            children: [
              // Alamat Pengiriman
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_customerName $_customerPhone',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _customerAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Fitur edit alamat belum diimplementasikan!',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'edit alamat',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 0, thickness: 1, indent: 16, endIndent: 16),

              // Daftar Produk di Keranjang
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: displayedItems.length,
                  itemBuilder: (context, index) {
                    final item = displayedItems[index];
                    return _CartItemCard(
                      name: item['name']!,
                      image: item['image']!,
                      price:
                          (item['price'] as num).toDouble(), // Pastikan double
                      qty: item['qty']!,
                      onAdd:
                          () => _updateQuantityInCart(
                            item['productId']!,
                            item['cartItemId']!,
                            1,
                            item['qty']!,
                          ),
                      onRemove:
                          () => _updateQuantityInCart(
                            item['productId']!,
                            item['cartItemId']!,
                            -1,
                            item['qty']!,
                          ),
                    );
                  },
                ),
              ),

              // Total dan Tombol "Buat Pesanan"
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total: Rp ${grandTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (displayedItems.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Keranjang kosong, tidak bisa membuat pesanan.',
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          '/payment',
                          arguments: {
                            'orderedItems': displayedItems,
                            'totalPrice': grandTotal,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E23),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Buat Pesanan',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  image.startsWith('http')
                      ? Image.network(
                        image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: _imageErrorBuilder,
                      )
                      : Image.asset(
                        image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: _imageErrorBuilder,
                      ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'dalam satuan kg',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.menu, size: 20, color: Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opsi lainnya untuk ${name}')),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          size: 20,
                          color: Colors.green,
                        ),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$qty',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.green,
                        ),
                        onPressed: onAdd,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${(price * qty).toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.black, fontSize: 14),
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
      height: 80,
      width: 80,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }
}
