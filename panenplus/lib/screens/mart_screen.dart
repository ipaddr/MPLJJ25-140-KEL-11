// lib/screens/mart_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';
import 'detail_toko_screen.dart';
import 'toko_saya_screen.dart';
import 'add_to_cart_screen.dart';

class MartTab extends StatelessWidget {
  // HAPUS KATA KUNCI 'const' DARI SINI
  MartTab({Key? key}) : super(key: key);

  final FirestoreService _firestoreService =
      FirestoreService(); // Ini sekarang valid

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bagian Toko Saya (sama seperti sebelumnya)
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/toko_saya');
          },
          child: Container(
            color: const Color(0xfff0f7ec),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: const [
                Icon(Icons.favorite_border, color: Colors.black),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toko Saya\nToko menjual makanan pokok, sayuran, buah-buahan...',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.black),
              ],
            ),
          ),
        ),

        // Rekomendasi Hari Ini + Search (sama seperti sebelumnya)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rekomendasi hari ini',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fungsi pencarian belum diimplementasikan!',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Mengambil dan menampilkan produk dari Firestore (sama seperti sebelumnya)
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestoreService.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error memuat produk: ${snapshot.error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada produk. Silakan unggah produk pertama Anda!',
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.7,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var productDoc = snapshot.data!.docs[index];
                  var productData = productDoc.data() as Map<String, dynamic>;

                  return _MartProductCard(
                    productId: productDoc.id,
                    name: productData['productName'] ?? 'Nama Produk',
                    price:
                        'Rp ${productData['price']?.toStringAsFixed(0) ?? '0'}',
                    image:
                        productData['imageUrl'] ??
                        'assets/images/product_placeholder.png',
                    sellerName:
                        productData['sellerName'] ?? 'Penjual Tidak Dikenal',
                    sellerId: productData['sellerId'] ?? '',
                    stock: productData['stock'] ?? 0,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/detail_toko',
                        arguments: {
                          'productId': productDoc.id,
                          'productName': productData['productName'],
                          'price': productData['price']?.toStringAsFixed(0),
                          'imageUrl': productData['imageUrl'],
                          'description': productData['description'],
                          'storeName': productData['sellerName'],
                          'stock': productData['stock']?.toString() ?? '0',
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// _MartProductCard tetap sama seperti terakhir Anda miliki
class _MartProductCard extends StatelessWidget {
  final String productId;
  final String name;
  final String price;
  final String image;
  final String sellerName;
  final String sellerId;
  final int stock;
  final VoidCallback onTap;

  const _MartProductCard({
    Key? key,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.sellerName,
    required this.sellerId,
    required this.stock,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    image.startsWith('http')
                        ? Image.network(
                          image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                width: double.infinity,
                                height: double.infinity,
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : Image.asset(
                          image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                width: double.infinity,
                                height: double.infinity,
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'dalam satuan kg',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 153, 180, 154),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          size: 24,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/add_to_cart',
                            arguments: {
                              'productId': productId,
                              'name': name,
                              'price': price,
                              'image': image,
                              'sellerId': sellerId,
                              'sellerName': sellerName,
                              'stock': stock,
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 24),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Menambahkan $name ke favorit!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/toko_saya');
                    },
                    child: Text(
                      sellerName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
