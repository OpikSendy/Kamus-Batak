import '../models/suku.dart';
import '../service/supabase_service.dart';

class SukuRepository {
  final SupabaseService _supabaseService = SupabaseService();

  Future<List<Suku>> getAllSuku() async {
    try {
      final data = await _supabaseService.fetchData('suku');
      return data.map((json) => Suku.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching suku data: $e");
      throw Exception("Failed to load suku list: $e");
    }
  }

  Future<void> addSuku(Suku suku) async {
    try {
      await _supabaseService.insertData('suku', suku.toJson());
    } catch (e) {
      print("Error adding suku: $e");
      throw Exception("Failed to add suku: $e");
    }
  }

  Future<void> deleteSuku(String sukuId) async {
    try {
      await _supabaseService.deleteData('suku', 'id', sukuId);
    } catch (e) {
      print("Error deleting suku: $e");
      throw Exception("Failed to delete suku: $e");
    }
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    try {
      return await _supabaseService.uploadFoto(filePath, bucketName);
    } catch (e) {
      print("Error uploading foto: $e");
      throw Exception("Failed to upload foto: $e");
    }
  }

  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    try {
      await _supabaseService.updateFoto('suku', 'id', id.toString(), fotoUrl);
      await _supabaseService.updateFoto('suku', 'id', sukuId.toString(), fotoUrl);
    } catch (e) {
      print("Error updating foto: $e");
      throw Exception("Failed to update foto: $e");
    }
  }
}