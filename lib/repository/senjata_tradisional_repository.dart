import '../models/senjata_tradisional.dart';
import '../service/supabase_service.dart';

class SenjataTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<SenjataTradisional>> getSenjataBySukuId(int sukuId) async {
    final data = await _supabaseService.fetchData('senjata_tradisional');
    final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();
    return filteredData.map((json) => SenjataTradisional.fromJson(json)).toList();
  }

  Future<void> addSenjata(SenjataTradisional senjata) async {
    await _supabaseService.insertData('senjata_tradisional', senjata.toJson());
  }

  Future<void> deleteSenjata(int senjataId) async {
    await _supabaseService.deleteData('senjata_tradisional', 'id', senjataId as String);
  }

  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    await _supabaseService.updateFoto('senjata_tradisional', 'id', id.toString(), fotoUrl);
    await _supabaseService.updateFoto('suku', 'id', sukuId.toString(), fotoUrl);
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    return await _supabaseService.uploadFoto(filePath, bucketName);
  }
}