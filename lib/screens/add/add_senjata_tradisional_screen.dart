import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/senjata_tradisional_viewmodel.dart';

class AddSenjataTradisionalScreen extends StatefulWidget {
  final int sukuId;

  const AddSenjataTradisionalScreen({
    super.key,
    required this.sukuId,
  });

  @override
  State<AddSenjataTradisionalScreen> createState() => _AddSenjataTradisionalScreenState();
}

class _AddSenjataTradisionalScreenState extends State<AddSenjataTradisionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _feature1Controller = TextEditingController();
  final _feature2Controller = TextEditingController();
  final _feature3Controller = TextEditingController();
  final _sejarahController = TextEditingController();
  final _materialController = TextEditingController();
  final _simbolController = TextEditingController();
  final _penggunaanController = TextEditingController();
  final _pertahananController = TextEditingController();
  final _perburuanController = TextEditingController();
  final _seremonialController = TextEditingController();

  final _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _feature1Controller.dispose();
    _feature2Controller.dispose();
    _feature3Controller.dispose();
    _sejarahController.dispose();
    _materialController.dispose();
    _simbolController.dispose();
    _penggunaanController.dispose();
    _pertahananController.dispose();
    _perburuanController.dispose();
    _seremonialController.dispose();
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
                leading: Icon(Icons.camera_alt, color: Colors.red[800]),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.red[800]),
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

    final viewModel = Provider.of<SenjataTradisionalViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    final success = await viewModel.submitSenjataByUser(
      sukuId: widget.sukuId,
      nama: _namaController.text,
      fotoFile: _selectedImage!,
      deskripsi: _deskripsiController.text,
      feature1: _feature1Controller.text,
      feature2: _feature2Controller.text,
      feature3: _feature3Controller.text,
      sejarah: _sejarahController.text,
      material: _materialController.text,
      simbol: _simbolController.text,
      penggunaan: _penggunaanController.text,
      pertahanan: _pertahananController.text,
      perburuan: _perburuanController.text,
      seremonial: _seremonialController.text,
      bucketName: 'senjata_tradisional',
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
            child: Text('OK', style: TextStyle(color: Colors.red[800])),
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
          'Data senjata tradisional berhasil dikirim!\n\n'
              'Data Anda akan ditampilkan setelah divalidasi oleh admin. '
              'Terima kasih atas kontribusinya!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: Text('OK', style: TextStyle(color: Colors.red[800])),
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
            'Tambah Senjata Tradisional',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
        ),
        backgroundColor: Colors.red[800],
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
                _buildPhotoSection(),
                SizedBox(height: 24),

                // Nama Senjata
                _buildTextField(
                  controller: _namaController,
                  label: 'Nama Senjata',
                  hint: 'Contoh: Piso Surit',
                  icon: Icons.gavel,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama senjata tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama senjata minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Deskripsi
                _buildTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi',
                  hint: 'Deskripsi singkat tentang senjata',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Features Section
                Text(
                  'Fitur Unggulan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _feature1Controller,
                  label: 'Fitur 1',
                  hint: 'Fitur pertama',
                  icon: Icons.star,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fitur 1 tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _feature2Controller,
                  label: 'Fitur 2',
                  hint: 'Fitur kedua',
                  icon: Icons.star,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fitur 2 tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _feature3Controller,
                  label: 'Fitur 3',
                  hint: 'Fitur ketiga',
                  icon: Icons.star,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fitur 3 tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Detail Information Section
                Text(
                  'Informasi Detail',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _sejarahController,
                  label: 'Sejarah',
                  hint: 'Sejarah dan asal-usul senjata',
                  icon: Icons.history,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sejarah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _materialController,
                  label: 'Material',
                  hint: 'Bahan pembuatan senjata',
                  icon: Icons.build,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Material tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _simbolController,
                  label: 'Simbol',
                  hint: 'Simbol dan makna filosofis',
                  icon: Icons.local_library,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Simbol tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _penggunaanController,
                  label: 'Penggunaan',
                  hint: 'Cara penggunaan senjata',
                  icon: Icons.handyman,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Penggunaan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Fungsi Section
                Text(
                  'Fungsi Senjata',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _pertahananController,
                  label: 'Pertahanan',
                  hint: 'Fungsi untuk pertahanan',
                  icon: Icons.shield,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fungsi pertahanan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _perburuanController,
                  label: 'Perburuan',
                  hint: 'Fungsi untuk perburuan',
                  icon: Icons.nature_people,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fungsi perburuan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _seremonialController,
                  label: 'Seremonial',
                  hint: 'Fungsi dalam upacara adat',
                  icon: Icons.celebration,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fungsi seremonial tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
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
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Senjata',
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
            height: 200,
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
                      backgroundColor: Colors.red[800],
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
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (maxLines == 1) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: maxLines > 1 ? label : null,
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[800]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[800]!, width: 2),
            ),
            prefixIcon: Icon(icon, color: Colors.red[800]),
            alignLabelWithHint: maxLines > 1,
          ),
          validator: validator,
        ),
      ],
    );
  }
}