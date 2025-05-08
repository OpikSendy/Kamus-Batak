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
}