import 'package:flutter/material.dart';
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
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pushNamed(context, '/tarian-tradisional-detail', arguments: sukuId);
                      },
                    ),
                    _buildCategoryCard(
                      context,
                      icon: Icons.home,
                      title: 'Rumah Adat',
                      subtitle: 'Arsitektur tradisional',
                      color: Colors.brown,
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
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: Colors.red[800],
          //   child: Icon(
          //       Icons.explore,
          //       color: Colors.white,
          //   ),
          //   onPressed: () {
          //     Implementasi fungsi floating button
            // },
          // ),
        );
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