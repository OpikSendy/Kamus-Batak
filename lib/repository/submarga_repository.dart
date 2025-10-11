// lib/repository/submarga_repository.dart

import '../models/submarga.dart';
import '../service/supabase_service.dart';

class SubmargaRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'submarga';

  /// Mengambil submarga berdasarkan marga_id yang sudah divalidasi (PERBAIKAN)
  Future<List<Submarga>> getSubmargaByMargaId(int margaId) async {
    try {
      print("Fetching validated submarga for margaId: $margaId...");

      final data = await _supabaseService.fetchData(_tableName);

      // Filter berdasarkan marga_id dan is_validated
      final filteredData = data.where((item) =>
      item['marga_id'] == margaId &&
          item['is_validated'] == true
      ).toList();

      print("Received ${filteredData.length} validated submarga records");

      return filteredData.map((json) => Submarga.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching submarga data: $e");
      throw Exception("Failed to load submarga list: $e");
    }
  }

  /// Mengambil submarga berdasarkan ID
  Future<Submarga?> getSubmargaById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return Submarga.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching submarga by ID: $e");
      throw Exception("Failed to load submarga: $e");
    }
  }

  /// Menambahkan submarga baru oleh user (pending validation)
  Future<void> addSubmargaByUser(Submarga submarga) async {
    try {
      final data = {
        'marga_id': submarga.margaId,
        'nama': submarga.nama,
        'foto': submarga.foto,
        'deskripsi': submarga.deskripsi,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding submarga by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Submarga added successfully");
    } catch (e) {
      print("Error adding submarga by user: $e");
      throw Exception("Failed to add submarga: $e");
    }
  }

  /// Menambahkan submarga baru oleh admin (langsung validated)
  Future<void> addSubmargaByAdmin(Submarga submarga) async {
    try {
      final data = {
        'marga_id': submarga.margaId,
        'nama': submarga.nama,
        'foto': submarga.foto,
        'deskripsi': submarga.deskripsi,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding submarga by admin: $e");
      throw Exception("Failed to add submarga: $e");
    }
  }

  /// Mengupdate data submarga
  Future<void> updateSubmarga(Submarga submarga) async {
    try {
      if (submarga.id == null) {
        throw Exception("Submarga ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          submarga.id!,
          submarga.toJson()
      );
    } catch (e) {
      print("Error updating submarga: $e");
      throw Exception("Failed to update submarga: $e");
    }
  }

  /// Menghapus submarga
  Future<void> deleteSubmarga(int submargaId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', submargaId);
    } catch (e) {
      print("Error deleting submarga: $e");
      throw Exception("Failed to delete submarga: $e");
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

  /// Update foto submarga
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

  /// Mencari submarga berdasarkan nama (hanya yang validated)
  Future<List<Submarga>> searchSubmargaByName(String name, int margaId) async {
    try {
      final data = await _supabaseService.searchData(
        _tableName,
        'nama',
        name,
      );

      // Filter hanya yang sudah validated dan sesuai margaId
      final validated = data.where((json) =>
      json['is_validated'] == true &&
          json['marga_id'] == margaId
      ).toList();

      return validated.map((json) => Submarga.fromJson(json)).toList();
    } catch (e) {
      print("Error searching submarga: $e");
      throw Exception("Failed to search submarga: $e");
    }
  }

  /// Check if submarga name already exists in a marga
  Future<bool> isSubmargaNameExists(String nama, int margaId, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          json['marga_id'] == margaId &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking submarga name: $e");
      return false;
    }
  }
}