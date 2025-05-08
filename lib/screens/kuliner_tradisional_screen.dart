import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/kuliner_tradisional_viewmodel.dart';

class KulinerTradisionalDetailScreen extends StatefulWidget {
  const KulinerTradisionalDetailScreen({super.key});

  @override
  KulinerTradisionalState createState() => KulinerTradisionalState();
}

class KulinerTradisionalState extends State<KulinerTradisionalDetailScreen> {
  final String _searchQuery = '';
  String _selectedFilter = 'Semua';

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
                      left: 50,
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
                IconButton(
                  icon: Icon(Icons.filter_list, color: Colors.white),
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
              final filteredList = viewModel.kulinerList.where((kuliner) {
                final matchesSearch = kuliner.nama.toLowerCase().contains(_searchQuery.toLowerCase());
                final matchesFilter = _selectedFilter == 'Semua' || kuliner.jenis.toLowerCase() == _selectedFilter.toLowerCase();
                return matchesSearch && matchesFilter;
              }).toList();
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
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.orange[800],
      //   child: Icon(
      //       Icons.restaurant_menu,
      //       color: Colors.white,
      //   ),
      //   onPressed: () {
      //     // Implementasi tambahan, misalnya bookmark kuliner favorit
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Fitur bookmark kuliner akan segera hadir!'),
      //         backgroundColor: Colors.orange[800],
      //       ),
      //     );
      //   },
      // ),
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
                    _buildInfoChip(Icons.star, '4.8', Colors.amber),
                    SizedBox(width: 12),
                    _buildInfoChip(Icons.access_time, '30 menit', Colors.blue[700]!),
                    SizedBox(width: 12),
                    _buildInfoChip(Icons.local_fire_department, 'Populer', Colors.red[700]!),
                  ],
                ),
                SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: () {
                    // Implementasi tombol lihat resep
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Fitur ini akan segera hadir!'),
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

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(20),
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
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
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