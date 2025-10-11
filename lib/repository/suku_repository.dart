// lib/repository/suku_repository.dart

import '../models/suku.dart';
import '../service/supabase_service.dart';

class SukuRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'suku';

  /// Mengambil semua data suku yang sudah divalidasi (PERBAIKAN)
  Future<List<Suku>> getAllSuku() async {
    try {
      print("Fetching all validated suku...");

      // Gunakan method fetchValidatedData yang baru
      final data = await _supabaseService.fetchValidatedData(_tableName);

      print("Received ${data.length} suku records");

      final sukuList = data.map((json) {
        print("Parsing suku: ${json['nama']}");
        return Suku.fromJson(json);
      }).toList();

      return sukuList;
    } catch (e) {
      print("Error fetching suku data: $e");
      throw Exception("Failed to load suku list: $e");
    }
  }

  /// Mengambil suku berdasarkan ID
  Future<Suku?> getSukuById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return Suku.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching suku by ID: $e");
      throw Exception("Failed to load suku: $e");
    }
  }

  /// Menambahkan suku baru oleh user (pending validation)
  Future<void> addSukuByUser(Suku suku) async {
    try {
      final data = {
        'nama': suku.nama,
        'foto': suku.foto,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding suku by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Suku added successfully");
    } catch (e) {
      print("Error adding suku by user: $e");
      throw Exception("Failed to add suku: $e");
    }
  }

  /// Menambahkan suku baru oleh admin (langsung validated)
  Future<void> addSukuByAdmin(Suku suku) async {
    try {
      final data = {
        'nama': suku.nama,
        'foto': suku.foto,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding suku by admin: $e");
      throw Exception("Failed to add suku: $e");
    }
  }

  /// Mengupdate data suku
  Future<void> updateSuku(Suku suku) async {
    try {
      if (suku.id == null) {
        throw Exception("Suku ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          suku.id!,
          suku.toJson()
      );
    } catch (e) {
      print("Error updating suku: $e");
      throw Exception("Failed to update suku: $e");
    }
  }

  /// Menghapus suku
  Future<void> deleteSuku(int sukuId) async {
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

  /// Mencari suku berdasarkan nama (hanya yang validated)
  Future<List<Suku>> searchSukuByName(String name) async {
    try {
      final data = await _supabaseService.searchData(
        _tableName,
        'nama',
        name,
      );

      // Filter hanya yang sudah validated
      final validated = data.where((json) =>
      json['is_validated'] == true
      ).toList();

      return validated.map((json) => Suku.fromJson(json)).toList();
    } catch (e) {
      print("Error searching suku: $e");
      throw Exception("Failed to search suku: $e");
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