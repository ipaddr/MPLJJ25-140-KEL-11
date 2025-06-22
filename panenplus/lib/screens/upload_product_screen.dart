// lib/screens/upload_product_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panenplus/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class UploadProductScreen extends StatefulWidget {
  final String? productId;
  const UploadProductScreen({super.key, this.productId});

  @override
  State<UploadProductScreen> createState() => _UploadProductScreenState();
}

class _UploadProductScreenState extends State<UploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Variabel untuk menangani gambar
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _imageName;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductDataForEdit(widget.productId!);
    }
  }

  Future<void> _loadProductDataForEdit(String productId) async {
    setState(() => _isLoading = true);
    try {
      DocumentSnapshot productDoc = await _firestoreService.getProductDetails(
        productId,
      );
      if (productDoc.exists && mounted) {
        final data = productDoc.data() as Map<String, dynamic>;
        nameController.text = data['productName'] ?? '';
        priceController.text = data['price']?.toString() ?? '';
        descriptionController.text = data['description'] ?? '';
        stockController.text = data['stock']?.toString() ?? '';
        _existingImageUrl = data['imageUrl'];
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data produk: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _existingImageUrl = null;
      });
      if (kIsWeb) {
        _selectedImageBytes = await pickedFile.readAsBytes();
        _imageName = pickedFile.name;
      } else {
        _selectedImageFile = File(pickedFile.path);
      }
      setState(() {});
    }
  }

  Future<void> _handleProductUpload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImageFile == null &&
        _selectedImageBytes == null &&
        _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar produk.')),
      );
      return;
    }
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anda harus login.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      // Menggunakan fungsi uploadImage yang sudah adaptif (web/mobile)
      if (_selectedImageFile != null || _selectedImageBytes != null) {
        imageUrl = await _firestoreService.uploadImage(
          mobileFile: _selectedImageFile,
          webBytes: _selectedImageBytes,
          fileName: _imageName,
        );
      }

      Map<String, dynamic> productData = {
        'productName': nameController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'description': descriptionController.text.trim(),
        'stock': int.tryParse(stockController.text.trim()) ?? 0,
        'imageUrl': imageUrl,
        'sellerId': currentUser.uid,
        'sellerName': currentUser.displayName ?? 'Penjual Tidak Dikenal',
      };

      if (widget.productId == null) {
        await _firestoreService.addProduct(
          productName: productData['productName'],
          price: productData['price'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          sellerId: productData['sellerId'],
          sellerName: productData['sellerName'],
          stock: productData['stock'],
        );
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diunggah!')),
          );
      } else {
        await _firestoreService.updateProduct(widget.productId!, productData);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diperbarui!')),
          );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productId == null ? 'Unggah Produk Baru' : 'Edit Produk',
        ),
        elevation: 1,
      ),
      body:
          _isLoading &&
                  widget.productId !=
                      null // Tampilkan loading hanya saat memuat data edit
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Bagian Gambar Produk ---
                      const Text(
                        "Gambar Produk",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: _buildImagePreview(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Bagian Detail Produk ---
                      const Text(
                        "Detail Produk",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: _inputDecoration(
                          'Nama Produk',
                          Icons.label_important_outline,
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Nama produk tidak boleh kosong'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Harga (Rp)',
                          Icons.attach_money_outlined,
                        ),
                        validator:
                            (v) =>
                                (v == null ||
                                        v.isEmpty ||
                                        double.tryParse(v) == null)
                                    ? 'Harga harus angka yang valid'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration(
                          'Jumlah Stok',
                          Icons.inventory_2_outlined,
                        ),
                        validator:
                            (v) =>
                                (v == null ||
                                        v.isEmpty ||
                                        int.tryParse(v) == null)
                                    ? 'Stok harus angka yang valid'
                                    : null,
                      ),
                      const SizedBox(height: 24),

                      // --- Bagian Deskripsi ---
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: _inputDecoration(
                          'Deskripsi lengkap produk',
                          Icons.description_outlined,
                          alignLabel: true,
                        ),
                        validator:
                            (v) =>
                                (v == null || v.isEmpty)
                                    ? 'Deskripsi tidak boleh kosong'
                                    : null,
                      ),
                      const SizedBox(height: 32),

                      // --- Tombol Aksi ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon:
                              _isLoading
                                  ? const SizedBox.shrink()
                                  : const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.white,
                                  ),
                          label:
                              _isLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : Text(
                                    widget.productId == null
                                        ? 'Unggah Produk'
                                        : 'Perbarui Produk',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          onPressed: _isLoading ? null : _handleProductUpload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool alignLabel = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      alignLabelWithHint: alignLabel,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green[800]!, width: 2),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _existingImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey[600]),
        const SizedBox(height: 8),
        const Text(
          'Ketuk untuk pilih gambar',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
