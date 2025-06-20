// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; // Untuk tipe File dari mobile
import 'dart:typed_data'; // Untuk tipe Uint8List dari web

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
      'address': '', // Alamat default kosong
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

  // Mengunggah gambar untuk MOBILE (menerima File)
  Future<String> uploadProductImage(File imageFile) async {
    String fileName =
        'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    UploadTask uploadTask = _storage.ref().child(fileName).putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Mengunggah gambar untuk WEB (menerima Uint8List)
  Future<String> uploadProductImageBytes(
    Uint8List imageBytes,
    String fileName,
  ) async {
    String filePath =
        'product_images/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    UploadTask uploadTask = _storage.ref().child(filePath).putData(imageBytes);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
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
    DocumentReference docRef = _db.collection('products').doc();
    await docRef.set({
      'productId': docRef.id,
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

  // Mendapatkan semua produk
  Stream<QuerySnapshot> getProducts() {
    return _db
        .collection('products')
        .orderBy('timestamp', descending: true)
        .snapshots();
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

  // --- Operasi Pesanan (Orders) & Logika Terkait ---

  // Membuat pesanan baru
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }

  // Mengosongkan keranjang setelah pesanan dibuat (Versi Efisien)
  Future<void> clearCart(String userId) async {
    QuerySnapshot cartSnapshot =
        await _db.collection('users').doc(userId).collection('cart').get();

    WriteBatch batch = _db.batch();
    for (DocumentSnapshot doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Mendapatkan semua pesanan milik seorang pengguna (pembeli)
  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Mendapatkan pesanan untuk penjual tertentu
  Stream<QuerySnapshot> getOrdersForSeller(String sellerId) {
    return _db
        .collection('orders')
        .where('sellerIdsInOrder', arrayContains: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Operasi Chat (KODE BARU DITAMBAHKAN DI SINI) ---

  // Membuat ID chat yang konsisten antara dua pengguna
  String getChatId(String userId1, String userId2) {
    if (userId1.hashCode <= userId2.hashCode) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  // Mengirim pesan baru dan mengupdate data percakapan
  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> messageData,
    Map<String, dynamic> chatData,
  ) async {
    // Tambahkan pesan ke sub-koleksi messages
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Update data percakapan utama (lastMessage, dll)
    // set dengan merge:true akan membuat dokumen jika belum ada, atau update jika sudah ada
    await _db
        .collection('chats')
        .doc(chatId)
        .set(chatData, SetOptions(merge: true));
  }

  // Mendapatkan stream/aliran pesan dari sebuah percakapan
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Mendapatkan semua percakapan yang dimiliki seorang pengguna
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _db
        .collection('chats')
        .where('users', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }
}
