import '../models/kuliner_tradisional.dart';
import '../service/supabase_service.dart';

class KulinerTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<KulinerTradisional>> getKulinerBySukuId(int sukuId) async {
    final data = await _supabaseService.fetchData('kuliner_tradisional');
    final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();
    return filteredData.map((json) => KulinerTradisional.fromJson(json)).toList();
  }

  Future<void> addKuliner(KulinerTradisional kuliner) async {
    await _supabaseService.insertData('kuliner_tradisional', kuliner.toJson());
  }

  Future<void> deleteKuliner(int kulinerId) async {
    await _supabaseService.deleteData('kuliner_tradisional', 'id', kulinerId as String);
  }
}