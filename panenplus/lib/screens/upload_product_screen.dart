import 'package:flutter/material.dart';

class UploadProductScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: InputDecoration(labelText: 'Nama Produk')),
              TextFormField(decoration: InputDecoration(labelText: 'Harga')),
              TextFormField(decoration: InputDecoration(labelText: 'Deskripsi')),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Simpan ke backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Produk diunggah')),
                    );
                  }
                },
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
