// lib/repository/marga_repository.dart

import '../models/marga.dart';
import '../service/supabase_service.dart';

class MargaRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'marga';

  /// Mengambil semua data marga yang sudah divalidasi berdasarkan suku ID
  Future<List<Marga>> getMargaBySukuId(int sukuId) async {
    try {
      print("Fetching validated marga for suku_id: $sukuId...");

      final data = await _supabaseService.fetchValidatedData(_tableName);

      // Filter berdasarkan suku_id
      final filteredData = data.where((item) => item['suku_id'] == sukuId).toList();

      print("Received ${filteredData.length} validated marga records");

      return filteredData.map((json) => Marga.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching marga by suku_id: $e");
      throw Exception("Failed to load marga list: $e");
    }
  }

  /// Mengambil marga berdasarkan ID
  Future<Marga?> getMargaById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return Marga.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching marga by ID: $e");
      throw Exception("Failed to load marga: $e");
    }
  }

  /// Menambahkan marga baru oleh user (pending validation)
  Future<void> addMargaByUser(Marga marga) async {
    try {
      final data = {
        'suku_id': marga.sukuId,
        'nama': marga.nama,
        'foto': marga.foto,
        'deskripsi': marga.deskripsi,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding marga by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Marga added successfully");
    } catch (e) {
      print("Error adding marga by user: $e");
      throw Exception("Failed to add marga: $e");
    }
  }

  /// Menambahkan marga baru oleh admin (langsung validated)
  Future<void> addMargaByAdmin(Marga marga) async {
    try {
      final data = {
        'suku_id': marga.sukuId,
        'nama': marga.nama,
        'foto': marga.foto,
        'deskripsi': marga.deskripsi,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding marga by admin: $e");
      throw Exception("Failed to add marga: $e");
    }
  }

  /// Mengupdate data marga
  Future<void> updateMarga(Marga marga) async {
    try {
      if (marga.id == null) {
        throw Exception("Marga ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          marga.id!,
          marga.toJson()
      );
    } catch (e) {
      print("Error updating marga: $e");
      throw Exception("Failed to update marga: $e");
    }
  }

  /// Menghapus marga
  Future<void> deleteMarga(int margaId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', margaId);
    } catch (e) {
      print("Error deleting marga: $e");
      throw Exception("Failed to delete marga: $e");
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

  /// Update foto marga
  Future<void> updateFoto(int id, String fotoUrl) async {
    try {
      await _supabaseService.updateFoto(
          _tableName,
          'id',
          id,
          fotoUrl
      );
    } catch (e) {
      print("Error updating foto: $e");
      throw Exception("Failed to update foto: $e");
    }
  }

  /// Mencari marga berdasarkan nama (hanya yang validated)
  Future<List<Marga>> searchMargaByName(String name, int sukuId) async {
    try {
      final data = await _supabaseService.searchData(
        _tableName,
        'nama',
        name,
      );

      // Filter hanya yang sudah validated dan sesuai suku_id
      final validated = data.where((json) =>
      json['is_validated'] == true && json['suku_id'] == sukuId
      ).toList();

      return validated.map((json) => Marga.fromJson(json)).toList();
    } catch (e) {
      print("Error searching marga: $e");
      throw Exception("Failed to search marga: $e");
    }
  }

  /// Check if marga name already exists in a specific suku
  Future<bool> isMargaNameExists(String nama, int sukuId, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          json['suku_id'] == sukuId &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking marga name: $e");
      return false;
    }
  }
}