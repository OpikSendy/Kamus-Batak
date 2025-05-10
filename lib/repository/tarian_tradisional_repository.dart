import '../models/tarian_tradisional.dart';
import '../service/supabase_service.dart';

class TarianTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<TarianTradisional>> getTarianBySukuId(int sukuId) async {
    final data = await _supabaseService.fetchData('tarian_tradisional');
    final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();
    return filteredData.map((json) => TarianTradisional.fromJson(json)).toList();
  }

  Future<void> addTarian(TarianTradisional tarian) async {
    await _supabaseService.insertData('tarian_tradisional', tarian.toJson());
  }

  Future<void> deleteTarian(int tarianId) async {
    await _supabaseService.deleteData('tarian_tradisional', 'id', tarianId as String);
  }

  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    await _supabaseService.updateFoto('tarian_tradisional', 'id', id.toString(), fotoUrl);
    await _supabaseService.updateFoto('suku', 'id', sukuId.toString(), fotoUrl);
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    return await _supabaseService.uploadFoto(filePath, bucketName);
  }
}