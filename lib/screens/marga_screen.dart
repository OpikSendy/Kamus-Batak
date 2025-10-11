import 'package:flutter/material.dart';
import 'package:kbb/models/submarga.dart';
import 'package:kbb/screens/add/add_marga_screen.dart';
import 'package:kbb/screens/add/add_submarga_screen.dart';
import 'package:provider/provider.dart';
import 'package:kbb/viewmodel/submarga_viewmodel.dart';
import 'package:kbb/viewmodel/marga_viewmodel.dart';
import 'package:kbb/models/marga.dart';
// Import KomentarViewModel dan Komentar model
import '../viewmodel/komentar_viewmodel.dart'; // Sesuaikan path jika berbeda
import '../models/komentar.dart'; // Sesuaikan path jika berbeda

class MargaDetailScreen extends StatefulWidget {
  const MargaDetailScreen({super.key});

  @override
  State<MargaDetailScreen> createState() => _MargaDetailScreenState();
}

class _MargaDetailScreenState extends State<MargaDetailScreen> {
  final Set<int> _expandedPanels = {};

  // Tambahkan TextEditingController untuk komentar
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Tambahkan KomentarViewModel
  late KomentarViewModel _komentarViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sukuId = ModalRoute.of(context)?.settings.arguments as int?;
      if (sukuId != null) {
        // Menginisialisasi MargaViewModel dan memanggil fetchMargaList
        Provider.of<MargaViewModel>(context, listen: false).fetchMargaList(sukuId);

        // Inisialisasi KomentarViewModel untuk halaman ini
        // Kita tidak bisa langsung memuat komentar spesifik untuk 'marga' di sini
        // karena halaman ini menampilkan daftar marga, bukan satu marga spesifik.
        // Komentar akan ditambahkan pada detail masing-masing marga jika diperluas.
        _komentarViewModel = Provider.of<KomentarViewModel>(context, listen: false);
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
      // Perbarui daftar komentar untuk marga ini setelah komentar berhasil dikirim
      _komentarViewModel.fetchComments(itemId: itemId, itemType: itemType);
    } catch (e) {
      _showSnackBar('Gagal mengirim komentar: ${e.toString()}', isError: true);
    }
  }

  // Tambahkan method baru untuk menampilkan detail submarga dalam dialog
  void _showSubmargaDetailDialog(BuildContext context, Submarga submarga) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: submarga.foto.isNotEmpty
                    ? Image.network(
                  submarga.foto,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                )
                    : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.red[800], size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            submarga.nama,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      submarga.deskripsi,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[800],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sukuId = ModalRoute.of(context)?.settings.arguments as int?;

    if (sukuId == null) {
      return _buildErrorScaffold('Error', 'ID Suku tidak valid');
    }

    // Menggunakan ChangeNotifierProvider di sini untuk MargaViewModel
    // Pastikan KomentarViewModel sudah di sediakan di level aplikasi (main.dart)
    return ChangeNotifierProvider(
      create: (_) => MargaViewModel()..fetchMargaList(sukuId),
      child: Consumer<MargaViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return _buildLoadingScaffold();
          } else if (viewModel.margaList.isEmpty) {
            return _buildEmptyScaffold();
          } else {
            return _buildMargaListScaffold(context, viewModel, sukuId);
          }
        },
      ),
    );
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daftar Marga",
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
            ),
            SizedBox(height: 20),
            Text(
              'Memuat daftar marga...',
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
        title: Text(
          "Daftar Marga",
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              "Tidak ada data marga ditemukan",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Silakan coba kembali nanti",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(String title, String message) {
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: Colors.red[800],
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

  Widget _buildMargaListScaffold(BuildContext context, MargaViewModel viewModel, int sukuId) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daftar Marga",
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.red[800],
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //         Icons.search,
        //         color: Colors.white,
        //     ),
        //     onPressed: () {
        //       showSearch(
        //         context: context,
        //         delegate: MargaSearchDelegate(viewModel.margaList),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.people,
                          color: Colors.red[800],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sistem Marga',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Marga adalah identitas kekerabatan dalam suku Batak yang menunjukkan garis keturunan. Sistem ini penting dalam menentukan hubungan pernikahan dan kekerabatan.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Count info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Ditemukan ${viewModel.margaList.length} marga',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Marga list
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 16),
                itemCount: viewModel.margaList.length,
                itemBuilder: (context, index) {
                  final marga = viewModel.margaList[index];
                  final isExpanded = _expandedPanels.contains(marga.id);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // Expandable header
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_expandedPanels.contains(marga.id)) {
                                  _expandedPanels.remove(marga.id);
                                } else {
                                  _expandedPanels.add(marga.id!);
                                  // Ketika panel dibuka, muat komentar untuk marga ini
                                  _komentarViewModel.fetchComments(itemId: marga.id!, itemType: 'marga');
                                }
                              });
                            },
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(isExpanded ? 0 : 12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red[100],
                                    radius: 24,
                                    backgroundImage: NetworkImage(marga.foto),
                                    onBackgroundImageError: (_, __) {
                                      // Handle image error by showing a default icon
                                      // You might want to use a placeholder image instead
                                      print('Error loading image for marga: ${marga.nama}');
                                    },
                                    child: (marga.foto.isEmpty || !Uri.parse(marga.foto).isAbsolute)
                                        ? Icon( // Show a default icon if photo is empty or invalid
                                      Icons.person,
                                      color: Colors.red[800],
                                      size: 24,
                                    )
                                        : null, // Don't show icon if image is loaded
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          marga.nama,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded ? Icons.expand_less : Icons.expand_more,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expanded content
                          if (isExpanded)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Divider
                                Divider(height: 1),

                                // Description
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Deskripsi:",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        marga.deskripsi,
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          height: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      // Sub Marga Section
                                      _buildSubmargaSection(context, marga.id!, marga.nama),

                                      // --- Bagian Komentar ---
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
                                      _buildCommentForm(marga.id!, 'marga'), // ID marga dan itemType 'marga'

                                      const SizedBox(height: 24),

                                      // Daftar Komentar
                                      Consumer<KomentarViewModel>(
                                        builder: (context, komentarViewModel, child) {
                                          // Filter komentar untuk marga yang sedang diperluas
                                          final relevantComments = komentarViewModel.comments
                                              .where((k) => k.itemId == marga.id && k.itemType == 'marga')
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
                                                  'Belum ada komentar yang disetujui untuk marga ini.',
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
                              ],
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMargaScreen(sukuId: sukuId),
            ),
          );

          // Refresh list setelah kembali
          if (mounted) {
            Provider.of<MargaViewModel>(context, listen: false).fetchMargaList(sukuId);
          }
        },
        backgroundColor: Colors.red[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Marga',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmargaSection(BuildContext context, int margaId, String margaNama) {
    return ChangeNotifierProvider(
      create: (_) => SubmargaViewModel()..fetchSubmargaList(margaId),
      child: Consumer<SubmargaViewModel>(
        builder: (context, subMargaViewModel, _) {
          if (subMargaViewModel.isLoading) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[800]!),
                ),
              ),
            );
          } else if (subMargaViewModel.submargaList.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sub Marga:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddSubmargaScreen(
                              margaId: margaId,
                              margaNama: margaNama,
                            ),
                          ),
                        );

                        // Refresh list setelah kembali
                        if (mounted) {
                          subMargaViewModel.fetchSubmargaList(margaId);
                        }
                      },
                      icon: Icon(Icons.add, size: 18, color: Colors.red[800]),
                      label: Text(
                        'Tambah',
                        style: TextStyle(color: Colors.red[800]),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red[800]!),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Belum ada data sub marga tersedia.",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Jadilah yang pertama menambahkan!",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Sub Marga:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${subMargaViewModel.submargaList.length}",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddSubmargaScreen(
                              margaId: margaId,
                              margaNama: margaNama,
                            ),
                          ),
                        );

                        // Refresh list setelah kembali
                        if (mounted) {
                          subMargaViewModel.fetchSubmargaList(margaId);
                        }
                      },
                      icon: Icon(Icons.add, size: 18, color: Colors.red[800]),
                      label: Text(
                        'Tambah',
                        style: TextStyle(color: Colors.red[800]),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.red[800]!),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: subMargaViewModel.submargaList.length,
                    separatorBuilder: (context, index) => Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) {
                      final subMarga = subMargaViewModel.submargaList[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red[50],
                          backgroundImage: subMarga.foto.isNotEmpty
                              ? NetworkImage(subMarga.foto)
                              : null,
                          child: subMarga.foto.isEmpty
                              ? Text(
                            subMarga.nama[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                        title: Text(
                          subMarga.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          subMarga.deskripsi,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 14),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          // Optional: Navigate to submarga detail
                          // Navigator.pushNamed(
                          //   context,
                          //   '/submarga-detail',
                          //   arguments: subMarga.id,
                          // );

                          // Atau tampilkan detail dalam dialog
                          _showSubmargaDetailDialog(context, subMarga);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
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

// Search delegate for searching margas
class MargaSearchDelegate extends SearchDelegate<Marga?> {
  final List<Marga> margaList;

  MargaSearchDelegate(this.margaList);

  @override
  String get searchFieldLabel => 'Cari marga...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.red[800],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
      ),
      textTheme: theme.textTheme.copyWith(
        bodyLarge: TextStyle(color: Colors.white),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = query.isEmpty
        ? margaList
        : margaList
        .where((marga) => marga.nama.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Tidak ada marga yang sesuai',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final marga = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(marga.foto),
            onBackgroundImageError: (_, __) {
              // Handle image error
            },
            child: (marga.foto.isEmpty || !Uri.parse(marga.foto).isAbsolute)
                ? Icon(
              Icons.person,
              color: Colors.red[800],
            )
                : null,
          ),
          title: Text(marga.nama),
          subtitle: Text(
            marga.deskripsi,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, marga);
          },
        );
      },
    );
  }
}