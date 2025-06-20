// lib/screens/upload_product_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:panenplus/services/firestore_service.dart'; // Pastikan path ini benar
// Hapus semua import yang tidak lagi diperlukan untuk image_picker dan Firebase Storage
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb; // Tidak perlu kIsWeb lagi

class UploadProductScreen extends StatefulWidget {
  final String? productId; // ID produk jika dalam mode edit
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
  bool _isLoading = false;

  // Variabel untuk menyimpan path gambar aset lokal yang dipilih
  String _selectedAssetImagePath = ''; // Default kosong

  // Daftar path gambar aset lokal yang bisa dipilih pengguna
  // PASTIKAN SEMUA PATH INI BENAR DAN FILE GAMBARNYA ADA DI FOLDER ASSET ANDA
  final List<String> _assetImagePaths = const [
    'assets/beras.png',
    'assets/wortel.png',
    'assets/kentang.png',
    'assets/jagung.png',
    'assets/pakcoy.png',
    'assets/tomat.png',
    'assets/images/product_placeholder.png', // Contoh placeholder
    // Tambahkan semua gambar produk default/placeholder yang Anda miliki di sini
  ];

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductDataForEdit(widget.productId!); // Muat data jika mode edit
    }
  }

  Future<void> _loadProductDataForEdit(String productId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      DocumentSnapshot productDoc = await _firestoreService.getProductDetails(
        productId,
      );
      if (productDoc.exists) {
        final data = productDoc.data() as Map<String, dynamic>;
        nameController.text = data['productName'] ?? '';
        priceController.text = data['price']?.toString() ?? '';
        descriptionController.text = data['description'] ?? '';
        stockController.text = data['stock']?.toString() ?? '';
        _selectedAssetImagePath =
            data['imageUrl'] ?? ''; // Ambil path gambar yang tersimpan
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data produk: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleProductUpload() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus login untuk mengunggah produk.'),
          ),
        );
      }
      return;
    }

    // Validasi gambar: Pastikan ada gambar yang dipilih
    if (_selectedAssetImagePath.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih gambar produk dari aset lokal.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> productData = {
        'productName': nameController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0.0,
        'description': descriptionController.text.trim(),
        'stock': int.tryParse(stockController.text.trim()) ?? 0,
        'imageUrl': _selectedAssetImagePath, // Langsung gunakan path aset lokal
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diunggah!')),
          );
        }
      } else {
        await _firestoreService.updateProduct(widget.productId!, productData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diperbarui!')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal ${widget.productId == null ? "mengunggah" : "memperbarui"} produk: $e',
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading && widget.productId != null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // Tidak ada lagi fungsi pickImage dari image_picker
                            // Pengguna akan memilih dari Dropdown di bawah
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Silakan pilih gambar dari dropdown di bawah.',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                              image:
                                  _selectedAssetImagePath.isNotEmpty
                                      ? DecorationImage(
                                        image: AssetImage(
                                          _selectedAssetImagePath,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                _selectedAssetImagePath.isEmpty
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ), // Ikon umum
                                        Text(
                                          'Pilih Gambar Aset Lokal',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown untuk memilih gambar dari aset lokal
                      DropdownButtonFormField<String>(
                        value:
                            _selectedAssetImagePath.isEmpty
                                ? null
                                : _selectedAssetImagePath,
                        hint: const Text('Pilih Gambar Produk (Aset Lokal)'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelText: 'Gambar Produk',
                        ),
                        items:
                            _assetImagePaths.map((String path) {
                              return DropdownMenuItem<String>(
                                value: path,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      path,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      path.split('/').last,
                                    ), // Tampilkan hanya nama file
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAssetImagePath = newValue ?? '';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Gambar produk harus dipilih';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Nama Produk',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama produk tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Harga (Rp)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Harga tidak boleh kosong';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Harga harus angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stok',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Stok tidak boleh kosong';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Stok harus angka';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi Produk',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleProductUpload,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                widget.productId == null
                                    ? 'Unggah Produk'
                                    : 'Perbarui Produk',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
