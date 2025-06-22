// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import semua screen Anda
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/akun_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/detail_toko_screen.dart';
import 'screens/add_to_cart_screen.dart';
import 'screens/upload_product_screen.dart';
import 'screens/toko_saya_screen.dart';
import 'screens/transaction_success_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/chat_list_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PanenPlusApp());
}

class PanenPlusApp extends StatelessWidget {
  const PanenPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PanenPlus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          // --- Rute Tanpa Argumen ---
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/main':
            return MaterialPageRoute(builder: (_) => const MainNavigation());
          case '/toko_saya':
            return MaterialPageRoute(builder: (_) => const TokoSayaScreen());
          case '/cart':
            return MaterialPageRoute(builder: (_) => const CartScreen());
          case '/chat_list':
            return MaterialPageRoute(builder: (_) => const ChatListScreen());
          case '/detail_toko':
            return MaterialPageRoute(builder: (_) => const DetailTokoScreen());
          case '/transaction_success':
            return MaterialPageRoute(
              builder: (_) => const TransactionSuccessScreen(),
            );
          case '/order_history':
            return MaterialPageRoute(
              builder: (_) => const OrderHistoryScreen(),
            );
          case '/notifications':
            return MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            );

          // --- Rute yang Membutuhkan Argumen/Data ---
          case '/payment':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => PaymentScreen(paymentData: args),
            );

          case '/add_to_cart':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AddToCartScreen(productData: args),
            );

          case '/upload':
            final args = settings.arguments as Map<String, dynamic>?;
            final productId = args?['productId'];
            return MaterialPageRoute(
              builder: (_) => UploadProductScreen(productId: productId),
            );

          default:
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(child: Text('Halaman tidak ditemukan')),
                  ),
            );
        }
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const AkunPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}
