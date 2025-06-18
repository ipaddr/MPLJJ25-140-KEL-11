import 'package:flutter/material.dart';
import 'pembayaran_page.dart';
import 'pesan_page.dart';
import 'akun_page.dart';

class TransaksiSuksesPage extends StatelessWidget {
  const TransaksiSuksesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Color(0xFFCDE2C4),
          elevation: 2,
          automaticallyImplyLeading: false,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 10),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Panen',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'Plus',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Icon(Icons.notifications_none, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Transaksi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 24),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDDEAD5),
              ),
              child: Icon(Icons.check, size: 100, color: Colors.green[700]),
            ),
          ),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Pesananmu sudah diterima. Kami sudah menyelesaikan pesananmu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              // Contoh logika lihat pesanan (kosongkan jika belum tersedia)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey,
              side: BorderSide(color: Colors.grey),
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text('Lihat Pesanan'),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Contoh logika pesan lainnya (kosongkan jika belum tersedia)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFCDE2C4),
              foregroundColor: Colors.white,
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text('Pesan Lainnya'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Pesan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
        onTap: (index) {
          Widget targetPage;

          switch (index) {
            case 0:
              targetPage = PembayaranPage();
              break;
            case 1:
              targetPage = PesanPage();
              break;
            case 2:
              targetPage = AkunPage();
              break;
            default:
              return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          );
        },
      ),
    );
  }
}
