import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/pakaian_tradisional_viewmodel.dart';
import '../models/pakaian_tradisional.dart';

class PakaianTradisionalDetailScreen extends StatefulWidget {
  const PakaianTradisionalDetailScreen({super.key});

  @override
  State<PakaianTradisionalDetailScreen> createState() => _PakaianTradisionalDetailScreenState();
}

class _PakaianTradisionalDetailScreenState extends State<PakaianTradisionalDetailScreen> {
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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.teal[700],
      //   onPressed: () {
      //     _showSearchDialog(context);
      //   },
      //   child: Icon(Icons.search),
      // ),
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
            color: Colors.teal[700],
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

  void _showPakaianDetail(BuildContext context, PakaianTradisional pakaian) {
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
                actions: [
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
                        pakaian.nama,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.teal[700],
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Pakaian Tradisional Indonesia",
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
                          _buildInfoChip(Icons.style, "Jenis", pakaian.feature1),
                          _buildInfoChip(Icons.event, "Acara", pakaian.feature2),
                          _buildInfoChip(Icons.auto_awesome, "Status", pakaian.feature3),
                        ],
                      ),

                      SizedBox(height: 24),

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

                      SizedBox(height: 20),

                      // Interactive elements
                      Container(
                        padding: EdgeInsets.all(16),
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
                            SizedBox(height: 12),
                            Text(
                              "Pakaian ini telah menjadi warisan budaya tak benda yang diakui secara nasional. Dilestarikan secara turun-temurun, pakaian ini menjadi identitas budaya yang kuat bagi masyarakat setempat.",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.teal[700],
                              ),
                            ),
                            // SizedBox(height: 16),
                            // OutlinedButton(
                            //   style: OutlinedButton.styleFrom(
                            //     side: BorderSide(color: Colors.teal[700]!),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(8),
                            //     ),
                            //   ),
                            //   onPressed: () {
                            //     _showGalleryPreview(context);
                            //   },
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       Icon(
                            //         Icons.photo_library_outlined,
                            //         color: Colors.teal[700],
                            //       ),
                            //       SizedBox(width: 8),
                            //       Text(
                            //         "Lihat Galeri Foto",
                            //         style: TextStyle(
                            //           color: Colors.teal[700],
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30),

                      // Related pakaian
                      // Text(
                      //   "Pakaian Terkait Lainnya",
                      //   style: TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.teal[800],
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
                      //                 pakaian.foto, // Placeholder, would use other images in real app
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
                      //                     "Pakaian ${index + 1}",
                      //                     style: TextStyle(
                      //                       fontWeight: FontWeight.bold,
                      //                       fontSize: 14,
                      //                     ),
                      //                   ),
                      //                   SizedBox(height: 4),
                      //                   Text(
                      //                     "Pakaian Tradisional",
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
          //               side: BorderSide(color: Colors.teal[700]!),
          //               padding: EdgeInsets.symmetric(vertical: 12),
          //             ),
          //             onPressed: () {
          //               Navigator.of(context).pop();
          //             },
          //             child: Text(
          //               "Kembali",
          //               style: TextStyle(
          //                 color: Colors.teal[700],
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //         SizedBox(width: 16),
          //         Expanded(
          //           child: ElevatedButton(
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: Colors.teal[700],
          //               padding: EdgeInsets.symmetric(vertical: 12),
          //             ),
          //             onPressed: () {
          //               ScaffoldMessenger.of(context).showSnackBar(
          //                 SnackBar(
          //                   content: Text('Berbagi informasi pakaian ${pakaian.nama}'),
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
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[100]!),
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
            color: Colors.teal[700],
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
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal[900],
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
              color: Colors.teal[800],
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

  // void _showGalleryPreview(BuildContext context) {
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
  //             height: 200,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[300],
  //               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //             ),
  //             child: Center(
  //               child: Icon(
  //                 Icons.photo_library,
  //                 size: 64,
  //                 color: Colors.teal[700],
  //               ),
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               children: [
  //                 Text(
  //                   "Galeri Foto",
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   "Fitur ini akan tersedia segera. Kami sedang mengembangkan kemampuan untuk menampilkan galeri foto pakaian tradisional.",
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Colors.grey[700],
  //                   ),
  //                 ),
  //                 SizedBox(height: 16),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.teal[700],
  //                     minimumSize: Size(double.infinity, 45),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text("Tutup"),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showFilterOptions(BuildContext context) {
  //   showModalBottomSheet(
  //       context: context,
  //       shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //   ),
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
  //                   "Filter Pakaian Tradisional",
  //                   style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.teal[800],
  //                   ),
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 ),
  //               ],
  //             ),
  //
  //             SizedBox(height: 16),
  //
  //             Text(
  //               "Kategori",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.teal[700],
  //               ),
  //             ),
  //
  //             SizedBox(height: 12),
  //
  //             Wrap(
  //               spacing: 10,
  //               runSpacing: 10,
  //               children: [
  //                 _buildFilterChip("Semua", isSelected: true),
  //                 _buildFilterChip("Pernikahan"),
  //                 _buildFilterChip("Upacara Adat"),
  //                 _buildFilterChip("Sehari-hari"),
  //                 _buildFilterChip("Pertunjukan"),
  //               ],
  //             ),
  //
  //             SizedBox(height: 20),
  //
  //             Text(
  //               "Daerah",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.teal[700],
  //               ),
  //             ),
  //
  //             SizedBox(height: 12),
  //
  //             Wrap(
  //               spacing: 10,
  //               runSpacing: 10,
  //               children: [
  //                 _buildFilterChip("Semua", isSelected: true),
  //                 _buildFilterChip("Sumatera"),
  //                 _buildFilterChip("Jawa"),
  //                 _buildFilterChip("Kalimantan"),
  //                 _buildFilterChip("Sulawesi"),
  //                 _buildFilterChip("Papua"),
  //                 _buildFilterChip("Bali"),
  //                 _buildFilterChip("NTT"),
  //                 _buildFilterChip("NTB"),
  //               ],
  //             ),
  //
  //             SizedBox(height: 20),
  //
  //             Text(
  //               "Urutkan Berdasarkan",
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.teal[700],
  //               ),
  //             ),
  //
  //             SizedBox(height: 12),
  //
  //             Wrap(
  //               spacing: 10,
  //               runSpacing: 10,
  //               children: [
  //                 _buildFilterChip("Terbaru", isSelected: true),
  //                 _buildFilterChip("Terpopuler"),
  //                 _buildFilterChip("A-Z"),
  //                 _buildFilterChip("Z-A"),
  //               ],
  //             ),
  //
  //             SizedBox(height: 24),
  //
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: OutlinedButton(
  //                     style: OutlinedButton.styleFrom(
  //                       side: BorderSide(color: Colors.teal[700]!),
  //                       padding: EdgeInsets.symmetric(vertical: 12),
  //                     ),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
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
  //                       Navigator.of(context).pop();
  //                       // Apply filter logic would go here
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

  // Widget _buildFilterChip(String label, {bool isSelected = false}) {
  //   return FilterChip(
  //     label: Text(label),
  //     selected: isSelected,
  //     selectedColor: Colors.teal[100],
  //     checkmarkColor: Colors.teal[700],
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(16),
  //       side: BorderSide(color: isSelected ? Colors.teal[700]! : Colors.grey[300]!),
  //     ),
  //     labelStyle: TextStyle(
  //       color: isSelected ? Colors.teal[700] : Colors.grey[800],
  //       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //     ),
  //     onSelected: (bool selected) {
  //       // In a real app, you would update the state here
  //     },
  //   );
  // }
  //
  // void _showSearchDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: Padding(
  //         padding: EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "Cari Pakaian Tradisional",
  //               style: TextStyle(
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.teal[800],
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             TextField(
  //               autofocus: true,
  //               decoration: InputDecoration(
  //                 hintText: "Nama pakaian tradisional...",
  //                 prefixIcon: Icon(Icons.search, color: Colors.teal[700]),
  //                 border: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: BorderSide(color: Colors.grey[300]!),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderRadius: BorderRadius.circular(12),
  //                   borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(height: 16),
  //             Text(
  //               "Pencarian Terakhir",
  //               style: TextStyle(
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.grey[700],
  //               ),
  //             ),
  //             SizedBox(height: 8),
  //             Wrap(
  //               spacing: 8,
  //               runSpacing: 8,
  //               children: [
  //                 _buildSearchHistoryChip("Baju Bodo"),
  //                 _buildSearchHistoryChip("Kebaya"),
  //                 _buildSearchHistoryChip("Pakaian Adat Jawa"),
  //               ],
  //             ),
  //             SizedBox(height: 16),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 TextButton(
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text(
  //                     "Batal",
  //                     style: TextStyle(
  //                       color: Colors.grey[700],
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 8),
  //                 ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.teal[700],
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                     // Search logic would go here
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                         content: Text('Mencari pakaian tradisional...'),
  //                         behavior: SnackBarBehavior.floating,
  //                       ),
  //                     );
  //                   },
  //                   child: Text("Cari"),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSearchHistoryChip(String label) {
  //   return Chip(
  //     label: Text(label),
  //     backgroundColor: Colors.grey[100],
  //     deleteIcon: Icon(Icons.close, size: 16),
  //     onDeleted: () {
  //       // Delete search history logic would go here
  //     },
  //     labelStyle: TextStyle(
  //       fontSize: 12,
  //       color: Colors.grey[800],
  //     ),
  //   );
  // }

  void _showInfoDialog(BuildContext context) {
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
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[700],
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Tentang Pakaian Tradisional",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Pakaian tradisional merupakan salah satu warisan budaya yang menunjukkan identitas dan keberagaman suku-suku di Indonesia. Setiap daerah memiliki pakaian khas dengan keunikan tersendiri dalam hal desain, motif, bahan, dan cara memakainya.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Pakaian tradisional biasanya dikenakan pada acara-acara khusus seperti upacara adat, pernikahan, hari raya, pertunjukan seni, dan acara resmi lainnya. Melestarikan pakaian tradisional berarti juga melestarikan nilai-nilai budaya yang terkandung di dalamnya.",
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
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
                      )
                      ,
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
}