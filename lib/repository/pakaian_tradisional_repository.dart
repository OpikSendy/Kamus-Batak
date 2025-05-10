import '../models/pakaian_tradisional.dart';
import '../service/supabase_service.dart';

class PakaianTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<PakaianTradisional>> getPakaianBySukuId(int sukuId) async {
    final data = await _supabaseService.fetchData('pakaian_tradisional');
    final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();
    return filteredData.map((json) => PakaianTradisional.fromJson(json)).toList();
  }

  Future<void> addPakaian(PakaianTradisional pakaian) async {
    await _supabaseService.insertData('pakaian_tradisional', pakaian.toJson());
  }

  Future<void> deletePakaian(int pakaianId) async {
    await _supabaseService.deleteData('pakaian_tradisional', 'id', pakaianId.toString());
  }

  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    await _supabaseService.updateFoto('pakaian_tradisional', 'id', id.toString(), fotoUrl);
    await _supabaseService.updateFoto('suku', 'id', sukuId.toString(), fotoUrl);
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    return await _supabaseService.uploadFoto(filePath, bucketName);
  }
}
