import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kbb/models/kuliner_tradisional.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import '../viewmodel/kuliner_tradisional_viewmodel.dart';
import '../viewmodel/komentar_viewmodel.dart'; // Pastikan ini diimpor
import '../models/komentar.dart'; // Pastikan ini diimpor

class KulinerTradisionalDetailScreen extends StatefulWidget {
  const KulinerTradisionalDetailScreen({super.key});

  @override
  KulinerTradisionalState createState() => KulinerTradisionalState();
}

class KulinerTradisionalState extends State<KulinerTradisionalDetailScreen> {
  // Variabel untuk pencarian dan filter, diaktifkan kembali
  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  // Variabel Komentar tidak diperlukan di sini karena ini adalah halaman daftar.
  // Komentar akan berada di halaman detail kuliner tunggal.
  // TextEditingController _commentController = TextEditingController();
  // TextEditingController _nameController = TextEditingController();
  // late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ambil sukuId untuk mengambil daftar kuliner berdasarkan suku
      final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
      if (sukuId != null) {
        // Panggil fetchKulinerListBySukuId untuk mendapatkan daftar kuliner
        Provider.of<KulinerTradisionalViewModel>(context, listen: false)
            .fetchKulinerListBySukuId(sukuId);
      }
    });
  }

  @override
  void dispose() {
    // _commentController.dispose(); // Hapus karena tidak lagi di sini
    // _nameController.dispose(); // Hapus karena tidak lagi di sini
    super.dispose();
  }

  // Fungsi snackbar (tetap berguna)
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // sukuId tetap diperlukan untuk fetching awal
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;

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
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  "Kuliner Tradisional", // Judul untuk daftar
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
                      'https://example.com/kuliner_background.jpg', // Gambar background statis
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
                      left: 60,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
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
                // Mengaktifkan kembali fitur pencarian di AppBar
                Container(
                  width: 140, // Sesuaikan lebar agar tidak terlalu sempit
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Cari kuliner...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                // Mengaktifkan kembali tombol filter
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ],
            ),
          ];
        },
        body: Consumer<KulinerTradisionalViewModel>(
          builder: (context, viewModel, child) {
            // Logika filter dan pencarian untuk daftar kuliner
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
                    const SizedBox(height: 20),
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
            } else if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan: ${viewModel.errorMessage}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Coba ambil data lagi
                        if (sukuId != null) {
                          Provider.of<KulinerTradisionalViewModel>(context, listen: false)
                              .fetchKulinerListBySukuId(sukuId);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                      child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else if (filteredList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.no_food,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty || _selectedFilter != 'Semua'
                          ? "Kuliner tidak ditemukan dengan kriteria tersebut."
                          : "Tidak ada data kuliner tradisional.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty || _selectedFilter != 'Semua'
                          ? "Coba sesuaikan pencarian atau filter Anda."
                          : "Coba periksa kembali nanti.",
                      textAlign: TextAlign.center,
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
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
                        const SizedBox(width: 8),
                        Text(
                          'DAFTAR KULINER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.grey[800],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredList.length} item',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jelajahi rasa otentik makanan dan minuman tradisional',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final kuliner = filteredList[index];
                          // Membungkus _buildKulinerCard dengan GestureDetector
                          // agar bisa dinavigasi ke halaman detail
                          return GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman detail kuliner spesifik
                              Navigator.pushNamed(context,
                                '/kuliner-tradisional-single-detail', // Ganti dengan rute detail kuliner tunggal
                                arguments: kuliner.id, // Kirim ID kuliner sebagai argumen),
                              );
                            },
                            child: _buildKulinerCard(context, kuliner),
                          );
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
    );
  }

  // --- Widget untuk membangun kartu kuliner (sama seperti sebelumnya) ---
  Widget _buildKulinerCard(BuildContext context, KulinerTradisional kuliner) {
    Color tagColor = kuliner.jenis == 'makanan' ? Colors.green[700]! : Colors.blue[700]!;
    String tagText = kuliner.jenis == 'makanan' ? 'MAKANAN KHAS' : 'MINUMAN KHAS';

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                child: Hero( // Tambahkan Hero Widget untuk animasi transisi gambar
                  tag: 'kuliner-image-${kuliner.id}', // Tag unik untuk setiap kuliner
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
              ),

              // Tag
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tagText,
                    style: const TextStyle(
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Description (diubah sedikit agar tombol "Lihat Resep" berfungsi)
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(width: 8),
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
                const SizedBox(height: 12.0),
                Text(
                  kuliner.deskripsi,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                  maxLines: 3, // Batasi deskripsi di daftar
                  overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika terlalu panjang
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    _buildInfoChip(Icons.star, kuliner.rating, Colors.amber),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.access_time, kuliner.waktu, Colors.blue[700]!),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Tombol "Lihat Resep" yang sudah berfungsi untuk halaman daftar
                OutlinedButton(
                  onPressed: () {
                    // Navigasi ke halaman detail kuliner spesifik
                    Navigator.pushNamed(
                      context,
                      '/kuliner-tradisional-single-detail', // Ganti dengan rute detail kuliner tunggal
                      arguments: kuliner.id, // Kirim ID kuliner sebagai argumen
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: Colors.orange[800]!),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline, // Ganti ikon menjadi info atau detail
                        size: 18,
                        color: Colors.orange[800],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Lihat Detail', // Ubah teks menjadi "Lihat Detail"
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

  // --- Widget-widget pembantu lainnya (seperti sebelumnya) ---
  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const SizedBox(width: 6),
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

  // Dialog filter
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Jenis Kuliner',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Semua', 'makanan', 'minuman'].map((filter) {
                  return ChoiceChip(
                    label: Text(filter.toUpperCase()),
                    selected: _selectedFilter == filter,
                    selectedColor: Colors.orange[800],
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

// Hapus _showResep dari sini, karena itu akan ada di halaman detail tunggal.
// Demikian juga _buildFilterOption dan _showSearchDialog jika tidak digunakan di sini.
// Untuk _showResep, kita akan memindahkannya ke halaman detail spesifik.
}


// --- Halaman Detail Kuliner Tunggal (Baru) ---
// Anda perlu membuat file baru, misalnya: lib/screens/kuliner_tradisional_single_detail_screen.dart
// Salin semua kode dari KulinerTradisionalDetailScreen Anda yang sebelumnya untuk detail tunggal ke file ini.
// Pastikan untuk mengganti nama class menjadi KulinerTradisionalSingleDetailScreen.

// lib/screens/kuliner_tradisional_single_detail_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/kuliner_tradisional.dart';
// import '../viewmodel/kuliner_tradisional_viewmodel.dart';
// import '../viewmodel/komentar_viewmodel.dart';
// import '../models/komentar.dart';

class KulinerTradisionalSingleDetailScreen extends StatefulWidget {
  const KulinerTradisionalSingleDetailScreen({super.key});

  @override
  _KulinerTradisionalSingleDetailScreenState createState() => _KulinerTradisionalSingleDetailScreenState();
}

class _KulinerTradisionalSingleDetailScreenState extends State<KulinerTradisionalSingleDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final kulinerId = ModalRoute.of(context)?.settings.arguments as int?;
      if (kulinerId != null) {
        // Panggil fetchKulinerDetail untuk detail kuliner tunggal
        Provider.of<KulinerTradisionalViewModel>(context, listen: false).fetchKulinerDetail(kulinerId);

        _komentarViewModel = Provider.of<KomentarViewModel>(context, listen: false);
        _komentarViewModel.fetchComments(itemId: kulinerId, itemType: 'kuliner');
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
    } catch (e) {
      _showSnackBar('Gagal mengirim komentar: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kulinerId = ModalRoute.of(context)?.settings.arguments as int?;
    if (kulinerId == null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ID Kuliner tidak valid.'),
        ),
      );
    }

    return Consumer<KulinerTradisionalViewModel>(
      builder: (context, kulinerViewModel, child) {
        final KulinerTradisional? currentKuliner = kulinerViewModel.currentKulinerDetail;

        if (kulinerViewModel.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!)),
                  SizedBox(height: 20),
                  Text(
                    'Memuat informasi kuliner tradisional...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (kulinerViewModel.errorMessage != null || currentKuliner == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    kulinerViewModel.errorMessage ?? 'Kuliner tidak ditemukan atau terjadi kesalahan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<KulinerTradisionalViewModel>(context, listen: false).fetchKulinerDetail(kulinerId);
                      _komentarViewModel.fetchComments(itemId: kulinerId, itemType: 'kuliner');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800]),
                    child: Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 250.0,
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
                      currentKuliner.nama,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'kuliner-image-${currentKuliner.id}',
                          child: Image.network(
                            currentKuliner.foto,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[800]!),
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
                  actions: const [],
                ),
              ];
            },
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildKulinerDetailContent(currentKuliner), // Konten detail kuliner

                    const SizedBox(height: 24),

                    // Bagian Komentar
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

                    _buildCommentForm(currentKuliner.id, 'kuliner'),

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
                            return _buildCommentCard(komentar);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Widget-widget pembantu di halaman detail ---
  Widget _buildKulinerDetailContent(KulinerTradisional kuliner) {
    Color tagColor = kuliner.jenis == 'makanan' ? Colors.green[700]! : Colors.blue[700]!;
    String tagText = kuliner.jenis == 'makanan' ? 'MAKANAN KHAS' : 'MINUMAN KHAS';

    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                const SizedBox(width: 8),
                Text(
                  kuliner.jenis == 'makanan' ? 'Makanan Tradisional' : 'Minuman Tradisional',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: tagColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tagColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    tagText,
                    style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              kuliner.deskripsi,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                _buildInfoChip(Icons.star, kuliner.rating, Colors.amber),
                const SizedBox(width: 12),
                _buildInfoChip(Icons.access_time, kuliner.waktu, Colors.blue[700]!),
              ],
            ),
            const SizedBox(height: 16.0),
            OutlinedButton(
              onPressed: () {
                _showResep(context, kuliner);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.orange[800]!),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book,
                    size: 18,
                    color: Colors.orange[800],
                  ),
                  const SizedBox(width: 8),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          const SizedBox(width: 6),
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

  void _showResep(BuildContext context, KulinerTradisional kuliner) {
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[700],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Resep ${kuliner.nama}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    kuliner.resep,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                        "Tutup",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
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
}