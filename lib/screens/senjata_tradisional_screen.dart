import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kbb/screens/add/add_senjata_tradisional_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import '../viewmodel/senjata_tradisional_viewmodel.dart';
import '../models/senjata_tradisional.dart';
// Import KomentarViewModel dan Komentar model
import '../viewmodel/komentar_viewmodel.dart'; // Sesuaikan path jika berbeda
import '../models/komentar.dart'; // Sesuaikan path jika berbeda

class SenjataTradisionalDetailScreen extends StatefulWidget {
  const SenjataTradisionalDetailScreen({super.key});

  @override
  State<SenjataTradisionalDetailScreen> createState() =>
      _SenjataTradisionalDetailScreenState();
}

class _SenjataTradisionalDetailScreenState
    extends State<SenjataTradisionalDetailScreen> {
  int _selectedSenjataIndex = 0;
  final PageController _pageController = PageController();

  // Tambahkan TextEditingController untuk komentar
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Tambahkan KomentarViewModel
  late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Inisialisasi KomentarViewModel
      _komentarViewModel = Provider.of<KomentarViewModel>(context, listen: false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Fungsi untuk mengirim komentar
  void _submitComment({required int itemId, required String itemType}) async {
    if (_commentController.text.trim().isEmpty) {
      _showSnackBar('Komentar tidak boleh kosong!', isError: true);
      return;
    }

    final String namaAnonim = _nameController.text.trim().isEmpty ? 'Anonim' : _nameController.text.trim();
    final String komentarText = _commentController.text.trim();

    try {
      await _komentarViewModel.addComment(
        itemId: itemId,
        itemType: itemType,
        namaAnonim: namaAnonim,
        komentarText: komentarText,
      );
      _showSnackBar('Komentar berhasil dikirim! Menunggu persetujuan admin.');
      _commentController.clear();
      _nameController.clear();
      // Perbarui daftar komentar untuk item ini setelah komentar berhasil dikirim
      _komentarViewModel.fetchComments(itemId: itemId, itemType: itemType);
    } catch (e) {
      _showSnackBar('Gagal mengirim komentar: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;

    if (sukuId == null) {
      return _buildErrorScaffold('Error', 'ID Suku tidak valid');
    }

    return ChangeNotifierProvider(
      create: (_) => SenjataTradisionalViewModel()..fetchSenjataList(sukuId),
      child: Consumer<SenjataTradisionalViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildLoadingScaffold();
          } else if (viewModel.senjataList.isEmpty) {
            return _buildEmptyScaffold();
          } else {
            return _buildSenjataScaffold(context, viewModel);
          }
        },
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Senjata Tradisional",
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
        backgroundColor: Colors.red[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
            ),
            SizedBox(height: 20),
            Text(
              'Memuat senjata tradisional...',
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
          "Senjata Tradisional",
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
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "Tidak ada data senjata tradisional",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Informasi senjata tradisional belum tersedia",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
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
        backgroundColor: Colors.red[700],
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
                backgroundColor: Colors.red[700],
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

  Widget _buildSenjataScaffold(
      BuildContext context, SenjataTradisionalViewModel viewModel) {
    // Muat komentar untuk senjata tradisional yang sedang aktif saat ini
    // Pastikan ini dipanggil setiap kali _selectedSenjataIndex berubah
    // atau saat screen pertama kali dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.senjataList.isNotEmpty) {
        final currentSenjata = viewModel.senjataList[_selectedSenjataIndex];
        _komentarViewModel.fetchComments(itemId: currentSenjata.id!, itemType: 'senjata_tradisional');
      }
    });

    return Scaffold(
      backgroundColor: Colors.red[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Senjata Tradisional",
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.share),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text("Berbagi informasi senjata tradisional"),
          //         behavior: SnackBarBehavior.floating,
          //         backgroundColor: Colors.red[700],
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: Column(
        children: [
          // Large page view for senjata images
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              itemCount: viewModel.senjataList.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedSenjataIndex = index;
                  // Muat komentar untuk senjata tradisional yang baru dipilih
                  final currentSenjata = viewModel.senjataList[_selectedSenjataIndex];
                  _komentarViewModel.fetchComments(itemId: currentSenjata.id!, itemType: 'senjata_tradisional');
                });
              },
              itemBuilder: (context, index) {
                final senjata = viewModel.senjataList[index];
                return Hero(
                  tag: 'senjata-tradisional-${senjata.id}',
                  child: GestureDetector(
                    onTap: () {
                      _showFullScreenImage(context, senjata);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              senjata.foto,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                      loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          loadingProgress
                                              .expectedTotalBytes!
                                          : null,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.red[700]!),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          size: 64,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          "Gagal memuat gambar",
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Bottom gradient overlay for text visibility
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Image title at bottom
                            Positioned(
                              bottom: 30,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    senjata.nama,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 3.0,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.history,
                                        color: Colors.white70,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Senjata Tradisional",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Zoom indicator
                            Positioned(
                              top: 100,
                              right: 20,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Perbesar",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Page indicator
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                viewModel.senjataList.length,
                    (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _selectedSenjataIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _selectedSenjataIndex == index
                        ? Colors.red[700]
                        : Colors.red[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Description section
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and action buttons row
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.gavel,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            viewModel.senjataList[_selectedSenjataIndex].nama,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                        ),
                        // _buildFavoriteButton(),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Features section
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildFeatureChip(Icons.history, "Sejarah"),
                        _buildFeatureChip(Icons.handyman, "Kerajinan"),
                        _buildFeatureChip(Icons.school, "Budaya"),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Detailed description
                    Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      viewModel.senjataList[_selectedSenjataIndex].deskripsi,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Functions section
                    Text(
                      "Fungsi dan Kegunaan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[100]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFunctionItem("Pertahanan", viewModel.senjataList[_selectedSenjataIndex].pertahanan),
                          SizedBox(height: 12),
                          _buildFunctionItem("Perburuan", viewModel.senjataList[_selectedSenjataIndex].perburuan),
                          SizedBox(height: 12),
                          _buildFunctionItem("Seremonial", viewModel.senjataList[_selectedSenjataIndex].seremonial),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Additional information
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.red[700]!,
                            Colors.red[900]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tahukah Anda?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Senjata tradisional ini memiliki nilai filosofis yang melambangkan keberanian dan kekuatan. Proses pembuatannya memerlukan keahlian khusus dan sering disertai dengan ritual tertentu.",
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              _showDetailedInfo(context,
                                  viewModel.senjataList[_selectedSenjataIndex]);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Pelajari lebih lanjut",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // --- Bagian Komentar ---
                    const Divider(height: 32, thickness: 1),
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red[700], // Sesuaikan warna tema
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'KOMENTAR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Form untuk menambahkan komentar
                    _buildCommentForm(viewModel.senjataList[_selectedSenjataIndex].id!, 'senjata_tradisional'), // ID senjata dan itemType

                    const SizedBox(height: 24),

                    // Daftar Komentar
                    Consumer<KomentarViewModel>(
                      builder: (context, komentarViewModel, child) {
                        // Filter komentar untuk senjata tradisional yang sedang dilihat
                        final currentSenjataId = viewModel.senjataList[_selectedSenjataIndex].id;
                        final relevantComments = komentarViewModel.comments
                            .where((k) => k.itemId == currentSenjataId && k.itemType == 'senjata_tradisional')
                            .toList();

                        if (komentarViewModel.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (komentarViewModel.errorMessage != null) {
                          return Center(
                            child: Text(
                              'Gagal memuat komentar: ${komentarViewModel.errorMessage}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        if (relevantComments.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Belum ada komentar yang disetujui untuk senjata tradisional ini.',
                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: relevantComments.length,
                          itemBuilder: (context, index) {
                            final komentar = relevantComments[index];
                            return _buildCommentCard(komentar);
                          },
                        );
                      },
                    ),
                    // --- Akhir Bagian Komentar ---
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
          if (sukuId != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddSenjataTradisionalScreen(sukuId: sukuId),
              ),
            );

            // Refresh list setelah kembali
            if (mounted) {
              viewModel.fetchSenjataList(sukuId);
            }
          }
        },
        backgroundColor: Colors.red[800],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Senjata',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget untuk tombol favorit (contoh, tidak fungsional di sini)
  // Widget _buildFavoriteButton() {
  //   return IconButton(
  //     icon: Icon(Icons.favorite_border, color: Colors.red[700]),
  //     onPressed: () {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text("Fitur favorit belum diimplementasikan"),
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Colors.red[700],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget untuk chip fitur
  Widget _buildFeatureChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, color: Colors.red[700], size: 18),
      label: Text(
        text,
        style: TextStyle(color: Colors.red[700], fontSize: 13),
      ),
      backgroundColor: Colors.red[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.red[200]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  // Widget untuk item fungsi dan kegunaan
  Widget _buildFunctionItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.military_tech, color: Colors.red[700], size: 18),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Dialog untuk informasi
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red[700]),
              SizedBox(width: 10),
              Text(
                "Informasi Senjata",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Bagian ini menampilkan detail lengkap tentang senjata tradisional terpilih.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Text(
                  "Anda bisa menggeser gambar di bagian atas untuk melihat foto-foto lain dari senjata ini (jika tersedia).",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Text(
                  "Informasi detail mencakup deskripsi, fungsi, dan poin-poin penting lainnya.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Tutup",
                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan gambar full screen
  void _showFullScreenImage(BuildContext context, SenjataTradisional senjata) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'senjata-tradisional-${senjata.id}',
                  child: Image.network(
                    senjata.foto,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.red[700]!),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 80,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan informasi detail lebih lanjut
  void _showDetailedInfo(BuildContext context, SenjataTradisional senjata) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      senjata.nama,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.red[700], size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Senjata Tradisional ${senjata.nama}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildDetailedSection("Sejarah Asal-usul", senjata.sejarah),
                    _buildDetailedSection("Bahan dan Pembuatan", senjata.material),
                    _buildDetailedSection("Penggunaan dalam Adat", senjata.simbol),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Widget untuk setiap bagian detail di bottom sheet
  Widget _buildDetailedSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // Widget untuk form komentar
  Widget _buildCommentForm(int itemId, String itemType) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tinggalkan Komentar Anda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama (opsional)',
                hintText: 'Misal: Anonim',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Komentar Anda',
                hintText: 'Tulis komentar Anda di sini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _submitComment(itemId: itemId, itemType: itemType),
                icon: const Icon(Icons.send),
                label: const Text('Kirim Komentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700], // Warna disesuaikan dengan tema
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk card komentar
  Widget _buildCommentCard(Komentar komentar) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.grey, size: 28),
                const SizedBox(width: 8),
                Text(
                  komentar.namaAnonim,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey[900],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(komentar.tanggalKomentar),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              komentar.komentarText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi format tanggal
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}