import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchData(String table) async {
    try {
      final response = await _supabase
          .from(table)
          .select();

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertData(String table, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from(table)
          .insert(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteData(String table, String idField, String idValue) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq(idField, idValue);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFoto(String table, String idField, String idValue, String foto) async {
    try {
      await _supabase
          .from(table)
          .update({'foto': foto})
          .eq(idField, idValue);
    } catch (e) {
      rethrow;
    }
  }
}