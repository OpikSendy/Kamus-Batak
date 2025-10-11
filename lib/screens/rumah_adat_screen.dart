// lib/screens/rumah_adat_detail_screen.dart - UPDATED WITH RESPONSIVE DESIGN

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/rumah_adat_viewmodel.dart';
import '../models/rumah_adat.dart';
import '../viewmodel/komentar_viewmodel.dart';
import '../models/komentar.dart';
import 'add/add_rumah_adat_screen.dart';

class RumahAdatDetailScreen extends StatefulWidget {
  const RumahAdatDetailScreen({super.key});

  @override
  State<RumahAdatDetailScreen> createState() => _RumahAdatDetailScreenState();
}

class _RumahAdatDetailScreenState extends State<RumahAdatDetailScreen> {
  int _selectedRumahIndex = 0;
  final PageController _pageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

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
      _komentarViewModel.fetchComments(itemId: itemId, itemType: itemType);
    } catch (e) {
      _showSnackBar('Gagal mengirim komentar: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    if (sukuId == null) {
      return _buildErrorScaffold('Error', 'ID Suku tidak valid');
    }

    return ChangeNotifierProvider(
      create: (_) => RumahAdatViewModel()..fetchRumahAdatList(sukuId),
      child: Consumer<RumahAdatViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildLoadingScaffold();
          } else if (viewModel.rumahAdatList.isEmpty) {
            return _buildEmptyScaffold(sukuId, isSmallScreen);
          } else {
            return _buildRumahAdatScaffold(context, viewModel, sukuId, isSmallScreen);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Rumah Adat",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
            ),
            SizedBox(height: 20),
            Text('Memuat rumah adat...', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScaffold(int sukuId, bool isSmallScreen) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Rumah Adat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work_outlined, size: isSmallScreen ? 70 : 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text("Tidak ada data rumah adat",
                  style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.grey[700], fontWeight: FontWeight.w500)),
              SizedBox(height: 8),
              Text("Informasi rumah adat belum tersedia",
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 20 : 24,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRumahAdatScreen(sukuId: sukuId),
                    ),
                  );
                  // Refresh list after adding
                  if (mounted) {
                    Provider.of<RumahAdatViewModel>(context, listen: false).fetchRumahAdatList(sukuId);
                  }
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('Tambah Rumah Adat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red[700],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(message, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Kembali', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRumahAdatScaffold(BuildContext context, RumahAdatViewModel viewModel, int sukuId, bool isSmallScreen) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.rumahAdatList.isNotEmpty) {
        final currentRumahAdat = viewModel.rumahAdatList[_selectedRumahIndex];
        _komentarViewModel.fetchComments(itemId: currentRumahAdat.id!, itemType: 'rumah_adat');
      }
    });

    return Scaffold(
      backgroundColor: Colors.red[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Rumah Adat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image PageView
          Expanded(
            flex: isSmallScreen ? 2 : 3,
            child: PageView.builder(
              controller: _pageController,
              itemCount: viewModel.rumahAdatList.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedRumahIndex = index;
                  final currentRumahAdat = viewModel.rumahAdatList[_selectedRumahIndex];
                  _komentarViewModel.fetchComments(itemId: currentRumahAdat.id!, itemType: 'rumah_adat');
                });
              },
              itemBuilder: (context, index) {
                final rumahAdat = viewModel.rumahAdatList[index];
                return _buildImageCard(rumahAdat, isSmallScreen);
              },
            ),
          ),

          // Page Indicator
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                viewModel.rumahAdatList.length,
                    (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _selectedRumahIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _selectedRumahIndex == index ? Colors.red[700] : Colors.red[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Description Section
          Expanded(
            flex: isSmallScreen ? 3 : 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: _buildDescriptionContent(viewModel, isSmallScreen),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRumahAdatScreen(sukuId: sukuId),
            ),
          );
          if (mounted) {
            viewModel.fetchRumahAdatList(sukuId);
          }
        },
        backgroundColor: Colors.red[800],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildImageCard(RumahAdat rumahAdat, bool isSmallScreen) {
    return Hero(
      tag: 'rumah-adat-${rumahAdat.id}',
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context, rumahAdat),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  rumahAdat.foto,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: isSmallScreen ? 56 : 64, color: Colors.grey[600]),
                            SizedBox(height: 16),
                            Text("Gagal memuat gambar", style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rumahAdat.nama,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(offset: Offset(1, 1), blurRadius: 3.0, color: Colors.black.withOpacity(0.5))],
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white70, size: 16),
                          SizedBox(width: 4),
                          Text("Lokasi tradisional", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 100,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text("Perbesar", style: TextStyle(color: Colors.white, fontSize: 12)),
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
  }

  Widget _buildDescriptionContent(RumahAdatViewModel viewModel, bool isSmallScreen) {
    final rumahAdat = viewModel.rumahAdatList[_selectedRumahIndex];

    return Column(
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
              child: Icon(Icons.home_work, color: Colors.red[700]),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                rumahAdat.nama,
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
            ),
            _buildFavoriteButton(),
          ],
        ),
        SizedBox(height: 16),

        // Features section
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFeatureChip(Icons.architecture, rumahAdat.feature1),
            _buildFeatureChip(Icons.history, rumahAdat.feature2),
            _buildFeatureChip(Icons.handyman, rumahAdat.feature3),
          ],
        ),
        SizedBox(height: 20),

        // Detailed description
        Text("Deskripsi", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: Colors.red[800])),
        SizedBox(height: 8),
        Text(rumahAdat.deskripsi, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800])),
        SizedBox(height: 20),

        // Cultural significance section
        Text("Signifikansi Budaya", style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: Colors.red[800])),
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
              _buildSignificanceItem("Spiritual", rumahAdat.item1),
              SizedBox(height: 12),
              _buildSignificanceItem("Sosial", rumahAdat.item2),
              SizedBox(height: 12),
              _buildSignificanceItem("Artistik", rumahAdat.item3),
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
              colors: [Colors.red[700]!, Colors.red[900]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tahukah Anda?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text(
                "Rumah adat ini memiliki filosofi yang mendalam tentang hubungan manusia dengan alam dan leluhur. Setiap ornamen memiliki makna tersendiri.",
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.white.withOpacity(0.9)),
              ),
              SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showDetailedInfo(context, rumahAdat),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Pelajari lebih lanjut", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Komentar Section
        const Divider(height: 32, thickness: 1),
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('KOMENTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey[800])),
          ],
        ),
        const SizedBox(height: 16),

        // Form komentar
        _buildCommentForm(rumahAdat.id!, 'rumah_adat'),
        const SizedBox(height: 24),

        // Daftar Komentar
        Consumer<KomentarViewModel>(
          builder: (context, komentarViewModel, child) {
            final currentRumahId = rumahAdat.id!;
            final relevantComments = komentarViewModel.comments
                .where((k) => k.itemId == currentRumahId && k.itemType == 'rumah_adat')
                .toList();

            if (komentarViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (komentarViewModel.errorMessage != null) {
              return Center(
                child: Text('Gagal memuat komentar: ${komentarViewModel.errorMessage}', style: const TextStyle(color: Colors.red)),
              );
            }
            if (relevantComments.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Belum ada komentar yang disetujui untuk rumah adat ini.',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
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
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: Icon(Icons.favorite_border, color: Colors.red[700]),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fitur favorit belum diimplementasikan"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red[700],
          ),
        );
      },
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, color: Colors.red[700], size: 18),
      label: Text(text, style: TextStyle(color: Colors.red[700], fontSize: 13)),
      backgroundColor: Colors.red[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.red[200]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildSignificanceItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars, color: Colors.red[700], size: 18),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red[800])),
          ],
        ),
        SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
      ],
    );
  }

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
              Text("Informasi Rumah Adat", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Bagian ini menampilkan detail lengkap tentang rumah adat terpilih.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                SizedBox(height: 10),
                Text("Anda bisa menggeser gambar di bagian atas untuk melihat foto-foto lain dari rumah adat ini (jika tersedia).",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Tutup", style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, RumahAdat rumahAdat) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: Hero(
                  tag: 'rumah-adat-${rumahAdat.id}',
                  child: Image.network(
                    rumahAdat.foto,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(child: Icon(Icons.broken_image, color: Colors.white, size: 80));
                    },
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailedInfo(BuildContext context, RumahAdat rumahAdat) {
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
                    Text(rumahAdat.nama, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red[900])),
                    SizedBox(height: 20),
                    _buildDetailedSection("Sejarah", rumahAdat.sejarah),
                    _buildDetailedSection("Fungsi dan Penggunaan", rumahAdat.fungsi),
                    _buildDetailedSection("Ornamen dan Simbol", rumahAdat.ornamen),
                    _buildDetailedSection("Struktur Bangunan", rumahAdat.bangunan),
                    _buildDetailedSection("Pelestarian", rumahAdat.pelestarian),
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

  Widget _buildDetailedSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[800])),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16, color: Colors.grey[800], height: 1.6), textAlign: TextAlign.justify),
        ],
      ),
    );
  }

  Widget _buildCommentForm(int itemId, String itemType) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tinggalkan Komentar Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama (opsional)',
                hintText: 'Misal: Anonim',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
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
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                Text(komentar.namaAnonim, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[900])),
                const Spacer(),
                Text(_formatDate(komentar.tanggalKomentar), style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(komentar.komentarText, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}