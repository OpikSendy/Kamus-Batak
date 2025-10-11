// lib/screens/suku_screen.dart - Responsive Version

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kbb/viewmodel/suku_viewmodel.dart';
import '../models/suku.dart';
import '../viewmodel/komentar_viewmodel.dart';
import '../models/komentar.dart';

class SukuScreen extends StatefulWidget {
  const SukuScreen({super.key});

  @override
  SukuScreenState createState() => SukuScreenState();
}

class SukuScreenState extends State<SukuScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
      if (sukuId != null) {
        _komentarViewModel = Provider.of<KomentarViewModel>(context, listen: false);
        _komentarViewModel.fetchComments(itemId: sukuId, itemType: 'suku');
      }
    });
  }

  @override
  void dispose() {
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

    final String namaAnonim = _nameController.text.trim().isEmpty
        ? 'Anonim'
        : _nameController.text.trim();
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

    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final crossAxisCount = isSmallScreen ? 2 : (screenWidth < 900 ? 3 : 4);

    return Consumer<SukuViewModel>(
      builder: (context, sukuViewModel, child) {
        if (sukuViewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
                  ),
                  const SizedBox(height: 20),
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

        Suku? suku;
        try {
          suku = sukuViewModel.sukuList.firstWhere((s) => s.id == sukuId);
        } catch (e) {
          return _buildErrorScaffold('Error', 'Suku tidak ditemukan');
        }

        return Scaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                pinned: true,
                expandedHeight: isSmallScreen ? 200.0 : 250.0,
                backgroundColor: Colors.red[800],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    suku.nama,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
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
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.red[800],
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Tentang ${suku.nama}',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 16 : 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Suku ${suku.nama} adalah salah satu suku Batak yang memiliki kebudayaan dan tradisi yang kaya. Mari jelajahi berbagai aspek budaya suku ${suku.nama} melalui kategori di bawah ini.',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: Colors.grey[900],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16.0 : 24.0),

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
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'KATEGORI BUDAYA',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 4.0 : 6.0),
                      Text(
                        'Telusuri berbagai aspek budaya suku ${suku.nama}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 13,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12.0 : 16.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isSmallScreen ? 8.0 : 12.0,
                    mainAxisSpacing: isSmallScreen ? 8.0 : 12.0,
                    childAspectRatio: isSmallScreen ? 0.95 : 1.1,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildCategoryCard(
                      context,
                      icon: Icons.people,
                      title: 'Marga',
                      subtitle: 'Sistem kekerabatan',
                      color: Colors.blue,
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
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
                      isSmallScreen: isSmallScreen,
                      onTap: () {
                        Navigator.pushNamed(context, '/rumah-adat-detail', arguments: sukuId);
                      },
                    ),
                  ]),
                ),
              ),

              // Bagian Komentar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 32, thickness: 1),
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
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'KOMENTAR',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildCommentForm(sukuId, 'suku', isSmallScreen),

                      const SizedBox(height: 24),

                      Consumer<KomentarViewModel>(
                        builder: (context, komentarViewModel, child) {
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
                          if (komentarViewModel.comments.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'Belum ada komentar yang disetujui.',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: komentarViewModel.comments.length,
                            itemBuilder: (context, index) {
                              final komentar = komentarViewModel.comments[index];
                              return _buildCommentCard(komentar, isSmallScreen);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentForm(int itemId, String itemType, bool isSmallScreen) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tinggalkan Komentar Anda',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama (opsional)',
                hintText: 'Misal: Anonim',
                labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.person_outline),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 10 : 12,
                ),
              ),
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Komentar Anda',
                hintText: 'Tulis komentar Anda di sini...',
                labelStyle: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                hintStyle: TextStyle(fontSize: isSmallScreen ? 12 : 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              ),
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _submitComment(itemId: itemId, itemType: itemType),
                icon: Icon(Icons.send, size: isSmallScreen ? 16 : 18),
                label: Text(
                  'Kirim Komentar',
                  style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(Komentar komentar, bool isSmallScreen) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: Colors.grey,
                  size: isSmallScreen ? 24 : 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    komentar.namaAnonim,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 13 : 15,
                      color: Colors.grey[900],
                    ),
                  ),
                ),
                Text(
                  _formatDate(komentar.tanggalKomentar),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              komentar.komentarText,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildCategoryCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required bool isSmallScreen,
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
          padding: EdgeInsets.all(isSmallScreen ? 10.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isSmallScreen ? 24.0 : 32.0,
                  color: color,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8.0 : 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13.0 : 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 2.0 : 4.0),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10.0 : 12.0,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
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