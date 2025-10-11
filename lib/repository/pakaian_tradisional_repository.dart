// lib/repository/pakaian_tradisional_repository.dart

import '../models/pakaian_tradisional.dart';
import '../service/supabase_service.dart';

class PakaianTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'pakaian_tradisional';

  /// Mengambil semua data pakaian yang sudah divalidasi berdasarkan suku
  Future<List<PakaianTradisional>> getPakaianBySukuId(int sukuId) async {
    try {
      print("Fetching validated pakaian for suku: $sukuId");

      final data = await _supabaseService.fetchValidatedData(_tableName);

      // Filter berdasarkan suku_id
      final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();

      print("Received ${filteredData.length} pakaian records for suku $sukuId");

      return filteredData.map((json) => PakaianTradisional.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching pakaian data: $e");
      throw Exception("Failed to load pakaian list: $e");
    }
  }

  /// Mengambil pakaian berdasarkan ID
  Future<PakaianTradisional?> getPakaianById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return PakaianTradisional.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching pakaian by ID: $e");
      throw Exception("Failed to load pakaian: $e");
    }
  }

  /// Menambahkan pakaian baru oleh user (pending validation)
  Future<void> addPakaianByUser(PakaianTradisional pakaian) async {
    try {
      final data = {
        'suku_id': pakaian.sukuId,
        'nama': pakaian.nama,
        'foto': pakaian.foto,
        'deskripsi': pakaian.deskripsi,
        'sejarah': pakaian.sejarah,
        'bahan': pakaian.bahan,
        'kelengkapan': pakaian.kelengkapan,
        'feature1': pakaian.feature1,
        'feature2': pakaian.feature2,
        'feature3': pakaian.feature3,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding pakaian by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Pakaian added successfully");
    } catch (e) {
      print("Error adding pakaian by user: $e");
      throw Exception("Failed to add pakaian: $e");
    }
  }

  /// Menambahkan pakaian baru oleh admin (langsung validated)
  Future<void> addPakaianByAdmin(PakaianTradisional pakaian) async {
    try {
      final data = {
        'suku_id': pakaian.sukuId,
        'nama': pakaian.nama,
        'foto': pakaian.foto,
        'deskripsi': pakaian.deskripsi,
        'sejarah': pakaian.sejarah,
        'bahan': pakaian.bahan,
        'kelengkapan': pakaian.kelengkapan,
        'feature1': pakaian.feature1,
        'feature2': pakaian.feature2,
        'feature3': pakaian.feature3,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding pakaian by admin: $e");
      throw Exception("Failed to add pakaian: $e");
    }
  }

  /// Mengupdate data pakaian
  Future<void> updatePakaian(PakaianTradisional pakaian) async {
    try {
      if (pakaian.id == null) {
        throw Exception("Pakaian ID cannot be null for update");
      }

      await _supabaseService.updateData(
        _tableName,
        'id',
        pakaian.id!,
        pakaian.toJson(),
      );
    } catch (e) {
      print("Error updating pakaian: $e");
      throw Exception("Failed to update pakaian: $e");
    }
  }

  /// Menghapus pakaian
  Future<void> deletePakaian(int pakaianId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', pakaianId);
    } catch (e) {
      print("Error deleting pakaian: $e");
      throw Exception("Failed to delete pakaian: $e");
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

  /// Update foto pakaian
  Future<void> updateFoto(int id, String fotoUrl) async {
    try {
      await _supabaseService.updateFoto(
        _tableName,
        'id',
        id,
        fotoUrl,
      );
    } catch (e) {
      print("Error updating foto: $e");
      throw Exception("Failed to update foto: $e");
    }
  }

  /// Mencari pakaian berdasarkan nama (hanya yang validated)
  Future<List<PakaianTradisional>> searchPakaianByName(String name) async {
    try {
      final data = await _supabaseService.searchData(
        _tableName,
        'nama',
        name,
      );

      // Filter hanya yang sudah validated
      final validated = data.where((json) => json['is_validated'] == true).toList();

      return validated.map((json) => PakaianTradisional.fromJson(json)).toList();
    } catch (e) {
      print("Error searching pakaian: $e");
      throw Exception("Failed to search pakaian: $e");
    }
  }

  /// Check if pakaian name already exists
  Future<bool> isPakaianNameExists(String nama, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          (excludeId == null || json['id'] != excludeId));
      return exists;
    } catch (e) {
      print("Error checking pakaian name: $e");
      return false;
    }
  }
}