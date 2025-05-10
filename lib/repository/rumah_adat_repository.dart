import '../models/rumah_adat.dart';
import '../service/supabase_service.dart';

class RumahAdatRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<RumahAdat>> getRumahAdatBySukuId(int sukuId) async {
    final data = await _supabaseService.fetchData('rumah_adat');
    final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();
    return filteredData.map((json) => RumahAdat.fromJson(json)).toList();
  }

  Future<void> addRumahAdat(RumahAdat rumahAdat) async {
    await _supabaseService.insertData('rumah_adat', rumahAdat.toJson());
  }

  Future<void> deleteRumahAdat(int rumahAdatId) async {
    await _supabaseService.deleteData('rumah_adat', 'id', rumahAdatId as String);
  }

  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    await _supabaseService.updateFoto('rumah_adat', 'id', id.toString(), fotoUrl);
    await _supabaseService.updateFoto('suku', 'id', sukuId.toString(), fotoUrl);
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    return await _supabaseService.uploadFoto(filePath, bucketName);
  }
}