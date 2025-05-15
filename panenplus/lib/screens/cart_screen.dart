import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems = [
    {'name': 'Wortel', 'qty': 2, 'price': 5000},
    {'name': 'Jagung', 'qty': 1, 'price': 4000},
  ];

  @override
  Widget build(BuildContext context) {
    // Perbaikan: gunakan tipe num agar hasil operasi bisa int atau double
    final num total = cartItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));

    return Scaffold(
      appBar: AppBar(title: Text("Keranjang")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: cartItems.map((item) {
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text('Qty: ${item['qty']}'),
                  trailing: Text('Rp ${item['qty'] * item['price']}'),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: Rp $total', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              // Proses Pembayaran
            },
            child: Text('Bayar Sekarang'),
          )
        ],
      ),
    );
  }
}
