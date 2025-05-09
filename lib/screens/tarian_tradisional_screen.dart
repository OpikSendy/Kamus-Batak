import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import '../viewmodel/tarian_tradisional_viewmodel.dart';
import '../models/tarian_tradisional.dart';

class TarianTradisionalDetailScreen extends StatefulWidget {
  const TarianTradisionalDetailScreen({super.key});

  @override
  State<TarianTradisionalDetailScreen> createState() => _TarianTradisionalDetailScreenState();
}

class _TarianTradisionalDetailScreenState extends State<TarianTradisionalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;

    if (sukuId == null) {
      return _buildErrorScaffold('Error', 'ID Suku tidak valid');
    }

    return ChangeNotifierProvider(
      create: (_) => TarianTradisionalViewModel()..fetchTarianList(sukuId),
      child: Consumer<TarianTradisionalViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildLoadingScaffold();
          } else if (viewModel.tarianList.isEmpty) {
            return _buildEmptyScaffold();
          } else {
            return _buildTarianScaffold(viewModel.tarianList);
          }
        },
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Tarian Tradisional",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[700]!),
            ),
            SizedBox(height: 20),
            Text(
              'Memuat tarian tradisional...',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Tarian Tradisional",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "Tidak ada data tarian tradisional",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Informasi tarian tradisional belum tersedia",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Kembali',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Kembali',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarianScaffold(List<TarianTradisional> tarianList) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Tarian Tradisional",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white,),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.filter_list, color: Colors.white,),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text("Filter tarian tradisional"),
          //         behavior: SnackBarBehavior.floating,
          //         backgroundColor: Colors.brown[700],
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // Header with total count
          Container(
            color: Colors.brown[700],
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                Icon(
                  Icons.celebration,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Ditemukan ${tarianList.length} tarian tradisional",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Main list content
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tarianList.length,
              itemBuilder: (context, index) {
                final tarian = tarianList[index];
                return GestureDetector(
                  onTap: () {
                    _showTarianDetail(context, tarian);
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image with gradient overlay
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                tarian.foto,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 180,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.brown[700]!),
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 180,
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[400],
                                        size: 40,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Gradient overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Title on image
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Text(
                                tarian.nama,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // View details button
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.brown[700]!.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Lihat Detail",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Description
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Origin badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.brown[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.brown[100]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.brown[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Tarian Tradisional",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.brown[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),

                              // Description with limited lines
                              Text(
                                tarian.deskripsi,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: 16),

                              // Action row
                              Row(
                                children: [
                                  // Features row
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _buildFeatureChip(Icons.group, "Kelompok"),
                                      _buildFeatureChip(Icons.event, "Adat"),
                                    ],
                                  ),

                                  Spacer(),

                                  TextButton(
                                    onPressed: () {
                                      _showTarianDetail(context, tarian);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.brown[700],
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Baca Selengkapnya",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[700],
        onPressed: () async {
          final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
          if (sukuId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID suku tidak ditemukan'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          final viewModel = Provider.of<TarianTradisionalViewModel>(context, listen: false);

          if (viewModel.tarianList.isEmpty) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );

            try {
              // Muat data pakaian berdasarkan sukuId
              await viewModel.fetchTarianListBySukuId(sukuId);
              // Tutup dialog loading
              Navigator.pop(context);

              // Jika masih kosong setelah fetch, tampilkan pesan
              if (viewModel.tarianList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada data tarian tradisional untuk suku ini'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
            } catch (e) {
              // Tutup dialog loading jika terjadi error
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memuat data tarian: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }
          }

          // Tampilkan dialog setelah data dimuat
          await showUpdateFotoDialog(
            context: context,
            pakaianList: viewModel.tarianList,
            sukuId: sukuId,
            viewModel: viewModel,
          );
        },
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> showUpdateFotoDialog({
    required BuildContext context,
    required List<TarianTradisional> pakaianList,
    required int sukuId,
    required TarianTradisionalViewModel viewModel,
  }) async {
    // Periksa apakah pakaianList kosong dan muat data jika diperlukan
    if (pakaianList.isEmpty) {
      // Tampilkan loading indicator saat memuat data
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        // Muat data pakaian berdasarkan sukuId
        await viewModel.fetchTarianListBySukuId(sukuId);
        // Tutup dialog loading
        Navigator.pop(context);

        // Jika masih kosong setelah fetch, tampilkan pesan
        if (viewModel.tarianList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data tarian tradisional untuk suku ini'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return; // Keluar dari fungsi jika tidak ada data
        }
      } catch (e) {
        // Tutup dialog loading jika terjadi error
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data tarian: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return; // Keluar dari fungsi jika terjadi error
      }
    }

    final picker = ImagePicker();
    TarianTradisional? selectedPakaian;
    File? selectedImage;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dialog ditutup dengan tap di luar
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // Gunakan pakaianList terbaru dari viewModel
          final updatedPakaianList = viewModel.tarianList;

          // Debug print untuk memeriksa data
          print('Jumlah tarian tradisional: ${updatedPakaianList.length}');
          if (updatedPakaianList.isNotEmpty) {
            print('Contoh tarian pertama: ${updatedPakaianList[0].nama}');
          }

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Update Foto Tarian',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Dropdown dengan styling
                  DropdownButtonFormField<TarianTradisional>(
                    decoration: InputDecoration(
                      labelText: 'Pilih Pakaian',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    value: selectedPakaian,
                    items: updatedPakaianList.map((pakaian) {
                      return DropdownMenuItem(
                        value: pakaian,
                        child: Text(
                          pakaian.nama,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                      setState(() {
                        selectedPakaian = value;
                      });
                    },
                    hint: const Text('Pilih tarian tradisional'),
                  ),
                  const SizedBox(height: 20),
                  // Preview image
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada foto dipilih',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tombol pilih foto
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                      try {
                        final XFile? pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80, // Kompresi gambar
                          maxWidth: 800,    // Resize gambar
                        );
                        if (pickedFile != null) {
                          // Salin file ke lokasi yang kita kontrol untuk memastikan path valid
                          final tempDir = await path_provider.getTemporaryDirectory();
                          final targetPath = path.join(tempDir.path, 'picked_image.jpg');

                          // Salin file ke lokasi yang kita kontrol
                          final bytes = await pickedFile.readAsBytes();
                          final file = File(targetPath);
                          await file.writeAsBytes(bytes);

                          setState(() {
                            selectedImage = file;
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error memilih gambar: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pilih Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tombol aksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Batal'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                          if (selectedPakaian == null || selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih tarian dan foto terlebih dahulu!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                'Apakah Anda yakin ingin mengganti foto tarian ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Ya, Simpan'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              setState(() {
                                isLoading = true;
                              });

                              // Pastikan viewModel.updateFoto dapat menerima File
                              await viewModel.updateFoto(
                                  selectedPakaian!.id,
                                  selectedImage!,
                                  sukuId,
                                  'tarian'
                              );

                              Navigator.pop(context, true);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Foto berhasil diperbarui'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal memperbarui foto: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.brown[700],
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showTarianDetail(BuildContext context, TarianTradisional tarian) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: CustomScrollView(
            slivers: [
              // App bar with image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        tarian.foto,
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay for text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    tarian.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Colors.brown[700],
                actions: [
                  // IconButton(
                  //   icon: Icon(Icons.share),
                  //   onPressed: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text('Bagikan tarian ${tarian.nama}'),
                  //         behavior: SnackBarBehavior.floating,
                  //       ),
                  //     );
                  //   },
                  // ),
                  // IconButton(
                  //   icon: Icon(Icons.favorite_border),
                  //   onPressed: () {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         content: Text('Ditambahkan ke favorit'),
                  //         behavior: SnackBarBehavior.floating,
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and subtitle
                      Text(
                        tarian.nama,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.brown[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Tarian Tradisional Indonesia",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Info chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoChip(Icons.groups, tarian.kategori),
                          _buildInfoChip(Icons.timer, tarian.durasi),
                          _buildInfoChip(Icons.event, tarian.event),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Sections
                      _buildSection(
                        "Deskripsi",
                        tarian.deskripsi,
                      ),

                      _buildSection(
                        "Sejarah",
                        tarian.sejarah
                      ),

                      _buildSection(
                        "Gerakan dan Makna",
                        tarian.gerakan
                      ),

                      _buildSection(
                        "Kostum dan Perlengkapan",
                        tarian.kostum
                      ),

                      SizedBox(height: 20),

                      // Interactive elements
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.brown[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tahukah Anda?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown[800],
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Tarian ini telah diakui oleh UNESCO sebagai warisan budaya tak benda. Dilestarikan secara turun-temurun, tarian ini menjadi identitas budaya yang kuat bagi masyarakat setempat.",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.brown[700],
                              ),
                            ),
                            SizedBox(height: 16),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.brown[700]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                _showVideoPreview(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.brown[700],
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Tonton Video Tarian",
                                    style: TextStyle(
                                      color: Colors.brown[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Related tarian
                      // Text(
                      //   "Tarian Terkait Lainnya",
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.brown[800],
                      //   ),
                      // ),
                      // SizedBox(height: 16),
                      // Container(
                      //   height: 180,
                      //   child: ListView.builder(
                      //     scrollDirection: Axis.horizontal,
                      //     itemCount: 3,
                      //     itemBuilder: (context, index) {
                      //       return Container(
                      //         width: 160,
                      //         margin: EdgeInsets.only(right: 12),
                      //         decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(12),
                      //           boxShadow: [
                      //             BoxShadow(
                      //               color: Colors.black.withOpacity(0.1),
                      //               blurRadius: 5,
                      //               offset: Offset(0, 2),
                      //             ),
                      //           ],
                      //         ),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             ClipRRect(
                      //               borderRadius: BorderRadius.circular(12),
                      //               child: Image.network(
                      //                 tarian.foto, // Placeholder, would use other images in real app
                      //                 height: 110,
                      //                 width: 160,
                      //                 fit: BoxFit.cover,
                      //               ),
                      //             ),
                      //             Padding(
                      //               padding: EdgeInsets.all(8),
                      //               child: Column(
                      //                 crossAxisAlignment: CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     "Tarian ${index + 1}",
                      //                     style: TextStyle(
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 14,
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 4),
                      //                   Text(
                      //                     "Tarian Tradisional",
                      //                     style: TextStyle(
                      //                       fontSize: 12,
                      //                       color: Colors.grey[600],
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // bottomNavigationBar: BottomAppBar(
          //   color: Colors.white,
          //   elevation: 8,
          //   child: Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //     child: Row(
          //       children: [
          //         Expanded(
          //           child: OutlinedButton(
          //             style: OutlinedButton.styleFrom(
          //               side: BorderSide(color: Colors.brown[700]!),
          //               padding: EdgeInsets.symmetric(vertical: 12),
          //             ),
          //             onPressed: () {
          //               Navigator.of(context).pop();
          //             },
          //             child: Text(
          //               "Kembali",
          //               style: TextStyle(
          //                 color: Colors.brown[700],
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //         SizedBox(width: 16),
          //         Expanded(
          //           child: ElevatedButton(
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.brown[700],
          //               padding: EdgeInsets.symmetric(vertical: 12),
          //             ),
          //             onPressed: () {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 SnackBar(
          //                   content: Text('Berbagi informasi tarian ${tarian.nama}'),
          //                   behavior: SnackBarBehavior.floating,
          //                 ),
          //               );
          //             },
          //             child: Text(
          //               "Bagikan",
          //               style: TextStyle(
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        // ),
      // ),
        ),
      ),
    );
  }



  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.brown[700],
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.brown[700],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Video Preview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fitur ini akan tersedia segera. Kami sedang mengembangkan kemampuan untuk menampilkan video tarian tradisional.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      minimumSize: Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Tutup",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showFilterOptions(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: EdgeInsets.all(24),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   "Filter Tarian Tradisional",
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.teal[800],
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () {
  //                     Navigator.pop(context);
  //                   },
  //                 ),
  //               ],
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               "Kategori Tarian",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.teal[700],
  //               ),
  //             ),
  //             SizedBox(height: 12),
  //             Wrap(
  //               spacing: 10,
  //               runSpacing: 10,
  //               children: [
  //                 _buildFilterChip("Semua"),
  //                 _buildFilterChip("Seremonial"),
  //                 _buildFilterChip("Penyambutan"),
  //                 _buildFilterChip("Ritual"),
  //                 _buildFilterChip("Pertunjukan"),
  //               ],
  //             ),
  //             SizedBox(height: 20),
  //             Text(
  //               "Jumlah Penari",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.teal[700],
  //               ),
  //             ),
  //             SizedBox(height: 12),
  //             Wrap(
  //               spacing: 10,
  //               runSpacing: 10,
  //               children: [
  //                 _buildFilterChip("Tunggal"),
  //                 _buildFilterChip("Berpasangan"),
  //                 _buildFilterChip("Kelompok Kecil"),
  //                 _buildFilterChip("Kelompok Besar"),
  //               ],
  //             ),
  //             SizedBox(height: 24),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: OutlinedButton(
  //                     style: OutlinedButton.styleFrom(
  //                       side: BorderSide(color: Colors.teal[700]!),
  //                       padding: EdgeInsets.symmetric(vertical: 12),
  //                     ),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                     },
  //                     child: Text(
  //                       "Reset",
  //                       style: TextStyle(
  //                         color: Colors.teal[700],
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 16),
  //                 Expanded(
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.teal[700],
  //                       padding: EdgeInsets.symmetric(vertical: 12),
  //                     ),
  //                     onPressed: () {
  //                       Navigator.pop(context);
  //                       ScaffoldMessenger.of(context).showSnackBar(
  //                         SnackBar(
  //                           content: Text('Filter diterapkan'),
  //                           behavior: SnackBarBehavior.floating,
  //                         ),
  //                       );
  //                     },
  //                     child: Text(
  //                       "Terapkan",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _buildFilterChip(String label) {
  //   return FilterChip(
  //     label: Text(label),
  //     backgroundColor: Colors.grey[100],
  //     selectedColor: Colors.teal[100],
  //     checkmarkColor: Colors.teal[700],
  //     side: BorderSide(color: Colors.teal[100]!),
  //     labelStyle: TextStyle(fontSize: 13),
  //     selected: label == "Semua",
  //     onSelected: (selected) {
  //       // Handle selection in real app
  //     },
  //   );
  // }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Tentang Tarian Tradisional",
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tarian tradisional adalah bagian penting dari warisan budaya Indonesia. Setiap tarian memiliki keunikan dan nilai filosofis yang mencerminkan kearifan lokal dan identitas budaya.",
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.teal[700],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Semua konten dan informasi tarian disediakan untuk tujuan pendidikan dan pelestarian budaya.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Tutup",
              style: TextStyle(
                color: Colors.teal[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}