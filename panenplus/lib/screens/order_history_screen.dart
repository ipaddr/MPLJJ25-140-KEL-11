// lib/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';
import 'package:intl/intl.dart'; // Paket untuk format tanggal

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

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
                      child: Text("Anda belum memiliki pesanan."),
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
                      final order =
                          orders[index].data() as Map<String, dynamic>;
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
                                    'Pesanan #${orders[index].id.substring(0, 8)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      order['status'] ?? 'N/A',
                                      style: TextStyle(
                                        color: Colors.green.shade800,
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
                              const SizedBox(height: 8),
                              Text('Item:'),
                              ...items
                                  .map(
                                    (item) => Text(
                                      '• ${item['qty']}x ${item['name']}',
                                    ),
                                  )
                                  .toList(),
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
