import '../models/marga.dart';
import '../service/supabase_service.dart';

class MargaRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<Marga>> getMargaBySukuId(int sukuId) async {
    final data = await _supabaseService.fetchData('marga');
    final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();
    return filteredData.map((json) => Marga.fromJson(json)).toList();
  }

  Future<void> addMarga(Marga marga) async {
    await _supabaseService.insertData('marga', marga.toJson());
  }

  Future<void> deleteMarga(int margaId) async {
    await _supabaseService.deleteData('marga', 'id', margaId as String);
  }
}