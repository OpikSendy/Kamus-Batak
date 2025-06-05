import 'package:flutter/material.dart';
import 'package:kbb/screens/home_screen.dart';
import 'package:kbb/screens/kuliner_tradisional_screen.dart';
import 'package:kbb/screens/marga_screen.dart';
import 'package:kbb/screens/pakaian_tradisional_screen.dart';
import 'package:kbb/screens/rumah_adat_screen.dart';
import 'package:kbb/screens/senjata_tradisional_screen.dart';
import 'package:kbb/screens/splash_screen.dart';
import 'package:kbb/screens/suku_screen.dart';
import 'package:kbb/screens/tarian_tradisional_screen.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/kuliner-tradisional-single-detail':
        return _buildPageRoute(KulinerTradisionalSingleDetailScreen(), settings);
      case '/home':
        return _buildPageRoute(HomeScreen(), settings);
      case '/splash':
        return _buildPageRoute(SplashScreen(), settings);
      case '/suku-detail':
        return _buildPageRoute(SukuScreen(), settings);
      case '/marga-detail':
        return _buildPageRoute(MargaDetailScreen(), settings);
      case '/pakaian-tradisional-detail':
        return _buildPageRoute(PakaianTradisionalDetailScreen(), settings);
      case '/kuliner-tradisional-detail':
        return _buildPageRoute(KulinerTradisionalDetailScreen(), settings);
      case '/senjata-tradisional-detail':
        return _buildPageRoute(SenjataTradisionalDetailScreen(), settings);
      case '/tarian-tradisional-detail':
        return _buildPageRoute(TarianTradisionalDetailScreen(), settings);
      case '/rumah-adat-detail':
        return _buildPageRoute(RumahAdatDetailScreen(), settings);
      default:
        return _buildPageRoute(SplashScreen(), settings);
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
