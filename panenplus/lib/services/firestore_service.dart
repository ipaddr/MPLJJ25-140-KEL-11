// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Untuk Firebase Storage
import 'dart:io'; // Untuk tipe File dari image_picker
import 'dart:typed_data'; // Tambahkan ini untuk Uint8List

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Inisialisasi Firebase Storage

  // Mendapatkan ID pengguna saat ini
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // --- Operasi Pengguna (Users) ---

  // Menyimpan data pengguna baru setelah registrasi
  Future<void> saveNewUser(
    String uid,
    String username,
    String email,
    String phone,
  ) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'createdAt': Timestamp.now(),
      'storeDescription': 'Pengguna PanenPlus', // Deskripsi default
      'profileImageUrl': '', // URL gambar profil default kosong
      'address': '',
      'city': '',
      'postalCode': '',
      // Anda bisa menambahkan field default lainnya
    });
  }

  // Mendapatkan data profil pengguna berdasarkan UID
  Future<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // Memperbarui data profil pengguna
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // --- Operasi Produk (Products) ---

  // Mengunggah gambar ke Firebase Storage

  // Mengunggah gambar untuk MOBILE (menerima File)
  Future<String> uploadProductImage(File imageFile) async {
    String fileName =
        'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Mengunggah gambar untuk WEB (menerima Uint8List)
  Future<String> uploadProductImageBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    String filePath =
        'product_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    UploadTask uploadTask = _storage
        .ref()
        .child(filePath)
        .putData(imageBytes); // Menggunakan putData untuk bytes
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Menambahkan produk baru
  Future<void> addProduct({
    required String productName,
    required double price,
    required String description,
    required String imageUrl,
    required String sellerId,
    required String sellerName,
    required int stock,
  }) async {
    await _db.collection('products').add({
      'productName': productName,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'stock': stock,
      'timestamp': Timestamp.now(),
    });
  }

  // Mendapatkan semua produk (untuk Mart/Dashboard)
  Stream<QuerySnapshot> getProducts() {
    return _db.collection('products').snapshots();
  }

  // Mendapatkan produk berdasarkan sellerId (untuk Toko Saya)
  Stream<QuerySnapshot> getProductsBySeller(String sellerId) {
    return _db
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();
  }

  // Mendapatkan detail produk tunggal
  Future<DocumentSnapshot> getProductDetails(String productId) {
    return _db.collection('products').doc(productId).get();
  }

  // Memperbarui produk
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('products').doc(productId).update(data);
  }

  // Menghapus produk
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // --- Operasi Keranjang (Cart) ---

  // Menambahkan/memperbarui item di keranjang pengguna
  Future<void> updateCartItem(
    String userId,
    String productId,
    Map<String, dynamic> itemData,
  ) async {
    // Gunakan set dengan merge:true atau update. Doc ID bisa productId atau cartItemId unik
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .set(itemData, SetOptions(merge: true));
  }

  // Mendapatkan item keranjang pengguna
  Stream<QuerySnapshot> getCartItems(String userId) {
    return _db.collection('users').doc(userId).collection('cart').snapshots();
  }

  // Menghapus item dari keranjang
  Future<void> removeCartItem(String userId, String productId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Mengosongkan keranjang setelah pesanan dibuat
  Future<void> clearCart(String userId) async {
    QuerySnapshot cartSnapshot =
        await _db.collection('users').doc(userId).collection('cart').get();
    for (DocumentSnapshot doc in cartSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // --- Operasi Pesanan (Orders) ---

  // Membuat pesanan baru
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }

  // Mendapatkan pesanan pengguna
  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Mendapatkan pesanan untuk penjual (misal semua pesanan yang berisi produk dari penjual ini)
  Stream<QuerySnapshot> getSellerOrders(String sellerId) {
    // Ini query kompleks, mungkin perlu arrayContains untuk sellerId di setiap item order
    // Atau struktur data orders diubah agar lebih mudah query per seller.
    // Untuk awal, kita bisa bayangkan field 'sellerIdsInOrder' (array of seller UIDs)
    return _db
        .collection('orders')
        .where('sellerIdsInOrder', arrayContains: sellerId)
        .snapshots();
  }
}
