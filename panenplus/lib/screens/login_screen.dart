import 'package:flutter/material.dart';
import '../main.dart'; // agar bisa akses MainNavigation

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffd2e3c8),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Username atau Nomor Telepon',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke dashboard setelah login
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavigation()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
