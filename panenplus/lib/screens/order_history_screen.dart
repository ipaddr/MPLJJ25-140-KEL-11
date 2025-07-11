// lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';
import 'package:intl/intl.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Dikirim':
        return Colors.blue.shade700;
      case 'Selesai':
        return Colors.green.shade700;
      case 'Dibatalkan':
        return Colors.red.shade700;
      case 'Diproses':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pesanan Saya")),
      body:
          currentUser == null
              ? const Center(
                child: Text("Silakan login untuk melihat riwayat pesanan."),
              )
              : StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getUserOrders(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Anda belum memiliki riwayat pesanan."),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final orderDoc = orders[index];
                      final order = orderDoc.data() as Map<String, dynamic>;
                      final items =
                          (order['items'] as List).cast<Map<String, dynamic>>();
                      final timestamp =
                          (order['createdAt'] as Timestamp?)?.toDate();
                      final formattedDate =
                          timestamp != null
                              ? DateFormat(
                                'd MMMM yyyy, HH:mm',
                              ).format(timestamp)
                              : 'N/A';

                      final displayStatus = order['status'] ?? 'N/A';
                      final statusColor = _getStatusColor(displayStatus);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pesanan #${orderDoc.id.substring(0, 8)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      displayStatus,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text('Tanggal: $formattedDate'),
                              Text(
                                'Total: Rp ${order['grandTotal'].toStringAsFixed(0)}',
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Item Dibeli:',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              ...items
                                  .map(
                                    (item) => Text(
                                      '• ${item['qty']}x ${item['name']}',
                                    ),
                                  )
                                  .toList(),

                              if (order['status'] == 'Dikirim') ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                    ),
                                    label: const Text("Pesanan Sudah Diterima"),
                                    onPressed: () {
                                      firestoreService
                                          .updateOrderStatus(
                                            orderDoc.id,
                                            'Selesai',
                                          )
                                          .then(
                                            (_) => ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Terima kasih telah mengonfirmasi pesanan!",
                                                ),
                                              ),
                                            ),
                                          )
                                          .catchError(
                                            (e) => ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text("Gagal: $e"),
                                              ),
                                            ),
                                          );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
