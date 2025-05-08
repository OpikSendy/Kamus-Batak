import '../models/submarga.dart';
import '../service/supabase_service.dart';

class SubmargaRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<Submarga>> getSubmargaByMargaId(int margaId) async {
    final data = await _supabaseService.fetchData('submarga');
    final filteredData = data.where((item) => item['marga_id'] == margaId).toList();
    return filteredData.map((json) => Submarga.fromJson(json)).toList();
  }

  Future<void> addSubmarga(Submarga submarga) async {
    await _supabaseService.insertData('submarga', submarga.toJson());
  }

  Future<void> deleteSubmarga(int submargaId) async {
    await _supabaseService.deleteData('submarga', 'id', submargaId as String);
  }
}