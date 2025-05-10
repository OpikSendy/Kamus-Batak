import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kbb/models/kuliner_tradisional.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import '../viewmodel/kuliner_tradisional_viewmodel.dart';

class KulinerTradisionalDetailScreen extends StatefulWidget {
  const KulinerTradisionalDetailScreen({super.key});

  @override
  KulinerTradisionalState createState() => KulinerTradisionalState();
}

class KulinerTradisionalState extends State<KulinerTradisionalDetailScreen> {
  final String _searchQuery = '';
  final String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
      if (sukuId != null) {
        Provider.of<KulinerTradisionalViewModel>(context, listen: false).fetchKulinerList(sukuId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              pinned: true,
              backgroundColor: Colors.red[800],
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "Kuliner Tradisional",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://example.com/kuliner_background.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange[800]!,
                                Colors.red[800]!,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 70,
                              color: Colors.white30,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 138,
                      left: 250,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Cita Rasa Tradisional",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Container(
                //   width: 140,
                //   padding: EdgeInsets.symmetric(vertical: 10),
                //   child: TextField(
                //     onChanged: (value) {
                //       setState(() {
                //         _searchQuery = value;
                //       });
                //     },
                //     style: TextStyle(color: Colors.white),
                //     decoration: InputDecoration(
                //       hintText: 'Cari kuliner...',
                //       hintStyle: TextStyle(color: Colors.white70),
                //       border: InputBorder.none,
                //       prefixIcon: Icon(Icons.search, color: Colors.white),
                //       contentPadding: EdgeInsets.symmetric(vertical: 0),
                //     ),
                //   ),
                // ),
                // IconButton(
                //   icon: Icon(Icons.filter_list, color: Colors.white),
                //   onPressed: () {
                //     _showFilterDialog(context);
                //   },
                // ),
              ],
            ),
          ];
        },
        body: Consumer<KulinerTradisionalViewModel>(
          builder: (context, viewModel, child) {
            final filteredList = viewModel.kulinerList.where((kuliner) {
              final matchesSearch = kuliner.nama.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchesFilter = _selectedFilter == 'Semua' || kuliner.jenis.toLowerCase() == _selectedFilter.toLowerCase();
              return matchesSearch && matchesFilter;
            }).toList();
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Memuat daftar kuliner tradisional...',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            } else if (viewModel.kulinerList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_food,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Tidak ada data kuliner tradisional.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Coba periksa kembali nanti.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.red[800],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'DAFTAR KULINER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey[800],
                          ),
                        ),
                        Spacer(),
                        Text(
                          '${filteredList.length} item',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Jelajahi rasa otentik makanan dan minuman tradisional',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 16.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final kuliner = filteredList[index];
                          return _buildKulinerCard(context, kuliner);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
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

          final viewModel = Provider.of<KulinerTradisionalViewModel>(context, listen: false);

          if (viewModel.kulinerList.isEmpty) {
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
              await viewModel.fetchKulinerListBySukuId(sukuId);
              // Tutup dialog loading
              Navigator.pop(context);

              // Jika masih kosong setelah fetch, tampilkan pesan
              if (viewModel.kulinerList.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tidak ada data pakaian tradisional untuk suku ini'),
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
                  content: Text('Gagal memuat data pakaian: ${e.toString()}'),
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
            pakaianList: viewModel.kulinerList,
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
    required List<KulinerTradisional> pakaianList,
    required int sukuId,
    required KulinerTradisionalViewModel viewModel,
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
        await viewModel.fetchKulinerListBySukuId(sukuId);
        // Tutup dialog loading
        Navigator.pop(context);

        // Jika masih kosong setelah fetch, tampilkan pesan
        if (viewModel.kulinerList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada data pakaian tradisional untuk suku ini'),
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
            content: Text('Gagal memuat data pakaian: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return; // Keluar dari fungsi jika terjadi error
      }
    }

    final picker = ImagePicker();
    KulinerTradisional? selectedPakaian;
    File? selectedImage;
    bool isLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Mencegah dialog ditutup dengan tap di luar
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          // Gunakan pakaianList terbaru dari viewModel
          final updatedPakaianList = viewModel.kulinerList;

          // Debug print untuk memeriksa data
          print('Jumlah pakaian tradisional: ${updatedPakaianList.length}');
          if (updatedPakaianList.isNotEmpty) {
            print('Contoh pakaian pertama: ${updatedPakaianList[0].nama}');
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
                        'Update Foto Pakaian',
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
                  DropdownButtonFormField<KulinerTradisional>(
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
                    hint: const Text('Pilih pakaian tradisional'),
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
                                content: Text('Pilih pakaian dan foto terlebih dahulu!'),
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
                                'Apakah Anda yakin ingin mengganti foto pakaian ini?',
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
                                  'kuliner'
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


  Widget _buildKulinerCard(BuildContext context, dynamic kuliner) {
    Color tagColor = kuliner.jenis == 'makanan' ? Colors.green[700]! : Colors.blue[700]!;
    String tagText = kuliner.jenis == 'makanan' ? 'MAKANAN KHAS' : 'MINUMAN KHAS';

    return Card(
      margin: EdgeInsets.only(bottom: 20.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kuliner image with tag
          Stack(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Image.network(
                  kuliner.foto,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[800]!),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(
                        kuliner.jenis == 'makanan' ? Icons.restaurant : Icons.local_drink,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),

              // Tag
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tagText,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),

              // Gradient overlay on bottom for better text visibility
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
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
                bottom: 12,
                left: 16,
                right: 16,
                child: Text(
                  kuliner.nama,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Description
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      kuliner.jenis == 'makanan' ? Icons.restaurant_menu : Icons.local_bar,
                      size: 18,
                      color: tagColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      kuliner.jenis == 'makanan' ? 'Makanan Tradisional' : 'Minuman Tradisional',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: tagColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
                Text(
                  kuliner.deskripsi,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    _buildInfoChip(Icons.star, kuliner.rating, Colors.amber),
                    SizedBox(width: 12),
                    _buildInfoChip(Icons.access_time, kuliner.waktu, Colors.blue[700]!),
                  ],
                ),
                SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: () {
                    // _showResep(context, kuliner);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur resep akan segera hadir!'),
                        backgroundColor: Colors.orange[800],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.orange[800]!),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 18,
                        color: Colors.orange[800],
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Lihat Resep',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // void _showFilterDialog(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.all(20),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text(
  //                   'Filter Jenis Kuliner',
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.grey[800],
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
  //             SizedBox(height: 12),
  //             Wrap(
  //               spacing: 8,
  //               children: ['Semua', 'makanan', 'minuman'].map((filter) {
  //                 return ChoiceChip(
  //                   label: Text(filter.toUpperCase()),
  //                   selected: _selectedFilter == filter,
  //                   selectedColor: Colors.orange[800],
  //                   onSelected: (selected) {
  //                     setState(() {
  //                       _selectedFilter = filter;
  //                     });
  //                     Navigator.pop(context);
  //                   },
  //                 );
  //               }).toList(),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showResep(BuildContext context, KulinerTradisional kuliner) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.red[700],
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(
  //                   Icons.info_outline,
  //                   color: Colors.white,
  //                   size: 24,
  //                 ),
  //                 SizedBox(width: 8),
  //                 Text(
  //                   "Resep ${kuliner.nama}",
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               children: [
  //                 Text(
  //                   kuliner.resep,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     height: 1.5,
  //                     color: Colors.grey[800],
  //                   ),
  //                 ),
  //                 SizedBox(height: 16),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.red[700],
  //                     minimumSize: Size(double.infinity, 45),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text(
  //                     "Tutup",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.bold,
  //                       fontSize: 16,
  //                     )
  //                     ,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFilterOption(String label, bool isSelected) {
  //   return Chip(
  //     label: Text(
  //       label,
  //       style: TextStyle(
  //         color: isSelected ? Colors.white : Colors.grey[800],
  //         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //       ),
  //     ),
  //     backgroundColor: isSelected ? Colors.orange[800] : Colors.grey[200],
  //     padding: EdgeInsets.symmetric(horizontal: 12),
  //   );
  // }

  // void _showSearchDialog(BuildContext context) {
  //   TextEditingController searchController = TextEditingController(text: _searchQuery);
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('Cari Kuliner'),
  //         content: TextField(
  //           controller: searchController,
  //           decoration: InputDecoration(hintText: 'Masukkan nama kuliner'),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('Batal'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 _searchQuery = searchController.text;
  //               });
  //               Navigator.pop(context);
  //             },
  //             child: Text('Cari'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

}