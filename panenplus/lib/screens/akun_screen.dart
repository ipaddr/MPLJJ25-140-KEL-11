// lib/screens/akun_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  State<AkunPage> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunPage> {
  String _username = 'Loading...';
  String _profileImageUrl = '';
  String _storeDescription = 'Pengguna PanenPlus';
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _username = 'Tamu';
          _storeDescription = 'Silakan login';
        });
      }
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestoreService.getUserData(
        currentUser.uid,
      );
      if (userDoc.exists && mounted) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _username =
              userData['username'] ??
              currentUser.displayName ??
              'Pengguna PanenPlus';
          _profileImageUrl = userData['profileImageUrl'] ?? '';
          _storeDescription =
              userData['storeDescription'] ?? 'Pengguna Aplikasi';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data profil: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Akun Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- KARTU PROFIL PENGGUNA ---
          _buildProfileCard(),
          const SizedBox(height: 16),

          // --- MENU AKTIVITAS SAYA ---
          const Text(
            "Aktivitas Saya",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _buildActivityMenu(),

          // --- MENU PENGATURAN & BANTUAN ---
          const SizedBox(height: 16),
          const Text(
            "Pengaturan & Bantuan",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsMenu(),

          const SizedBox(height: 24),

          // --- TOMBOL LOGOUT ---
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.green.shade100,
            backgroundImage:
                _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl)
                    : null,
            child:
                _profileImageUrl.isEmpty
                    ? Icon(Icons.person, size: 32, color: Colors.green[800])
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _storeDescription,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Arahkan ke halaman edit profil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Halaman Ubah Profil belum dibuat."),
                ),
              );
            },
            icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityMenu() {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.receipt_long_outlined,
              color: Colors.blue.shade700,
            ),
            title: const Text("Riwayat Pesanan Saya"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/order_history');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(
              Icons.storefront_outlined,
              color: Color(0xFFF57C00),
            ),
            title: const Text("Toko Saya"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/toko_saya');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu() {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.chat_bubble_outline,
              color: Colors.green.shade700,
            ),
            title: const Text("Pesan Masuk"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/chat_list');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(
              Icons.notifications_none,
              color: Colors.purple.shade400,
            ),
            title: const Text("Notifikasi"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.grey.shade600),
            title: const Text("Pusat Bantuan"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Halaman Pusat Bantuan belum dibuat."),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Logout'),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
