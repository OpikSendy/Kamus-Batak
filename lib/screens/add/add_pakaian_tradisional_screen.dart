// lib/screens/add/add_pakaian_tradisional_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/pakaian_tradisional_viewmodel.dart';

class AddPakaianTradisionalScreen extends StatefulWidget {
  final int sukuId;

  const AddPakaianTradisionalScreen({
    super.key,
    required this.sukuId,
  });

  @override
  State<AddPakaianTradisionalScreen> createState() => _AddPakaianTradisionalScreenState();
}

class _AddPakaianTradisionalScreenState extends State<AddPakaianTradisionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _sejarahController = TextEditingController();
  final _bahanController = TextEditingController();
  final _kelengkapanController = TextEditingController();
  final _feature1Controller = TextEditingController();
  final _feature2Controller = TextEditingController();
  final _feature3Controller = TextEditingController();
  final _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _sejarahController.dispose();
    _bahanController.dispose();
    _kelengkapanController.dispose();
    _feature1Controller.dispose();
    _feature2Controller.dispose();
    _feature3Controller.dispose();
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
                leading: Icon(Icons.camera_alt, color: Colors.teal[700]),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.teal[700]),
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

    final viewModel = Provider.of<PakaianTradisionalViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    final success = await viewModel.submitPakaianByUser(
      sukuId: widget.sukuId,
      nama: _namaController.text,
      deskripsi: _deskripsiController.text,
      sejarah: _sejarahController.text,
      bahan: _bahanController.text,
      kelengkapan: _kelengkapanController.text,
      feature1: _feature1Controller.text,
      feature2: _feature2Controller.text,
      feature3: _feature3Controller.text,
      fotoFile: _selectedImage!,
      bucketName: 'pakaian_tradisional',
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
            child: Text('OK', style: TextStyle(color: Colors.teal[700])),
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
          'Data pakaian tradisional berhasil dikirim!\n\n'
              'Data Anda akan ditampilkan setelah divalidasi oleh admin. '
              'Terima kasih atas kontribusinya!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: Text('OK', style: TextStyle(color: Colors.teal[700])),
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
            'Tambah Pakaian Tradisional',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
        ),
        backgroundColor: Colors.teal[700],
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
                  'Foto Pakaian',
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
                              backgroundColor: Colors.teal[700],
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

                // Nama Field
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Pakaian',
                  hint: 'Contoh: Ulos Batak',
                  icon: Icons.checkroom,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama pakaian tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama pakaian minimal 3 karakter';
                    }
                    return null;
                  },
                ),

                // Deskripsi Field
                _buildTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi',
                  hint: 'Jelaskan secara singkat tentang pakaian ini',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                // Sejarah Field
                _buildTextField(
                  controller: _sejarahController,
                  label: 'Sejarah',
                  hint: 'Ceritakan sejarah pakaian ini',
                  icon: Icons.history_edu,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sejarah tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                // Bahan Field
                _buildTextField(
                  controller: _bahanController,
                  label: 'Bahan dan Motif',
                  hint: 'Jelaskan bahan dan motif yang digunakan',
                  icon: Icons.texture,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Bahan dan motif tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                // Kelengkapan Field
                _buildTextField(
                  controller: _kelengkapanController,
                  label: 'Kelengkapan dan Aksesoris',
                  hint: 'Jelaskan kelengkapan dan aksesoris',
                  icon: Icons.inventory_2,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kelengkapan tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                // Feature 1 Field
                _buildTextField(
                  controller: _feature1Controller,
                  label: 'Jenis/Kategori',
                  hint: 'Contoh: Formal, Upacara',
                  icon: Icons.style,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jenis tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                // Feature 2 Field
                _buildTextField(
                  controller: _feature2Controller,
                  label: 'Acara Penggunaan',
                  hint: 'Contoh: Pernikahan, Festival',
                  icon: Icons.event,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Acara tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                // Feature 3 Field
                _buildTextField(
                  controller: _feature3Controller,
                  label: 'Status',
                  hint: 'Contoh: Aktif, Ritual',
                  icon: Icons.auto_awesome,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Status tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
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
                borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
              ),
              prefixIcon: Icon(icon, color: Colors.teal[700]),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}