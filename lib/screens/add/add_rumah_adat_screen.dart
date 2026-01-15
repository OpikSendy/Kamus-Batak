// lib/screens/add/add_rumah_adat_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/rumah_adat_viewmodel.dart';

class AddRumahAdatScreen extends StatefulWidget {
  final int sukuId;

  const AddRumahAdatScreen({super.key, required this.sukuId});

  @override
  State<AddRumahAdatScreen> createState() => _AddRumahAdatScreenState();
}

class _AddRumahAdatScreenState extends State<AddRumahAdatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _feature1Controller = TextEditingController();
  final _feature2Controller = TextEditingController();
  final _feature3Controller = TextEditingController();
  final _item1Controller = TextEditingController();
  final _item2Controller = TextEditingController();
  final _item3Controller = TextEditingController();
  final _sejarahController = TextEditingController();
  final _bangunanController = TextEditingController();
  final _ornamenController = TextEditingController();
  final _fungsiController = TextEditingController();
  final _pelestarianController = TextEditingController();

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
    _item1Controller.dispose();
    _item2Controller.dispose();
    _item3Controller.dispose();
    _sejarahController.dispose();
    _bangunanController.dispose();
    _ornamenController.dispose();
    _fungsiController.dispose();
    _pelestarianController.dispose();
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

    final viewModel = Provider.of<RumahAdatViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    final success = await viewModel.submitRumahAdatByUser(
      sukuId: widget.sukuId,
      nama: _namaController.text,
      fotoFile: _selectedImage!,
      deskripsi: _deskripsiController.text,
      feature1: _feature1Controller.text,
      feature2: _feature2Controller.text,
      feature3: _feature3Controller.text,
      item1: _item1Controller.text,
      item2: _item2Controller.text,
      item3: _item3Controller.text,
      sejarah: _sejarahController.text,
      bangunan: _bangunanController.text,
      ornamen: _ornamenController.text,
      fungsi: _fungsiController.text,
      pelestarian: _pelestarianController.text,
      bucketName: 'rumah',
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
          'Data rumah adat berhasil dikirim!\n\n'
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final horizontalPadding = isSmallScreen ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            'Tambah Rumah Adat',
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
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20,
          ),
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
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
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
                              fontSize: isSmallScreen ? 12 : 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Foto Section
                _buildSectionTitle('Foto Rumah Adat', isSmallScreen),
                SizedBox(height: 12),
                _buildImagePicker(isSmallScreen),
                SizedBox(height: 24),

                // Nama Field
                _buildSectionTitle('Nama Rumah Adat', isSmallScreen),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _namaController,
                  hintText: 'Contoh: Rumah Bolon',
                  icon: Icons.home_work,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama rumah adat tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama rumah adat minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Deskripsi Field
                _buildSectionTitle('Deskripsi', isSmallScreen),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _deskripsiController,
                  hintText: 'Deskripsi singkat rumah adat',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Features Section
                _buildSectionHeader('Karakteristik Rumah Adat', isSmallScreen),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _feature1Controller,
                  hintText: 'Karakteristik 1 (contoh: Atap Tinggi)',
                  icon: Icons.architecture,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Karakteristik 1 tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _feature2Controller,
                  hintText: 'Karakteristik 2 (contoh: Ornamen Ukiran)',
                  icon: Icons.architecture,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Karakteristik 2 tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _feature3Controller,
                  hintText: 'Karakteristik 3 (contoh: Rumah Panggung)',
                  icon: Icons.architecture,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Karakteristik 3 tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Significance Items Section
                _buildSectionHeader('Signifikansi Budaya', isSmallScreen),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _item1Controller,
                  hintText: 'Signifikansi Spiritual',
                  icon: Icons.self_improvement,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Signifikansi spiritual tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _item2Controller,
                  hintText: 'Signifikansi Sosial',
                  icon: Icons.people,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Signifikansi sosial tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _item3Controller,
                  hintText: 'Signifikansi Artistik',
                  icon: Icons.palette,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Signifikansi artistik tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Detailed Information Section
                _buildSectionHeader('Informasi Detail', isSmallScreen),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _sejarahController,
                  hintText: 'Sejarah rumah adat',
                  icon: Icons.history_edu,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Sejarah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _bangunanController,
                  hintText: 'Struktur dan bangunan',
                  icon: Icons.foundation,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informasi bangunan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _ornamenController,
                  hintText: 'Ornamen dan dekorasi',
                  icon: Icons.art_track,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informasi ornamen tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _fungsiController,
                  hintText: 'Fungsi dan kegunaan',
                  icon: Icons.assignment,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Fungsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                _buildTextField(
                  controller: _pelestarianController,
                  hintText: 'Upaya pelestarian',
                  icon: Icons.restore,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informasi pelestarian tidak boleh kosong';
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
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16,
                    ),
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
                          fontSize: isSmallScreen ? 15 : 16,
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

  Widget _buildSectionTitle(String title, bool isSmallScreen) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isSmallScreen ? 15 : 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isSmallScreen ? 16 : 18,
          fontWeight: FontWeight.bold,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _buildImagePicker(bool isSmallScreen) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: isSmallScreen ? 200 : 250,
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
              size: isSmallScreen ? 56 : 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Tap untuk pilih foto',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
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
          borderSide: BorderSide(color: Colors.red[800]!, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.red[800]),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 16 : 12,
        ),
      ),
      validator: validator,
    );
  }
}