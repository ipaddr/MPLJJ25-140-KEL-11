// lib/screens/transaction_success_screen.dart
import 'package:flutter/material.dart';

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 80,
              backgroundColor: Color(0xFFC7D9C7), // Warna hijau tema
              child: Icon(Icons.check, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 30),
            const Text(
              'Transaksi Berhasil!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC7D9C7), // Warna hijau tema
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Terima kasih atas pembelian Anda.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Pop semua rute yang ada di tumpukan sampai ke rute MainNavigation
                // Ini akan membawa pengguna langsung ke dashboard dan membersihkan riwayat navigasi
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/main',
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7D9C7), // Warna hijau tema
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
