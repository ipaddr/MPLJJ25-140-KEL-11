// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Untuk tipe File dari mobile
import 'dart:typed_data'; // Untuk tipe Uint8List dari web
import 'package:http/http.dart' as http; // Import paket http
import 'dart:convert'; // Import untuk json.decode

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImage({
    File? mobileFile,
    Uint8List? webBytes,
    String? fileName,
  }) async {
    const String cloudName = 'dkkfsrir6';
    const String uploadPreset = 'panenplus';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    if (webBytes != null && fileName != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', webBytes, filename: fileName),
      );
    } else if (mobileFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('file', mobileFile.path),
      );
    } else {
      throw Exception('Tidak ada file atau data gambar yang diberikan.');
    }
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = json.decode(responseString);
        return jsonMap['secure_url'];
      } else {
        final respStr = await response.stream.bytesToString();
        print('Gagal upload, body: $respStr');
        throw Exception(
          'Gagal mengunggah gambar. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Gagal mengunggah gambar: $e');
    }
  }

  // --- Operasi Pengguna (Users) ---

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

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
      'storeDescription': 'Pengguna PanenPlus',
      'profileImageUrl': '',
      'address': '',
    });
  }

  Future<DocumentSnapshot> getUserData(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // --- Operasi Produk (Products) ---

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

  Stream<QuerySnapshot> getProducts() {
    return _db
        .collection('products')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getProductsBySeller(String sellerId) {
    return _db
        .collection('products')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();
  }

  Future<DocumentSnapshot> getProductDetails(String productId) {
    return _db.collection('products').doc(productId).get();
  }

  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('products').doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  // --- Operasi Keranjang (Cart) ---

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

  Stream<QuerySnapshot> getCartItems(String userId) {
    return _db.collection('users').doc(userId).collection('cart').snapshots();
  }

  Future<void> removeCartItem(String userId, String productId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // --- Operasi Pesanan (Orders) & Logika Terkait ---

  Future<void> placeOrderAndUpdateStock({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> items,
    required String userId,
  }) async {
    final batch = _db.batch();
    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, orderData);

    for (var item in items) {
      final productRef = _db.collection('products').doc(item['productId']);
      final quantityToDecrease = -item['qty'];
      batch.update(productRef, {
        'stock': FieldValue.increment(quantityToDecrease),
      });
    }

    final cartItemsSnapshot =
        await _db.collection('users').doc(userId).collection('cart').get();
    for (var doc in cartItemsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('buyerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getOrdersForSeller(String sellerId) {
    return _db
        .collection('orders')
        .where('sellerIdsInOrder', arrayContains: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Operasi Chat ---

  String getChatId(String userId1, String userId2) {
    if (userId1.hashCode <= userId2.hashCode) {
      return '$userId1-$userId2';
    } else {
      return '$userId2-$userId1';
    }
  }

  Future<void> sendMessage(
    String chatId,
    Map<String, dynamic> messageData,
    Map<String, dynamic> chatData,
  ) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);
    await _db
        .collection('chats')
        .doc(chatId)
        .set(chatData, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserChats(String userId) {
    return _db
        .collection('chats')
        .where('users', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  // *** PENAMBAHAN FUNGSI NOTIFIKASI DI SINI ***
  // --- Operasi Notifikasi ---

  // Menambahkan notifikasi baru untuk pengguna
  Future<void> addNotification(
    String userId,
    Map<String, dynamic> notificationData,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notificationData);
  }

  // Mengambil semua notifikasi milik pengguna
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Menandai notifikasi sebagai sudah dibaca
  Future<void> markNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
