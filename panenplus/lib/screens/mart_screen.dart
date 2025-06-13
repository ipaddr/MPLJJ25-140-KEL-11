import 'package:flutter/material.dart';
import 'toko_saya_screen.dart';
import 'detail_toko_screen.dart';

class MartTab extends StatelessWidget {
  const MartTab({Key? key}) : super(key: key);

  final List<Map<String, String>> products = const [
    {'name': 'Sayur packoy', 'price': '15,000', 'image': 'assets/pakcoy.png'},
    {'name': 'Beras', 'price': '20,000', 'image': 'assets/beras.png'},
    {'name': 'Jagung', 'price': '17,000', 'image': 'assets/jagung.png'},
    {'name': 'Wortel', 'price': '10,000', 'image': 'assets/wortel.png'},
    {'name': 'Kentang', 'price': '25,000', 'image': 'assets/kentang.png'},
    {'name': 'Tomat', 'price': '18,000', 'image': 'assets/tomat.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info Toko
        Container(
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
            ],
          ),
        ),
        // mart_screen.dart
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TokoSayaScreen()),
            );
          },
          child: Container(
            color: Color(0xFFA9CBB7),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Toko Saya',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white),
              ],
            ),
          ),
        ),

        // Rekomendasi Hari Ini + Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Rekomendasi hari ini',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Icon(Icons.search),
            ],
          ),
        ),

        // List Produk
        Expanded(
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _MartProductCard(
                name: products[index]['name']!,
                price: products[index]['price']!,
                image: products[index]['image']!,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MartProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;

  const _MartProductCard({
    Key? key,
    required this.name,
    required this.price,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Info Produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Text('dalam satuan kg', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    'Rp. $price',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Row(
                    children: const [
                      Icon(Icons.add_circle_outline, size: 20),
                      SizedBox(width: 4),
                      Text("0"),
                      SizedBox(width: 12),
                      Icon(Icons.favorite_border, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DetailTokoScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Toko Laudya & Nilam",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
    );
  }
}
