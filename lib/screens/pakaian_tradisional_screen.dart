import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kbb/screens/add/add_pakaian_tradisional_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import '../viewmodel/pakaian_tradisional_viewmodel.dart';
import '../models/pakaian_tradisional.dart';
// Import KomentarViewModel dan Komentar model
import '../viewmodel/komentar_viewmodel.dart'; // Sesuaikan path jika berbeda
import '../models/komentar.dart'; // Sesuaikan path jika berbeda

class PakaianTradisionalDetailScreen extends StatefulWidget {
  const PakaianTradisionalDetailScreen({super.key});

  @override
  State<PakaianTradisionalDetailScreen> createState() => _PakaianTradisionalDetailScreenState();
}

class _PakaianTradisionalDetailScreenState extends State<PakaianTradisionalDetailScreen> {
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
      create: (_) => PakaianTradisionalViewModel()..fetchPakaianList(sukuId),
      child: Consumer<PakaianTradisionalViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildLoadingScaffold();
          } else if (viewModel.pakaianList.isEmpty) {
            return _buildEmptyScaffold();
          } else {
            return _buildPakaianScaffold(viewModel.pakaianList);
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
          "Pakaian Tradisional",
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
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
            ),
            SizedBox(height: 20),
            Text(
              'Memuat pakaian tradisional...',
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
          "Pakaian Tradisional",
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
        backgroundColor: Colors.teal[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "Tidak ada data pakaian tradisional",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Informasi pakaian tradisional belum tersedia",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
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
        backgroundColor: Colors.teal[700],
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
                backgroundColor: Colors.teal[700],
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

  Widget _buildPakaianScaffold(List<PakaianTradisional> pakaianList) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Pakaian Tradisional",
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.teal[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white,),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with total count
          Container(
            color: Colors.teal[700],
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                Icon(
                  Icons.checkroom,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "Ditemukan ${pakaianList.length} pakaian tradisional",
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
              itemCount: pakaianList.length,
              itemBuilder: (context, index) {
                final pakaian = pakaianList[index];
                return GestureDetector(
                  onTap: () {
                    _showPakaianDetail(context, pakaian);
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
                                pakaian.foto,
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
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
                                pakaian.nama,
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
                                  color: Colors.teal[700]!.withOpacity(0.8),
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
                                  color: Colors.teal[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.teal[100]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.teal[700],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Pakaian Tradisional",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.teal[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 12),

                              // Description with limited lines
                              Text(
                                pakaian.deskripsi,
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
                                      _buildFeatureChip(Icons.style, pakaian.feature1),
                                      _buildFeatureChip(Icons.event, pakaian.feature2),
                                    ],
                                  ),

                                  Spacer(),

                                  TextButton(
                                    onPressed: () {
                                      _showPakaianDetail(context, pakaian);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.teal[700],
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
      // TAMBAHKAN FLOATING ACTION BUTTON INI
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
          if (sukuId != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPakaianTradisionalScreen(sukuId: sukuId),
              ),
            );

            // Refresh list setelah kembali
            if (mounted) {
              Provider.of<PakaianTradisionalViewModel>(context, listen: false)
                  .fetchPakaianList(sukuId);
            }
          }
        },
        backgroundColor: Colors.teal[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah Pakaian',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  // Fungsi untuk menampilkan dialog informasi
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.teal[700]),
              SizedBox(width: 10),
              Text(
                "Informasi Pakaian Tradisional",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "Bagian ini menampilkan daftar pakaian tradisional yang terkait dengan suku yang dipilih.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Text(
                  "Setiap kartu pakaian menampilkan nama, foto, deskripsi singkat, serta fitur-fitur penting. Anda bisa mengetuk kartu untuk melihat detail lengkap pakaian tersebut.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                SizedBox(height: 10),
                Text(
                  "Pada halaman detail, Anda dapat menemukan informasi lebih rinci seperti sejarah, bahan, motif, kelengkapan, dan aksesoris.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Tutup",
                style: TextStyle(color: Colors.teal[700], fontWeight: FontWeight.bold),
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

  // Fungsi untuk membuat chip fitur
  Widget _buildFeatureChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.teal[700],
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.teal[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showPakaianDetail(BuildContext context, PakaianTradisional pakaian) {
    // Saat detail pakaian dibuka, muat komentar untuk pakaian ini
    _komentarViewModel.fetchComments(itemId: pakaian.id!, itemType: 'pakaian_tradisional');

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
                        pakaian.foto,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[700]!),
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey[400],
                                size: 60,
                              ),
                            ),
                          );
                        },
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
                    pakaian.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
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
                backgroundColor: Colors.teal[700],
                actions: const [], // Bisa ditambahkan aksi lain jika diperlukan
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and subtitle
                      Text(
                        pakaian.nama,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.teal[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Pakaian Tradisional Indonesia",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Info chips
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoChip(Icons.style, "Jenis", pakaian.feature1),
                          _buildInfoChip(Icons.event, "Acara", pakaian.feature2),
                          _buildInfoChip(Icons.auto_awesome, "Status", pakaian.feature3),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sections
                      _buildSection(
                        "Deskripsi",
                        pakaian.deskripsi,
                      ),

                      _buildSection(
                          "Sejarah",
                          pakaian.sejarah
                      ),

                      _buildSection(
                          "Bahan dan Motif",
                          pakaian.bahan
                      ),

                      _buildSection(
                          "Kelengkapan dan Aksesoris",
                          pakaian.kelengkapan
                      ),

                      const SizedBox(height: 20),

                      // Interactive elements
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.teal[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tahukah Anda?",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Pakaian ini telah menjadi warisan budaya tak benda yang diakui secara nasional. Dilestarikan secara turun-temurun, pakaian ini menjadi identitas budaya yang kuat bagi masyarakat setempat.",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.teal[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Bagian Komentar ---
                      const Divider(height: 32, thickness: 1),
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.teal[700],
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
                      _buildCommentForm(pakaian.id!, 'pakaian_tradisional'), // ID pakaian dan itemType

                      const SizedBox(height: 24),

                      // Daftar Komentar
                      Consumer<KomentarViewModel>(
                        builder: (context, komentarViewModel, child) {
                          // Filter komentar untuk pakaian tradisional yang sedang dilihat
                          final relevantComments = komentarViewModel.comments
                              .where((k) => k.itemId == pakaian.id && k.itemType == 'pakaian_tradisional')
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
                                  'Belum ada komentar yang disetujui untuk pakaian ini.',
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
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk chip informasi detail (Jenis, Acara, Status)
  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.teal[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal[900],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Widget untuk setiap bagian deskripsi
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.teal[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
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
                  backgroundColor: Colors.teal[700], // Warna disesuaikan dengan tema pakaian tradisional
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