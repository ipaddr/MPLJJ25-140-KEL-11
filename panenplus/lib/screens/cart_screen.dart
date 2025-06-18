// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'payment_screen.dart'; // Pastikan Anda mengimpor payment_screen.dart

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Untuk sementara, gunakan data keranjang manual dengan kuantitas awal yang lebih dari 0
  // Nantinya, data ini akan berasal dari state management atau Firestore.
  List<Map<String, dynamic>> cartItems = [
    {
      'id': 'prod001',
      'name': 'Beras',
      'qty': 1,
      'price': 20000.0,
      'image': 'assets/beras.png',
    },
    {
      'id': 'prod002',
      'name': 'Wortel',
      'qty': 1,
      'price': 10000.0,
      'image': 'assets/wortel.png',
    },
    {
      'id': 'prod003',
      'name': 'Kentang',
      'qty': 1,
      'price': 25000.0,
      'image': 'assets/kentang.png',
    },
    {
      'id': 'prod004',
      'name': 'Jagung',
      'qty': 1,
      'price': 17000.0,
      'image': 'assets/jagung.png',
    },
    {
      'id': 'prod005',
      'name': 'Sayur Pakcoy',
      'qty': 1,
      'price': 15000.0,
      'image': 'assets/pakcoy.png',
    },
    {
      'id': 'prod006',
      'name': 'Tomat',
      'qty': 1,
      'price': 18000.0,
      'image': 'assets/tomat.png',
    },
  ];

  // Data dummy untuk alamat dan pengguna
  String _customerName = 'Laudya&Nilam';
  String _customerPhone = '(+62)85257646687';
  String _customerAddress =
      'Unp Air Tawar Barat,Padang Utara, KOTA PADANG SUMATRA BARAT ID 25675';

  num _calculateTotal() {
    return cartItems
        .where((item) => item['qty'] > 0)
        .fold(0, (sum, item) => sum + (item['qty'] * item['price']));
  }

  void _updateQuantity(String productId, int delta) {
    setState(() {
      int index = cartItems.indexWhere((item) => item['id'] == productId);
      if (index != -1) {
        int newQty = cartItems[index]['qty'] + delta;
        if (newQty > 0) {
          cartItems[index]['qty'] = newQty;
        } else {
          // Jika kuantitas menjadi 0 atau kurang, hapus item dari daftar
          cartItems.removeAt(index);
          // Alternatif: set qty ke 0 agar item tetap ada tapi tidak dihitung
          // cartItems[index]['qty'] = 0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> displayedItems =
        cartItems.where((item) => item['qty'] > 0).toList();
    final num grandTotal = _calculateTotal();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0), // Tinggi custom AppBar
        child: Container(
          color: const Color(0xFFC7D9C7), // Warna AppBar dari desain
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
                  // Tombol back
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
                          color: Colors.amber, // Warna oranye untuk "Plus"
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
                    // TODO: Navigasi ke halaman notifikasi
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
      body: Column(
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
                    // TODO: Implementasi edit alamat
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
                    style: TextStyle(
                      color: Color.fromARGB(255, 111, 111, 111),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0, thickness: 1, indent: 16, endIndent: 16),

          // Daftar Produk di Keranjang
          Expanded(
            child:
                displayedItems.isEmpty
                    ? const Center(child: Text('Keranjang Anda kosong.'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: displayedItems.length,
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];
                        return _CartItemCard(
                          name: item['name']!,
                          image: item['image']!,
                          price: item['price']!,
                          qty: item['qty']!,
                          onAdd: () => _updateQuantity(item['id']!, 1),
                          onRemove: () => _updateQuantity(item['id']!, -1),
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
                  offset: const Offset(0, -3), // Bayangan ke atas
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: Rp ${grandTotal.toStringAsFixed(0)}', // Total Harga
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
                    // NAVIGASI KE HALAMAN PEMBAYARAN DAN TERUSKAN DATA KERANJANG
                    Navigator.pushNamed(
                      context,
                      '/payment', // Rute ke PaymentScreen (pemilihan metode pembayaran)
                      arguments: {
                        'orderedItems': displayedItems,
                        'totalPrice': grandTotal,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF6B8E23,
                    ), // Warna hijau gelap
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buat Pesanan', // Teks tombol "Buat Pesanan" sesuai Pesanan.png
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            0, // Anda perlu mengelola selectedIndex dari MainNavigation
        selectedItemColor: Colors.green, // Warna hijau tema
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          // Navigasi ke MainNavigation dan ganti tab
          if (index == 0) {
            // Home
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/main', (route) => false);
          } else if (index == 1) {
            // Pesan
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/main', (route) => false);
            // Jika ingin langsung ke tab pesan, Anda butuh cara untuk mengatur selectedIndex di MainNavigation
            // Contoh: Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false, arguments: {'initialIndex': 1});
          } else if (index == 2) {
            // Akun
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/main', (route) => false);
            // Contoh: Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false, arguments: {'initialIndex': 2});
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Pesan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

// Widget untuk setiap item di keranjang
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
      elevation: 0, // Tidak ada bayangan Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200), // Border tipis
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Detail Produk
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
                    'Rp ${price.toStringAsFixed(0)}', // Format harga
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Kuantitas dan Tombol +/-
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tombol "..." (opsional, seperti di mockup)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(), // Hapus batasan default
                    icon: const Icon(
                      Icons.menu,
                      size: 20,
                      color: Colors.grey,
                    ), // Menggunakan ikon menu sesuai gambar
                    onPressed: () {
                      // TODO: Opsi lainnya, seperti hapus item
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opsi lainnya untuk ${name}')),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 8,
                ), // Jarak antara ikon menu dan kuantitas
                Row(
                  mainAxisSize:
                      MainAxisSize.min, // Agar Row hanya selebar isinya
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.green,
                      ), // Tombol '+'
                      onPressed: onAdd,
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
                        Icons.remove,
                        size: 20,
                        color: Colors.green,
                      ), // Tombol '-'
                      onPressed: onRemove,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${(price * qty).toStringAsFixed(0)}', // Total per item
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
