// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Tambahkan const constructor

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController(); // Menggunakan email, bukan username
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // Untuk indikator loading

  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Set loading true saat proses dimulai
    });

    try {
      // Login dengan email dan password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:
            emailController.text
                .trim(), // Gunakan .trim() untuk menghilangkan spasi kosong
        password: passwordController.text.trim(),
      );

      // Jika berhasil, navigasi ke halaman utama
      if (mounted) {
        // Pastikan widget masih mounted sebelum navigasi
        Navigator.pushReplacementNamed(context, '/main');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Tidak ada pengguna yang ditemukan untuk email tersebut.';
      } else if (e.code == 'wrong-password') {
        message = 'Kata sandi salah untuk email tersebut.';
      } else if (e.code == 'invalid-email') {
        message = 'Format email tidak valid.';
      } else {
        message = 'Terjadi kesalahan: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan tak terduga: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false; // Set loading false setelah proses selesai
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7D9C7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 110),

              const SizedBox(height: 16),
              // Menggunakan asset/logo.png yang Anda gunakan
              Image.asset(
                'assets/logo.png',
                height: 180,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.grass, size: 120, color: Colors.white),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController, // Gunakan emailController
                keyboardType:
                    TextInputType.emailAddress, // Keyboard untuk email
                decoration: const InputDecoration(
                  hintText: 'Email Anda', // Ubah hintText menjadi Email
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Kata Sandi',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  // Mengubah Text menjadi TextButton agar interaktif
                  onPressed: () {
                    // TODO: Implementasi lupa kata sandi
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fitur "Lupa kata sandi?" belum diimplementasikan.',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Lupa kata sandi?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator() // Tampilkan loading saat proses
                  : ElevatedButton(
                    onPressed: _login, // Panggil fungsi _login
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8E23),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ), // Tambahkan warna teks putih
                    ),
                  ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Daftar',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 228, 177),
                      ),
                    ), // Perbaiki warna teks Daftar
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tombol Google dan Facebook akan memerlukan integrasi Firebase yang lebih lanjut
              // seperti `google_sign_in` dan `flutter_facebook_auth`
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Login dengan Google belum diimplementasikan.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.g_mobiledata,
                  size: 32,
                  color: Colors.blueAccent,
                ), // Warna ikon Google
                label: const Text('Masuk dengan Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Login dengan Facebook belum diimplementasikan.',
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.facebook,
                  size: 32,
                  color: Colors.blue,
                ), // Warna ikon Facebook
                label: const Text('Masuk dengan Facebook'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
