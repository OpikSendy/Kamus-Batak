// lib/repository/kuliner_tradisional_repository.dart

import '../models/kuliner_tradisional.dart';
import '../service/supabase_service.dart';

class KulinerTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<KulinerTradisional>> getKulinerBySukuId(int sukuId) async {
    // Memperbaiki sedikit di sini: gunakan fetchDataWithCondition untuk efisiensi
    final data = await _supabaseService.fetchDataWithCondition('kuliner_tradisional', 'suku_id', sukuId);
    return data.map((json) => KulinerTradisional.fromJson(json)).toList();
  }

  // --- TAMBAHKAN METODE INI ---
  Future<KulinerTradisional> getKulinerById(int kulinerId) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
          'kuliner_tradisional', 'id', kulinerId); // Ambil data dengan kondisi id
      if (data.isNotEmpty) {
        return KulinerTradisional.fromJson(data.first); // Ambil item pertama
      } else {
        throw Exception('Kuliner with ID $kulinerId not found.');
      }
    } catch (e) {
      print("Error fetching kuliner by ID: $e");
      rethrow;
    }
  }
  // -------------------------

  Future<void> addKuliner(KulinerTradisional kuliner) async {
    await _supabaseService.insertData('kuliner_tradisional', kuliner.toJson());
  }

  Future<void> deleteKuliner(int kulinerId) async {
    // Pastikan tipe data untuk idValue sesuai dengan SupabaseService
    // Jika 'id' di Supabase adalah integer, maka jangan casting ke String di sini.
    // SupabaseService.deleteData membutuhkan dynamic untuk value.
    await _supabaseService.deleteData('kuliner_tradisional', 'id', kulinerId as String);
  }

  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    await _supabaseService.updateFoto('kuliner_tradisional', 'id', id.toString(), fotoUrl);
    // Asumsi 'suku' juga punya kolom 'foto' dan perlu diupdate
    // Jika tidak, baris ini bisa dihapus atau disesuaikan.
    await _supabaseService.updateFoto('suku', 'id', sukuId.toString(), fotoUrl);
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    return await _supabaseService.uploadFoto(filePath, bucketName);
  }
}