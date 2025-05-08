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
}