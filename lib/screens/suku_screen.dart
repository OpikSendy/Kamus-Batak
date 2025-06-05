import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'package:kbb/viewmodel/suku_viewmodel.dart';
import '../models/suku.dart';
// Import KomentarViewModel dan Komentar model
import '../viewmodel/komentar_viewmodel.dart'; // Sesuaikan path jika berbeda
import '../models/komentar.dart'; // Sesuaikan path jika berbeda

class SukuScreen extends StatefulWidget {
  const SukuScreen({super.key});

  @override
  SukuScreenState createState() => SukuScreenState();
}

class SukuScreenState extends State<SukuScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Tambahkan KomentarViewModel di sini
  late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    // Di initState, kita tidak bisa langsung mengakses Provider.of karena context belum sepenuhnya tersedia.
    // Kita akan memanggil fetchComments setelah build selesai menggunakan WidgetsBinding.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
      if (sukuId != null) {
        // Inisialisasi KomentarViewModel
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

    // Ambil nama dari controller, jika kosong gunakan 'Anonim'
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
      _nameController.clear(); // Bersihkan nama juga jika mau
      // Tidak perlu memuat ulang komentar disetujui karena komentar baru belum disetujui
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

    // Gunakan MultiProvider atau Consumer bertingkat jika SukuViewModel dan KomentarViewModel belum di root
    // Di sini kita akan menggunakan Consumer bertingkat untuk demonstrasi
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

        Suku? suku;
        try {
          suku = sukuViewModel.sukuList.firstWhere((s) => s.id == sukuId);
        } catch (e) {
          return _buildErrorScaffold('Error', 'Suku tidak ditemukan');
        }

        return Scaffold(
          body: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
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

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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

              // Bagian Komentar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      _buildCommentForm(sukuId, 'suku'), // Pass itemId dan itemType

                      const SizedBox(height: 24),

                      // Daftar Komentar
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
                            shrinkWrap: true, // Penting agar tidak terjadi error unbounded height
                            physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll di dalam listview ini
                            itemCount: komentarViewModel.comments.length,
                            itemBuilder: (context, index) {
                              final komentar = komentarViewModel.comments[index];
                              return _buildCommentCard(komentar);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom padding
              SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      },
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
                  backgroundColor: Colors.red[800],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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