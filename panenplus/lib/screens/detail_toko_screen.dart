import 'package:flutter/material.dart';
import 'mart_screen.dart';

class DetailTokoScreen extends StatelessWidget {
  const DetailTokoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFA9CBB7),
        title: const Text('Toko Saya', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // kembali ke halaman sebelumnya (Mart)
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
                    children: const [
                      Icon(Icons.person, size: 40, color: Colors.green),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laudya & Nilam',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Mobile Programming Lanjut',
                            style: TextStyle(color: Colors.grey),
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

            const SizedBox(height: 8),

            // Etalase Toko
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Etalase Toko Laudya & Nilam',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: const [
                      _ProductItem(
                        name: 'Jagung',
                        price: 'Rp. 17,000',
                        stock: '11',
                        image: 'assets/jagung.png',
                      ),
                      _ProductItem(
                        name: 'Tomat',
                        price: 'Rp. 18,000',
                        stock: '7',
                        image: 'assets/tomat.png',
                      ),
                      _ProductItem(
                        name: 'Wortel',
                        price: 'Rp. 10,000',
                        stock: '3',
                        image: 'assets/wortel.png',
                      ),
                      _ProductItem(
                        name: 'Kentang',
                        price: 'Rp. 25,000',
                        stock: '23',
                        image: 'assets/kentang.png',
                      ),
                      _ProductItem(
                        name: 'Beras',
                        price: 'Rp. 20,000',
                        stock: '47',
                        image: 'assets/beras.png',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // ubah sesuai kebutuhan
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MartTab()),
            );
          } else if (index == 1) {
            // TODO: Arahkan ke keranjang
          } else if (index == 2) {
            // TODO: Arahkan ke akun
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String count, String label) {
    return Column(
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
    );
  }
}

class _ProductItem extends StatelessWidget {
  final String name;
  final String price;
  final String stock;
  final String image;

  const _ProductItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Image.network(image, height: 60, fit: BoxFit.cover),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(price, style: const TextStyle(color: Colors.black87)),
          Text('Stok: $stock', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
