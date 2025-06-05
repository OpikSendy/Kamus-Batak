import '../models/suku.dart';
import '../service/supabase_service.dart';

class SukuRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'suku';

  /// Mengambil semua data suku
  Future<List<Suku>> getAllSuku() async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      return data.map((json) => Suku.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching suku data: $e");
      throw Exception("Failed to load suku list: $e");
    }
  }

  /// Mengambil suku berdasarkan ID
  Future<Suku?> getSukuById(int id) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final filteredData = data.where((json) => json['id'] == id).toList();

      if (filteredData.isNotEmpty) {
        return Suku.fromJson(filteredData.first);
      }
      return null;
    } catch (e) {
      print("Error fetching suku by ID: $e");
      throw Exception("Failed to load suku: $e");
    }
  }

  /// Menambahkan suku baru
  Future<void> addSuku(Suku suku) async {
    try {
      // Hapus ID dari data yang akan diinsert karena ID akan di-generate otomatis
      final data = suku.toJson();
      data.remove('id'); // Remove ID untuk auto-increment

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding suku: $e");
      throw Exception("Failed to add suku: $e");
    }
  }

  /// Mengupdate data suku
  Future<void> updateSuku(Suku suku) async {
    try {
      await _supabaseService.updateData(
          _tableName, 'id', suku.id.toString(), suku.toJson());
    } catch (e) {
      print("Error updating suku: $e");
      throw Exception("Failed to update suku: $e");
    }
  }

  /// Menghapus suku
  Future<void> deleteSuku(String sukuId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', sukuId);
    } catch (e) {
      print("Error deleting suku: $e");
      throw Exception("Failed to delete suku: $e");
    }
  }

  /// Upload foto ke storage
  Future<String> uploadFoto(String filePath, String bucketName) async {
    try {
      return await _supabaseService.uploadFoto(filePath, bucketName);
    } catch (e) {
      print("Error uploading foto: $e");
      throw Exception("Failed to upload foto: $e");
    }
  }

  /// Update foto suku
  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
    try {
      await _supabaseService.updateFoto(
          _tableName, 'id', id.toString(), fotoUrl);

      // Jika sukuId berbeda dengan id, update juga
      if (sukuId != id) {
        await _supabaseService.updateFoto(
            _tableName, 'id', sukuId.toString(), fotoUrl);
      }
    } catch (e) {
      print("Error updating foto: $e");
      throw Exception("Failed to update foto: $e");
    }
  }

  /// Mencari suku berdasarkan nama
  Future<List<Suku>> searchSukuByName(String name) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final filteredData = data.where((json) =>
          json['nama'].toString().toLowerCase().contains(name.toLowerCase())
      ).toList();

      return filteredData.map((json) => Suku.fromJson(json)).toList();
    } catch (e) {
      print("Error searching suku: $e");
      throw Exception("Failed to search suku: $e");
    }
  }

  /// Mengambil statistik suku
  Future<Map<String, int>> getSukuStats() async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final total = data.length;
      final withPhoto = data.where((json) =>
      json['foto'] != null && json['foto']
          .toString()
          .isNotEmpty
      ).length;
      final withoutPhoto = total - withPhoto;

      return {
        'total': total,
        'withPhoto': withPhoto,
        'withoutPhoto': withoutPhoto,
      };
    } catch (e) {
      print("Error getting suku stats: $e");
      throw Exception("Failed to get suku statistics: $e");
    }
  }

  /// Batch delete multiple suku
  Future<void> deleteMutipleSuku(List<String> sukuIds) async {
    try {
      for (String id in sukuIds) {
        await _supabaseService.deleteData(_tableName, 'id', id);
      }
    } catch (e) {
      print("Error deleting multiple suku: $e");
      throw Exception("Failed to delete multiple suku: $e");
    }
  }

  /// Check if suku name already exists
  Future<bool> isSukuNameExists(String nama, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking suku name: $e");
      return false;
    }
  }

}