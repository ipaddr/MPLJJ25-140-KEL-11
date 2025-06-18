import 'package:flutter/material.dart';

class PembayaranPage extends StatelessWidget {
  const PembayaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    int total = 3 * 20000 + 1 * 10000 + 2 * 25000;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Header PanenPlus
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFCFE3C3),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Panen',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      TextSpan(
                          text: 'Plus',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),

          // Tab Bisnis - Mart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text("Bisnis", style: TextStyle(fontSize: 16)),
              Text("Mart",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ],
          ),
          const SizedBox(height: 8),

          // Alamat Pengiriman
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text("Laudya&Nilam (+62)85257646687"),
            subtitle: const Text(
                "Unp Air Tawar Barat, Padang Utara, KOTA PADANG\nSUMATRA BARAT\nID 25675"),
          ),

          const Divider(),

          // Daftar Produk
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildProductItem("Beras", "Rp. 20,000", "assets/beras.jpg", 3),
                _buildProductItem("Wortel", "Rp. 10,000", "assets/wortel.jpg", 1),
                _buildProductItem("Kentang", "Rp. 25,000", "assets/kentang.jpg", 2),
              ],
            ),
          ),

          // Total dan Tombol Pembayaran
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Total: Rp. $total",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // ✅ Navigasi ke halaman transaksi sukses
                    Navigator.pushNamed(context, '/transaksi');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF586A39),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 14),
                  ),
                  child:
                      const Text("Pembayaran", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(
      String title, String price, String imagePath, int quantity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const Text("dalam satuan kg"),
                const SizedBox(height: 4),
                Text(price),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(quantity.toString()),
                    const SizedBox(width: 8),
                    const Icon(Icons.remove_circle, color: Colors.grey),
                  ],
                )
              ],
            ),
          ),
          const Icon(Icons.menu),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
