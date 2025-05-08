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
    await _supabaseService.deleteData('pakaian_tradisional', 'id', pakaianId as String);
  }
}