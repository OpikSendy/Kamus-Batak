import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:kbb/viewmodel/suku_viewmodel.dart';
import '../models/suku.dart';

class SukuScreen extends StatefulWidget {
  const SukuScreen({super.key});

  @override
  SukuScreenState createState() => SukuScreenState();
}

class SukuScreenState extends State<SukuScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
    if (sukuId == null) {
      return _buildErrorScaffold('Error', 'ID Suku tidak valid');
    }

    return Consumer<SukuViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Memuat informasi suku...',
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

        // Find the suku with matching ID
        Suku? suku;
        try {
          suku = viewModel.sukuList.firstWhere((s) => s.id == sukuId);
        } catch (e) {
          // Handle case where suku is not found
          return _buildErrorScaffold('Error', 'Suku tidak ditemukan');
        }

        return Scaffold(
          body: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // Beautiful App Bar with image
              SliverAppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                pinned: true,
                expandedHeight: 250.0,
                backgroundColor: Colors.red[800],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    suku.nama,
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
                  background: Hero(
                    tag: 'suku-image-${suku.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          suku.foto,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.broken_image, size: 64, color: Colors.grey[600]),
                            );
                          },
                        ),
                        // Gradient overlay for better text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Implementasi fitur berbagi
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: () {
                      // Implementasi fitur bookmark/save
                    },
                  ),
                ],
              ),

              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info card
                      Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tentang ${suku.nama}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Suku ${suku.nama} adalah salah satu suku Batak yang memiliki kebudayaan dan tradisi yang kaya. Mari jelajahi berbagai aspek budaya suku ${suku.nama} melalui kategori di bawah ini.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[900],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.0),

                      // Categories header
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red[800],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'KATEGORI BUDAYA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6.0),
                      Text(
                        'Telusuri berbagai aspek budaya suku ${suku.nama}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),

              // Grid view of categories
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildCategoryCard(
                      context,
                      icon: Icons.people,
                      title: 'Marga',
                      subtitle: 'Sistem kekerabatan',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, '/marga-detail', arguments: sukuId);
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.accessibility_new,
                      title: 'Pakaian Adat',
                      subtitle: 'Busana tradisional',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pushNamed(context, '/pakaian-tradisional-detail', arguments: sukuId);
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.restaurant,
                      title: 'Kuliner',
                      subtitle: 'Masakan khas',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pushNamed(context, '/kuliner-tradisional-detail', arguments: sukuId);
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.gavel,
                      title: 'Senjata',
                      subtitle: 'Peralatan perang',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pushNamed(context, '/senjata-tradisional-detail', arguments: sukuId);
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.directions_run,
                      title: 'Tarian',
                      subtitle: 'Gerakan tradisional',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.pushNamed(context, '/tarian-tradisional-detail', arguments: sukuId);
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.home,
                      title: 'Rumah Adat',
                      subtitle: 'Arsitektur tradisional',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pushNamed(context, '/rumah-adat-detail', arguments: sukuId);
                      },
                    ),
                  ]),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red[800],
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

              final viewModel = Provider.of<SukuViewModel>(context, listen: false);

              if (viewModel.sukuList.isEmpty) {
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
                  await viewModel.fetchSukuListById(sukuId);
                  // Tutup dialog loading
                  Navigator.pop(context);

                  // Jika masih kosong setelah fetch, tampilkan pesan
                  if (viewModel.sukuList.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tidak ada data suku tradisional untuk suku ini'),
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
                      content: Text('Gagal memuat data senjata: ${e.toString()}'),
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
                pakaianList: viewModel.sukuList,
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
      },
    );
  }

  Future<void> showUpdateFotoDialog({
    required BuildContext context,
    required List<Suku> pakaianList,
    required int sukuId,
    required SukuViewModel viewModel,
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
        await viewModel.fetchSukuListById(sukuId);
        // Tutup dialog loading
        Navigator.pop(context);

        // Jika masih kosong setelah fetch, tampilkan pesan
        if (viewModel.sukuList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data Suku untuk suku ini'),
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
            content: Text('Gagal memuat data suku: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return; // Keluar dari fungsi jika terjadi error
      }
    }

    final picker = ImagePicker();
    Suku? selectedPakaian;
    File? selectedImage;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dialog ditutup dengan tap di luar
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // Gunakan pakaianList terbaru dari viewModel
          final updatedPakaianList = viewModel.sukuList;

          // Debug print untuk memeriksa data
          print('Jumlah suku: ${updatedPakaianList.length}');
          if (updatedPakaianList.isNotEmpty) {
            print('Contoh suku pertama: ${updatedPakaianList[0].nama}');
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
                        'Update Foto Suku',
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
                  DropdownButtonFormField<Suku>(
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
                    hint: const Text('Pilih suku'),
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
                                content: Text('Pilih suku dan foto terlebih dahulu!'),
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
                                'Apakah Anda yakin ingin mengganti foto suku ini?',
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
                                  'suku'
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

  Widget _buildCategoryCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32.0,
                  color: color,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String title, String message) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red[800],
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
                backgroundColor: Colors.red[800],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Kembali ke Beranda',
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
}