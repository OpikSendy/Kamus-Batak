// lib/screens/add/add_tarian_tradisional_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/tarian_tradisional_viewmodel.dart';

class AddTarianTradisionalScreen extends StatefulWidget {
  final int sukuId;

  const AddTarianTradisionalScreen({
    super.key,
    required this.sukuId,
  });

  @override
  State<AddTarianTradisionalScreen> createState() => _AddTarianTradisionalScreenState();
}

class _AddTarianTradisionalScreenState extends State<AddTarianTradisionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _sejarahController = TextEditingController();
  final _gerakanController = TextEditingController();
  final _kostumController = TextEditingController();
  final _feature1Controller = TextEditingController();
  final _feature2Controller = TextEditingController();
  final _feature3Controller = TextEditingController();
  final _videoController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _durasiController = TextEditingController();
  final _eventController = TextEditingController();

  final _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _sejarahController.dispose();
    _gerakanController.dispose();
    _kostumController.dispose();
    _feature1Controller.dispose();
    _feature2Controller.dispose();
    _feature3Controller.dispose();
    _videoController.dispose();
    _kategoriController.dispose();
    _durasiController.dispose();
    _eventController.dispose();
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
                leading: Icon(Icons.camera_alt, color: Colors.brown[800]),
                title: Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.brown[800]),
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

    final viewModel = Provider.of<TarianTradisionalViewModel>(context, listen: false);

    setState(() => _isLoading = true);

    final success = await viewModel.submitTarianByUser(
      sukuId: widget.sukuId,
      nama: _namaController.text,
      deskripsi: _deskripsiController.text,
      sejarah: _sejarahController.text,
      gerakan: _gerakanController.text,
      kostum: _kostumController.text,
      feature1: _feature1Controller.text,
      feature2: _feature2Controller.text,
      feature3: _feature3Controller.text,
      video: _videoController.text,
      kategori: _kategoriController.text,
      durasi: _durasiController.text,
      event: _eventController.text,
      fotoFile: _selectedImage!,
      bucketName: 'tarian', 
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
            child: Text('OK', style: TextStyle(color: Colors.brown[800])),
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
          'Data tarian tradisional berhasil dikirim!\n\n'
              'Data Anda akan ditampilkan setelah divalidasi oleh admin. '
              'Terima kasih atas kontribusinya!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: Text('OK', style: TextStyle(color: Colors.brown[800])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            'Tambah Tarian Tradisional',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )
        ),
        backgroundColor: Colors.brown[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
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
                        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
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
                                  fontSize: isTablet ? 14 : 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Foto Section
                    _buildSectionTitle('Foto Tarian', isTablet),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: isTablet ? 300 : 250,
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
                                  backgroundColor: Colors.brown[800],
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
                              size: isTablet ? 80 : 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tap untuk pilih foto',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Nama Tarian
                    _buildTextField(
                      controller: _namaController,
                      label: 'Nama Tarian',
                      hint: 'Contoh: Tor Tor',
                      icon: Icons.music_note,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tarian tidak boleh kosong';
                        }
                        if (value.trim().length < 3) {
                          return 'Nama tarian minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Deskripsi
                    _buildTextField(
                      controller: _deskripsiController,
                      label: 'Deskripsi',
                      hint: 'Jelaskan tarian ini secara singkat',
                      icon: Icons.description,
                      isTablet: isTablet,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        if (value.trim().length < 20) {
                          return 'Deskripsi minimal 20 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Sejarah
                    _buildTextField(
                      controller: _sejarahController,
                      label: 'Sejarah',
                      hint: 'Ceritakan sejarah tarian ini',
                      icon: Icons.history_edu,
                      isTablet: isTablet,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Sejarah tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Gerakan
                    _buildTextField(
                      controller: _gerakanController,
                      label: 'Gerakan dan Makna',
                      hint: 'Jelaskan gerakan-gerakan dalam tarian',
                      icon: Icons.accessibility_new,
                      isTablet: isTablet,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Gerakan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Kostum
                    _buildTextField(
                      controller: _kostumController,
                      label: 'Kostum dan Perlengkapan',
                      hint: 'Deskripsikan kostum yang digunakan',
                      icon: Icons.checkroom,
                      isTablet: isTablet,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kostum tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Features Section
                    _buildSectionTitle('Informasi Tambahan', isTablet),
                    SizedBox(height: 12),

                    // Features dalam grid untuk tablet
                    if (isTablet)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _feature1Controller,
                              label: 'Fitur 1',
                              hint: 'Contoh: Ritual Adat',
                              icon: Icons.star,
                              isTablet: isTablet,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Fitur 1 tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _feature2Controller,
                              label: 'Fitur 2',
                              hint: 'Contoh: Tarian Kelompok',
                              icon: Icons.star,
                              isTablet: isTablet,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Fitur 2 tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildTextField(
                        controller: _feature1Controller,
                        label: 'Fitur 1',
                        hint: 'Contoh: Ritual Adat',
                        icon: Icons.star,
                        isTablet: isTablet,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Fitur 1 tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _feature2Controller,
                        label: 'Fitur 2',
                        hint: 'Contoh: Tarian Kelompok',
                        icon: Icons.star,
                        isTablet: isTablet,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Fitur 2 tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 20),

                    _buildTextField(
                      controller: _feature3Controller,
                      label: 'Fitur 3',
                      hint: 'Contoh: Musik Tradisional',
                      icon: Icons.star,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Fitur 3 tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Detail Info Section
                    _buildSectionTitle('Detail Tarian', isTablet),
                    SizedBox(height: 12),

                    if (isTablet)
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _kategoriController,
                              label: 'Kategori',
                              hint: 'Contoh: Tarian Adat',
                              icon: Icons.category,
                              isTablet: isTablet,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Kategori tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _durasiController,
                              label: 'Durasi',
                              hint: 'Contoh: 10-15 menit',
                              icon: Icons.timer,
                              isTablet: isTablet,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Durasi tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _buildTextField(
                        controller: _kategoriController,
                        label: 'Kategori',
                        hint: 'Contoh: Tarian Adat',
                        icon: Icons.category,
                        isTablet: isTablet,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kategori tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _durasiController,
                        label: 'Durasi',
                        hint: 'Contoh: 10-15 menit',
                        icon: Icons.timer,
                        isTablet: isTablet,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Durasi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 20),

                    _buildTextField(
                      controller: _eventController,
                      label: 'Event/Acara',
                      hint: 'Contoh: Upacara Pernikahan',
                      icon: Icons.event,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Event tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    _buildTextField(
                      controller: _videoController,
                      label: 'Link Video (Opsional)',
                      hint: 'Contoh: https://youtube.com/...',
                      icon: Icons.video_library,
                      isTablet: isTablet,
                      isRequired: false,
                    ),
                    SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[800],
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 20 : 16,
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
                              fontSize: isTablet ? 18 : 16,
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
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isTablet) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isTablet ? 18 : 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isTablet,
    int maxLines = 1,
    bool isRequired = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: isTablet ? 16 : 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: isTablet ? 15 : 13),
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
              borderSide: BorderSide(color: Colors.brown[800]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red[400]!),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red[600]!, width: 2),
            ),
            prefixIcon: Icon(icon, color: Colors.brown[800]),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20 : 16,
              vertical: isTablet ? 18 : 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}