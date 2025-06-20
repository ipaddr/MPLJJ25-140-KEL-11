import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';

class TokoSayaScreen extends StatefulWidget {
  const TokoSayaScreen({super.key});

  @override
  State<TokoSayaScreen> createState() => _TokoSayaScreenState();
}

class _TokoSayaScreenState extends State<TokoSayaScreen> {
  String _storeName = 'Loading...';
  String _storeDescription = 'Loading...';
  String _profileImageUrl = '';
  // Variabel _totalRevenue tidak lagi di-fetch di initState, tapi bisa di-update dari stream jika perlu
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    // Kita tidak perlu lagi memanggil _fetchTotalRevenue di sini karena bisa didapat dari stream
  }

  Future<void> _fetchStoreData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestoreService.getUserData(
          currentUser.uid,
        );
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _storeName =
                  userData['username'] ??
                  currentUser.displayName ??
                  'Nama Toko Anda';
              _storeDescription =
                  userData['storeDescription'] ?? 'Penjual Produk Pertanian';
              _profileImageUrl = userData['profileImageUrl'] ?? '';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal memuat data toko: $e')));
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _storeName = 'Toko Tamu';
          _storeDescription = 'Login untuk melihat toko Anda';
        });
      }
    }
  }

  Widget _buildStatusItem(String count, String label) {
    return Expanded(
      child: Column(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFC7D9C7),
        title: const Text('Toko Saya', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Toko
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.green.shade100,
                        backgroundImage:
                            _profileImageUrl.isNotEmpty
                                ? NetworkImage(_profileImageUrl)
                                    as ImageProvider
                                : null,
                        child:
                            _profileImageUrl.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.green[800],
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _storeName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _storeDescription,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // *** REFAKTOR DIMULAI DI SINI: StreamBuilder utama ***
            StreamBuilder<QuerySnapshot>(
              stream:
                  currentUser != null
                      ? _firestoreService.getOrdersForSeller(currentUser.uid)
                      : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  );
                }

                // Jika tidak ada data atau stream null
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: [
                      _buildStatusSection(0), // Tampilkan status dengan count 0
                      _buildIncomingOrders(
                        currentUser,
                        const [],
                      ), // Tampilkan list pesanan kosong
                      const SizedBox(height: 8),
                      _buildStoreShowcase(
                        currentUser,
                        0,
                      ), // Tampilkan etalase dengan revenue 0
                    ],
                  );
                }

                // Jika ada data, proses di sini
                final orders = snapshot.data!.docs;

                // Hitung status "Perlu Dikirim"
                final perluDikirimCount =
                    orders.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['status'] == 'Perlu Dikirim';
                    }).length;

                // Hitung total revenue dari semua pesanan yang ada
                num totalRevenue = 0;
                for (var orderDoc in orders) {
                  final orderData = orderDoc.data() as Map<String, dynamic>;
                  List<dynamic> items = orderData['items'] ?? [];
                  for (var item in items) {
                    if (item['sellerId'] == currentUser!.uid) {
                      totalRevenue += (item['price'] * item['qty']) ?? 0;
                    }
                  }
                }

                // Kembalikan UI dengan data yang sudah diproses
                return Column(
                  children: [
                    _buildStatusSection(perluDikirimCount),
                    _buildIncomingOrders(currentUser, orders),
                    const SizedBox(height: 8),
                    _buildStoreShowcase(currentUser, totalRevenue),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget baru untuk bagian Status Pesanan
  Widget _buildStatusSection(int perluDikirimCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color.fromARGB(255, 224, 224, 224)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            perluDikirimCount.toString(),
            'Perlu dikirim',
          ), // Data dinamis
          _buildStatusItem('0', 'Pembatalan'),
          _buildStatusItem('0', 'Pengembalian'),
          _buildStatusItem('0', 'Penilaian\nPerlu Dibalas'),
        ],
      ),
    );
  }

  // Widget untuk Pesanan Masuk (sekarang menerima List<DocumentSnapshot>)
  Widget _buildIncomingOrders(
    User? currentUser,
    List<DocumentSnapshot> orders,
  ) {
    if (currentUser == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pesanan Masuk',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          if (orders.isEmpty)
            const Center(child: Text('Belum ada pesanan yang masuk.'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderData = orders[index].data() as Map<String, dynamic>;
                final itemsInOrder =
                    (orderData['items'] as List)
                        .map((item) => item as Map<String, dynamic>)
                        .toList();
                final sellerItems =
                    itemsInOrder
                        .where((item) => item['sellerId'] == currentUser.uid)
                        .toList();

                if (sellerItems.isEmpty) return const SizedBox.shrink();

                return _OrderCard(
                  orderData: orderData,
                  sellerItems: sellerItems,
                );
              },
            ),
        ],
      ),
    );
  }

  // Widget untuk Etalase Toko (sekarang menerima totalRevenue)
  Widget _buildStoreShowcase(User? currentUser, num totalRevenue) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Etalase Toko',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream:
                currentUser != null
                    ? _firestoreService.getProductsBySeller(currentUser.uid)
                    : null,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Belum ada produk di etalase Anda.'),
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children:
                    snapshot.data!.docs.map((document) {
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String productId = document.id;

                      return _ProductItem(
                        productId: productId,
                        name: data['productName'] ?? 'Nama Produk',
                        price: 'Rp ${data['price']?.toStringAsFixed(0) ?? '0'}',
                        stock: (data['stock'] ?? 0).toString(),
                        image:
                            data['imageUrl'] ??
                            'assets/images/product_placeholder.png',
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              '/detail_toko',
                              arguments: {
                                'productId': productId,
                                'productName': data['productName'],
                                'price': data['price']?.toStringAsFixed(0),
                                'imageUrl': data['imageUrl'],
                                'description': data['description'],
                                'storeName': _storeName,
                                'stock': data['stock']?.toString() ?? '0',
                              },
                            ),
                        onEdit:
                            () => Navigator.pushNamed(
                              context,
                              '/upload',
                              arguments: {'productId': productId},
                            ),
                        onDelete: () async {
                          await _firestoreService.deleteProduct(productId);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${data['productName']} berhasil dihapus',
                                ),
                              ),
                            );
                        },
                      );
                    }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/upload'),
              icon: const Icon(Icons.add),
              label: const Text("Tambah Produk Baru"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Pemasukan\nRp${totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF466147),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// _ProductItem dan _OrderCard tetap sama, tidak perlu diubah.
// (Salin dari kode sebelumnya)

class _ProductItem extends StatelessWidget {
  // ... (isi class _ProductItem tetap sama)
  final String productId;
  final String name;
  final String price;
  final String stock;
  final String image;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    required this.image,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerPadding = 16.0 * 2;
    double spacing = 12.0 * 2;
    double itemWidth = (screenWidth - containerPadding - spacing) / 3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: itemWidth,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  image.startsWith('http')
                      ? Image.network(
                        image,
                        height: 60,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: _imageErrorBuilder,
                      )
                      : Image.asset(
                        image,
                        height: 60,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: _imageErrorBuilder,
                      ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              price,
              style: const TextStyle(color: Colors.black87, fontSize: 11),
            ),
            Text(
              'Stok: $stock',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit, size: 20, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete, size: 20, color: Colors.red),
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
      height: 60,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 30, color: Colors.grey),
    );
  }
}

class _OrderCard extends StatelessWidget {
  // ... (isi class _OrderCard tetap sama)
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> sellerItems;

  const _OrderCard({required this.orderData, required this.sellerItems});

  @override
  Widget build(BuildContext context) {
    final double revenueFromThisOrder = sellerItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['qty']),
    );
    final timestamp = orderData['createdAt'] as Timestamp?;
    final date = timestamp?.toDate();
    final formattedDate =
        date != null ? '${date.day}/${date.month}/${date.year}' : 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Pesanan dari: ${orderData['buyerName']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(),
            ...sellerItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('• ${item['qty']}x ${item['name']}'),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Pendapatan: Rp ${revenueFromThisOrder.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed:
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur ubah status pesanan belum diimplementasikan.',
                        ),
                      ),
                    ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange.shade700),
                  foregroundColor: Colors.orange.shade700,
                ),
                child: Text('Status: ${orderData['status']}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
