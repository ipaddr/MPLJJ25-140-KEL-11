import 'package:flutter/material.dart';

class UnggahProdukScreen extends StatefulWidget {
  const UnggahProdukScreen({super.key});

  @override
  State<UnggahProdukScreen> createState() => _UnggahProdukScreenState();
}

class _UnggahProdukScreenState extends State<UnggahProdukScreen> {
  List<ProductItem> products = [
    ProductItem(name: "Sayur pakcoy", price: 15000, stock: 4),
    ProductItem(name: "Beras", price: 25000, stock: 0),
    ProductItem(name: "Jagung", price: 17000, stock: 0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Etalase Toko'),
        backgroundColor: const Color(0xffC5DDBF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xffC5DDBF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            width: double.infinity,
            child: Row(
              children: const [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 28,
                  color: Colors.black,
                ),
                SizedBox(width: 10),
                Text(
                  "Upload Produk ke PanenPlus",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Spacer(),
                Icon(Icons.add_circle_outline, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onStockChanged: (newStock) {
                    setState(() {
                      product.stock = newStock;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xff556B2F),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.mail), label: "Pesan"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}

class ProductItem {
  String name;
  int price;
  int stock;
  ProductItem({required this.name, required this.price, required this.stock});
}

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final Function(int) onStockChanged;

  const ProductCard({
    super.key,
    required this.product,
    required this.onStockChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                "unggah\ngambar +",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("dalam satuan kg", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        "ajukan harga",
                        style: TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      DropdownButton<int>(
                        value: product.price,
                        items: const [
                          DropdownMenuItem(
                            value: 15000,
                            child: Text("Rp. 15,000"),
                          ),
                          DropdownMenuItem(
                            value: 17000,
                            child: Text("Rp. 17,000"),
                          ),
                          DropdownMenuItem(
                            value: 25000,
                            child: Text("Rp. 25,000"),
                          ),
                        ],
                        onChanged: (_) {},
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "stock tersedia",
                        style: TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          if (product.stock > 0) {
                            onStockChanged(product.stock - 1);
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Color(0xff556B2F),
                        ),
                      ),
                      Text(product.stock.toString()),
                      IconButton(
                        onPressed: () {
                          onStockChanged(product.stock + 1);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xff556B2F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }
}
