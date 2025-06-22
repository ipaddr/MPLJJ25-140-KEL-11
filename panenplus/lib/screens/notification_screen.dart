// lib/screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body:
          currentUser == null
              ? const Center(
                child: Text("Silakan login untuk melihat notifikasi."),
              )
              : StreamBuilder<QuerySnapshot>(
                stream: firestoreService.getUserNotifications(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada notifikasi baru."),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif =
                          notifications[index].data() as Map<String, dynamic>;
                      final bool isRead = notif['isRead'] ?? false;
                      final timestamp =
                          (notif['timestamp'] as Timestamp?)?.toDate();
                      final formattedDate =
                          timestamp != null
                              ? DateFormat('d MMM, HH:mm').format(timestamp)
                              : '';

                      return ListTile(
                        tileColor: isRead ? Colors.white : Colors.green.shade50,
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(
                            notif['type'] == 'order'
                                ? Icons.receipt_long
                                : Icons.chat_bubble,
                            color: Colors.green.shade800,
                          ),
                        ),
                        title: Text(
                          notif['title'] ?? '',
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notif['body'] ?? ''),
                        trailing: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () {
                          // Tandai sudah dibaca
                          firestoreService.markNotificationAsRead(
                            currentUser.uid,
                            notifications[index].id,
                          );

                          // Navigasi jika ada referenceId
                          final String? referenceId = notif['referenceId'];
                          if (referenceId != null) {
                            // TODO: Buat logika navigasi ke detail pesanan atau chat
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Akan navigasi ke item: $referenceId",
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
