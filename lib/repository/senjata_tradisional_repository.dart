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
}