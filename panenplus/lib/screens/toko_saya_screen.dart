// lib/screens/toko_saya_screen.dart
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
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
  }

  Future<void> _fetchStoreData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestoreService.getUserData(
          currentUser.uid,
        );
        if (userDoc.exists && mounted) {
          final userData = userDoc.data() as Map<String, dynamic>;
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

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Toko Saya'),
        centerTitle: true,
      ),
      body:
          currentUser == null
              ? const Center(
                child: Text('Silakan login untuk melihat toko Anda.'),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoreHeader(),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestoreService.getOrdersForSeller(
                        currentUser.uid,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
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

                        final orders = snapshot.data?.docs ?? [];

                        final perluDikirimCount =
                            orders
                                .where(
                                  (doc) =>
                                      (doc.data()
                                          as Map<String, dynamic>)['status'] ==
                                      'Perlu Dikirim',
                                )
                                .length;
                        final dikirimCount =
                            orders
                                .where(
                                  (doc) =>
                                      (doc.data()
                                          as Map<String, dynamic>)['status'] ==
                                      'Dikirim',
                                )
                                .length;
                        final selesaiCount =
                            orders
                                .where(
                                  (doc) =>
                                      (doc.data()
                                          as Map<String, dynamic>)['status'] ==
                                      'Selesai',
                                )
                                .length;
                        final dibatalkanCount =
                            orders
                                .where(
                                  (doc) =>
                                      (doc.data()
                                          as Map<String, dynamic>)['status'] ==
                                      'Dibatalkan',
                                )
                                .length;

                        num totalRevenue = 0;
                        for (var orderDoc in orders) {
                          final orderData =
                              orderDoc.data() as Map<String, dynamic>;
                          final status = orderData['status'] ?? '';
                          if (status != 'Dibatalkan') {
                            List<dynamic> items = orderData['items'] ?? [];
                            for (var item in items) {
                              if (item['sellerId'] == currentUser.uid) {
                                totalRevenue +=
                                    (item['price'] * item['qty']) ?? 0;
                              }
                            }
                          }
                        }

                        return Column(
                          children: [
                            _buildOrderStatusGrid(
                              perluDikirim: perluDikirimCount,
                              dikirim: dikirimCount,
                              selesai: selesaiCount,
                              dibatalkan: dibatalkanCount,
                            ),
                            const SizedBox(height: 8),
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

  Widget _buildStoreHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.green.shade100,
            backgroundImage:
                _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
            child:
                _profileImageUrl.isEmpty
                    ? Icon(Icons.storefront, size: 30, color: Colors.green[800])
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _storeName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _storeDescription,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusGrid({
    required int perluDikirim,
    required int dikirim,
    required int selesai,
    required int dibatalkan,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Pesanan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _buildStatusCard(
                icon: Icons.outbox_outlined,
                count: perluDikirim,
                label: 'Perlu Dikirim',
              ),
              _buildStatusCard(
                icon: Icons.local_shipping_outlined,
                count: dikirim,
                label: 'Dikirim',
              ),
              _buildStatusCard(
                icon: Icons.check_circle_outline,
                count: selesai,
                label: 'Selesai',
              ),
              _buildStatusCard(
                icon: Icons.cancel_outlined,
                count: dibatalkan,
                label: 'Dibatalkan',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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
            'Daftar Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          if (orders.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text('Belum ada pesanan.'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderDoc = orders[index];
                final orderData = orderDoc.data() as Map<String, dynamic>;
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
                  orderId: orderDoc.id,
                  orderData: orderData,
                  sellerItems: sellerItems,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStoreShowcase(User? currentUser, num totalRevenue) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Etalase Toko',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                              arguments: {/* ... argumen ... */},
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String orderId;
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> sellerItems;

  const _OrderCard({
    required this.orderId,
    required this.orderData,
    required this.sellerItems,
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final double revenueFromThisOrder = sellerItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['qty']),
    );
    final timestamp = orderData['createdAt'] as Timestamp?;
    final date = timestamp?.toDate();
    final formattedDate =
        date != null ? '${date.day}/${date.month}/${date.year}' : 'N/A';
    final currentStatus = orderData['status'] ?? 'N/A';

    Color statusColor;
    switch (currentStatus) {
      case 'Dikirim':
        statusColor = Colors.blue.shade700;
        break;
      case 'Selesai':
        statusColor = Colors.green.shade700;
        break;
      case 'Dibatalkan':
        statusColor = Colors.red.shade700;
        break;
      default:
        statusColor = Colors.orange.shade800;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pesanan dari: ${orderData['buyerName']}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 24),
            ...sellerItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Text('• ${item['qty']}x ${item['name']}'),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Pendapatan: Rp ${revenueFromThisOrder.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  "Ubah Status: ",
                  style: TextStyle(color: Colors.grey),
                ),
                PopupMenuButton<String>(
                  onSelected: (String newStatus) {
                    firestoreService.updateOrderStatus(orderId, newStatus).then((
                      _,
                    ) {
                      // Kirim notifikasi ke pembeli
                      final buyerId = orderData['buyerId'];
                      if (buyerId != null) {
                        firestoreService.addNotification(buyerId, {
                          'title': 'Status Pesanan Diperbarui',
                          'body':
                              'Pesanan Anda #${orderId.substring(0, 8)} sekarang berstatus: $newStatus',
                          'isRead': false,
                          'timestamp': FieldValue.serverTimestamp(),
                          'type': 'order',
                          'referenceId': orderId,
                        });
                      }
                    });
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Diproses',
                          child: Text('Diproses'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Dikirim',
                          child: Text('Dikirim'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Selesai',
                          child: Text('Selesai'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Dibatalkan',
                          child: Text('Dibatalkan'),
                        ),
                      ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          currentStatus,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          color: statusColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
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
