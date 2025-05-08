import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kbb/utils/page_router.dart';
import 'package:kbb/viewmodel/kuliner_tradisional_viewmodel.dart';
import 'package:kbb/viewmodel/marga_viewmodel.dart';
import 'package:kbb/viewmodel/pakaian_tradisional_viewmodel.dart';
import 'package:kbb/viewmodel/rumah_adat_viewmodel.dart';
import 'package:kbb/viewmodel/senjata_tradisional_viewmodel.dart';
import 'package:kbb/viewmodel/submarga_viewmodel.dart';
import 'package:kbb/viewmodel/suku_viewmodel.dart';
import 'package:kbb/viewmodel/tarian_tradisional_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // First initialize Supabase
  try {
    await Supabase.initialize(
      url: "https://cdwdmevwsgmqvjyuhhhf.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNkd2RtZXZ3c2dtcXZqeXVoaGhmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU1NzQ1NTQsImV4cCI6MjA2MTE1MDU1NH0.SrTGcwTqUUKPSblbOF0q3u-BvFC8-qFiRCUDec-eA9s",
    );
    print("Supabase initialized successfully");
  } catch (e) {
    print("Error initializing Supabase: $e");
  }

  // Now make test HTTP request if needed
  final client = Supabase.instance.client;

  try {
    final response = await client.from('suku').select();
    print("Test fetch response: $response");
  } catch (e) {
    print("Error during test fetch: $e");
  }

  // Run app
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SukuViewModel()),
      ChangeNotifierProvider(create: (_) => MargaViewModel()),
      ChangeNotifierProvider(create: (_) => SubmargaViewModel()),
      ChangeNotifierProvider(create: (_) => SenjataTradisionalViewModel()),
      ChangeNotifierProvider(create: (_) => PakaianTradisionalViewModel()),
      ChangeNotifierProvider(create: (_) => KulinerTradisionalViewModel()),
      ChangeNotifierProvider(create: (_) => TarianTradisionalViewModel()),
      ChangeNotifierProvider(create: (_) => RumahAdatViewModel()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kamus Batak',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: PageRouter.generateRoute,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}