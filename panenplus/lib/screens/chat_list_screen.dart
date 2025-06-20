// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/screens/chat_screen.dart';
import 'package:panenplus/services/firestore_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Pesan")),
        body: const Center(child: Text("Silakan login untuk melihat pesan.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan"),
        backgroundColor: const Color(0xFFCDE2C4),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getUserChats(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // **TAMBAHAN: Tangani error dengan lebih baik**
            return Center(
              child: Text(
                'Gagal memuat pesan. Pastikan indeks Firestore sudah dibuat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[700]),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada pesan."));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatData = chats[index].data() as Map<String, dynamic>;
              final users = chatData['users'] as List;
              final userNames = chatData['userNames'] as Map<String, dynamic>;

              final otherUserId = users.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => '',
              );
              final otherUserName = userNames[otherUserId] ?? 'User Dihapus';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    otherUserName.isNotEmpty
                        ? otherUserName[0].toUpperCase()
                        : '?',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
                title: Text(
                  otherUserName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  chatData['lastMessage'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatScreen(
                            sellerId: otherUserId,
                            sellerName: otherUserName,
                            buyerId: currentUser.uid,
                            buyerName: currentUser.displayName ?? 'Saya',
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
