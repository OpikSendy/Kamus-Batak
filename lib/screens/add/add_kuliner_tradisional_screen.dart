// lib/screens/add/add_kuliner_tradisional_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/kuliner_tradisional_viewmodel.dart';

class AddKulinerTradisionalScreen extends StatefulWidget {
  const AddKulinerTradisionalScreen({super.key});

  @override
  State<AddKulinerTradisionalScreen> createState() => _AddKulinerTradisionalScreenState();
}

class _AddKulinerTradisionalScreenState extends State<AddKulinerTradisionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _ratingController = TextEditingController();
  final _waktuController = TextEditingController();
  final _resepController = TextEditingController();
  final _picker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;
  String _selectedJenis = 'makanan'; // default: makanan

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _ratingController.dispose();
    _waktuController.dispose();
    _resepController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih gambar: $e');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Sumber Gambar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.orange[800]),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.orange[800]),
                title: Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImage == null) {
      _showErrorDialog('Silakan pilih foto terlebih dahulu');
      return;
    }

    // Ambil sukuId dari arguments
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
    if (sukuId == null) {
      _showErrorDialog('Error: ID Suku tidak valid');
      return;
    }

    final viewModel = Provider.of<KulinerTradisionalViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    final success = await viewModel.submitKulinerByUser(
      sukuId: sukuId,
      jenis: _selectedJenis,
      nama: _namaController.text,
      fotoFile: _selectedImage!,
      deskripsi: _deskripsiController.text,
      rating: _ratingController.text,
      waktu: _waktuController.text,
      resep: _resepController.text,
      bucketName: 'kuliner', // Sesuaikan dengan bucket Supabase Anda
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted && viewModel.errorMessage != null) {
      _showErrorDialog(viewModel.errorMessage!);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[800]),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Colors.orange[800])),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Text('Berhasil!'),
          ],
        ),
        content: Text(
          'Data kuliner berhasil dikirim!\n\n'
              'Data Anda akan ditampilkan setelah divalidasi oleh admin. '
              'Terima kasih atas kontribusinya!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: Text('OK', style: TextStyle(color: Colors.orange[800])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            'Tambah Kuliner Baru',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
        ),
        backgroundColor: Colors.orange[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[800]),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Data yang Anda kirim akan direview oleh admin '
                                'sebelum ditampilkan di aplikasi.',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Foto Section
                Text(
                  'Foto Kuliner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              backgroundColor: Colors.orange[800],
                              child: IconButton(
                                icon: Icon(Icons.edit, color: Colors.white, size: 20),
                                onPressed: _showImageSourceDialog,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tap untuk pilih foto',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Jenis Field
                Text(
                  'Jenis Kuliner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedJenis,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.orange[800]),
                      items: [
                        DropdownMenuItem(
                          value: 'makanan',
                          child: Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: Colors.green[700]),
                              SizedBox(width: 12),
                              Text('Makanan'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'minuman',
                          child: Row(
                            children: [
                              Icon(Icons.local_bar, color: Colors.blue[700]),
                              SizedBox(width: 12),
                              Text('Minuman'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedJenis = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Nama Field
                Text(
                  'Nama Kuliner',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Saksang',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                    ),
                    prefixIcon: Icon(Icons.restaurant, color: Colors.orange[800]),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama kuliner tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama kuliner minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Deskripsi Field
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Jelaskan tentang kuliner ini...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                    ),
                    prefixIcon: Icon(Icons.description, color: Colors.orange[800]),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    if (value.trim().length < 10) {
                      return 'Deskripsi minimal 10 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Rating & Waktu Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _ratingController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              hintText: '4.5',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                              ),
                              prefixIcon: Icon(Icons.star, color: Colors.amber),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Rating diperlukan';
                              }
                              final rating = double.tryParse(value);
                              if (rating == null || rating < 0 || rating > 5) {
                                return 'Rating harus 0-5';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _waktuController,
                            decoration: InputDecoration(
                              hintText: '30 menit',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                              ),
                              prefixIcon: Icon(Icons.access_time, color: Colors.blue[700]),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Waktu diperlukan';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Resep Field
                Text(
                  'Resep / Cara Membuat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _resepController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Tulis langkah-langkah pembuatan...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.orange[800]!, width: 2),
                    ),
                    prefixIcon: Icon(Icons.menu_book, color: Colors.orange[800]),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Resep tidak boleh kosong';
                    }
                    if (value.trim().length < 20) {
                      return 'Resep minimal 20 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Kirim Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}