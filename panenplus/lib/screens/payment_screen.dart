// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
// Jika Anda menggunakan data keranjang dari Firestore atau state management, import di sini:
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:provider/provider.dart'; // Jika menggunakan Provider untuk CartState
import 'transaction_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  List<Map<String, dynamic>> _receivedOrderedItems =
      []; // Untuk menyimpan item yang diterima
  num _receivedTotalPrice = 0; // Untuk menyimpan total harga yang diterima

  // Data dummy untuk alamat, jika tidak diambil dari user profile
  String _customerName = 'Laudya&Nilam';
  String _customerPhone = '(+62)85257646687';
  String _customerAddress =
      'Unp Air Tawar Barat,Padang Utara, KOTA PADANG SUMATRA BARAT ID 25675';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil argumen yang diteruskan dari CartScreen
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      // Pastikan untuk mengcast ke tipe yang benar
      _receivedOrderedItems = List<Map<String, dynamic>>.from(
        args['orderedItems'] as List,
      );
      _receivedTotalPrice = args['totalPrice'] as num;
    }
  }

  // Subtotal adalah total harga yang diterima dari CartScreen
  num _calculateSubtotal() {
    return _receivedTotalPrice;
  }

  // Contoh biaya pengiriman (bisa disesuaikan)
  num _calculateShippingCost() {
    return 15000; // Biaya pengiriman tetap
  }

  num _calculateGrandTotal() {
    return _calculateSubtotal() + _calculateShippingCost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'), // Judul sesuai desain
        backgroundColor: const Color(0xFFC7D9C7), // Warna AppBar yang konsisten
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
            // Bagian Alamat Pengiriman (sama seperti di CartScreen)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // Padding bawah
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
            const Divider(
              height: 0,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ), // Divider penuh

            const SizedBox(height: 16), // Jarak setelah divider
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Kartu Ringkasan Pesanan dengan Daftar Item
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Daftar Item yang Dipesan
                    ListView.builder(
                      shrinkWrap: true, // Penting agar ListView di dalam Column
                      physics:
                          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll ListView
                      itemCount: _receivedOrderedItems.length,
                      itemBuilder: (context, index) {
                        final item = _receivedOrderedItems[index];
                        return _PaymentOrderedItemCard(
                          name: item['name']!,
                          image: item['image']!,
                          price: item['price']!,
                          qty: item['qty']!,
                        );
                      },
                    ),
                    const Divider(
                      height: 20,
                      thickness: 1,
                    ), // Divider setelah item
                    _buildSummaryRow(
                      'Subtotal',
                      'Rp ${_calculateSubtotal().toStringAsFixed(0)}',
                    ),
                    _buildSummaryRow(
                      'Biaya Pengiriman',
                      'Rp ${_calculateShippingCost().toStringAsFixed(0)}',
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Total Pembayaran',
                      'Rp ${_calculateGrandTotal().toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bagian Pilih Metode Pembayaran
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Transfer Bank'),
                    value: 'bank_transfer',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('COD'),
                    value: 'cod',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Dana'),
                    value: 'dana',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Kartu Kredit/Debit'),
                    value: 'credit_card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedPaymentMethod == null
                        ? null // Disable button if no method selected
                        : () {
                          // TODO: Implementasi proses pembayaran nyata
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Memproses pembayaran dengan: $_selectedPaymentMethod',
                              ),
                            ),
                          );
                          // NAVIGASI KE HALAMAN TRANSAKSI BERHASIL
                          Navigator.pushNamed(context, '/transaction_success');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Memproses pembayaran dengan: $_selectedPaymentMethod',
                              ),
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Warna hijau tema
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk baris ringkasan (Subtotal, Biaya Pengiriman, Total)
  Widget _buildSummaryRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget baru untuk menampilkan item di Ringkasan Pesanan pada PaymentScreen
class _PaymentOrderedItemCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final int qty;

  const _PaymentOrderedItemCard({
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(
              image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.image,
                      size: 25,
                      color: Colors.grey,
                    ),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${qty} x Rp ${price.toStringAsFixed(0)}', // Misal: 3 x Rp 20.000
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${(price * qty).toStringAsFixed(0)}', // Total per item
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
