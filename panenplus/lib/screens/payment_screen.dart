// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:panenplus/services/firestore_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic>? paymentData;
  const PaymentScreen({super.key, this.paymentData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  List<Map<String, dynamic>> _orderedItems = [];
  num _totalPrice = 0;
  String _customerName = '';
  String _customerPhone = '';
  String _customerAddress = '';

  @override
  void initState() {
    super.initState();
    // Ambil data dari widget (constructor)
    final args = widget.paymentData;
    if (args != null) {
      _orderedItems = List<Map<String, dynamic>>.from(
        args['orderedItems'] as List,
      );
      _totalPrice = args['totalPrice'] as num;
      _customerName = args['customerName'] ?? 'Tidak ada nama';
      _customerPhone = args['customerPhone'] ?? 'Tidak ada telepon';
      _customerAddress = args['customerAddress'] ?? 'Tidak ada alamat';
    }
  }

  Future<void> _processOrder() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anda harus login.')));
      return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sellerIds =
          _orderedItems
              .map((item) => item['sellerId'] as String)
              .toSet()
              .toList();
      Map<String, dynamic> orderData = {
        'buyerId': currentUser.uid,
        'buyerName': _customerName,
        'buyerAddress': _customerAddress,
        'buyerPhone': _customerPhone,
        'items': _orderedItems,
        'sellerIdsInOrder': sellerIds,
        'grandTotal': _calculateGrandTotal(),
        'shippingCost': _calculateShippingCost(),
        'paymentMethod': _selectedPaymentMethod,
        'status': 'Perlu Dikirim',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestoreService.placeOrderAndUpdateStock(
        orderData: orderData,
        items: _orderedItems,
        userId: currentUser.uid,
      );

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/transaction_success', (route) => false);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  num _calculateSubtotal() => _totalPrice;
  num _calculateShippingCost() => 15000;
  num _calculateGrandTotal() => _calculateSubtotal() + _calculateShippingCost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFFC7D9C7),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, color: Colors.grey, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_customerName $_customerPhone',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _customerAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 0, thickness: 1),
            const SizedBox(height: 16),
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _orderedItems.length,
                      itemBuilder: (context, index) {
                        final item = _orderedItems[index];
                        return _PaymentOrderedItemCard(
                          name: item['name'] as String,
                          image: item['image'] as String,
                          price: (item['price'] as num).toDouble(),
                          qty: item['qty'] as int,
                        );
                      },
                    ),
                    const Divider(height: 20, thickness: 1),
                    _buildSummaryRow(
                      'Subtotal',
                      'Rp ${_calculateSubtotal().toStringAsFixed(0)}',
                    ),
                    _buildSummaryRow(
                      'Biaya Pengiriman',
                      'Rp ${_calculateShippingCost().toStringAsFixed(0)}',
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Total Pembayaran',
                      'Rp ${_calculateGrandTotal().toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Transfer Bank'),
                    value: 'bank_transfer',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (v) => setState(() => _selectedPaymentMethod = v),
                  ),
                  RadioListTile<String>(
                    title: const Text('COD (Bayar di Tempat)'),
                    value: 'cod',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (v) => setState(() => _selectedPaymentMethod = v),
                  ),
                  RadioListTile<String>(
                    title: const Text('Dana'),
                    value: 'dana',
                    groupValue: _selectedPaymentMethod,
                    onChanged:
                        (v) => setState(() => _selectedPaymentMethod = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        onPressed:
                            _orderedItems.isEmpty ||
                                    _selectedPaymentMethod == null
                                ? null
                                : _processOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text(
                          'Bayar Sekarang',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green[800] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOrderedItemCard extends StatelessWidget {
  final String name;
  final String image;
  final double price;
  final int qty;

  const _PaymentOrderedItemCard({
    required this.name,
    required this.image,
    required this.price,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child:
                image.startsWith('http')
                    ? Image.network(
                      image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => _errorBuilder(),
                    )
                    : Image.asset(
                      image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => _errorBuilder(),
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${qty} x Rp ${price.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${(price * qty).toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _errorBuilder() {
    return Container(
      color: Colors.grey[300],
      width: 50,
      height: 50,
      child: const Icon(Icons.image, size: 25, color: Colors.grey),
    );
  }
}
