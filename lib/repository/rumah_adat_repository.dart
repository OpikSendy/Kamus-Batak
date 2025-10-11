// lib/repository/rumah_adat_repository.dart

import '../models/rumah_adat.dart';
import '../service/supabase_service.dart';

class RumahAdatRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'rumah_adat';

  /// Mengambil semua data rumah adat yang sudah divalidasi berdasarkan suku
  Future<List<RumahAdat>> getRumahAdatBySukuId(int sukuId) async {
    try {
      print("Fetching validated rumah adat for suku_id: $sukuId");

      final data = await _supabaseService.fetchValidatedData(_tableName);

      // Filter berdasarkan suku_id
      final filteredData = data.where((item) =>
      item['suku_id'] == sukuId
      ).toList();

      print("Received ${filteredData.length} rumah adat records for suku $sukuId");

      return filteredData.map((json) => RumahAdat.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching rumah adat by suku_id: $e");
      throw Exception("Failed to load rumah adat list: $e");
    }
  }

  /// Mengambil rumah adat berdasarkan ID
  Future<RumahAdat?> getRumahAdatById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return RumahAdat.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching rumah adat by ID: $e");
      throw Exception("Failed to load rumah adat: $e");
    }
  }

  /// Menambahkan rumah adat baru oleh user (pending validation)
  Future<void> addRumahAdatByUser(RumahAdat rumahAdat) async {
    try {
      final data = {
        'suku_id': rumahAdat.sukuId,
        'nama': rumahAdat.nama,
        'foto': rumahAdat.foto,
        'deskripsi': rumahAdat.deskripsi,
        'feature1': rumahAdat.feature1,
        'feature2': rumahAdat.feature2,
        'feature3': rumahAdat.feature3,
        'item1': rumahAdat.item1,
        'item2': rumahAdat.item2,
        'item3': rumahAdat.item3,
        'sejarah': rumahAdat.sejarah,
        'bangunan': rumahAdat.bangunan,
        'ornamen': rumahAdat.ornamen,
        'fungsi': rumahAdat.fungsi,
        'pelestarian': rumahAdat.pelestarian,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding rumah adat by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Rumah adat added successfully");
    } catch (e) {
      print("Error adding rumah adat by user: $e");
      throw Exception("Failed to add rumah adat: $e");
    }
  }

  /// Menambahkan rumah adat baru oleh admin (langsung validated)
  Future<void> addRumahAdatByAdmin(RumahAdat rumahAdat) async {
    try {
      final data = {
        'suku_id': rumahAdat.sukuId,
        'nama': rumahAdat.nama,
        'foto': rumahAdat.foto,
        'deskripsi': rumahAdat.deskripsi,
        'feature1': rumahAdat.feature1,
        'feature2': rumahAdat.feature2,
        'feature3': rumahAdat.feature3,
        'item1': rumahAdat.item1,
        'item2': rumahAdat.item2,
        'item3': rumahAdat.item3,
        'sejarah': rumahAdat.sejarah,
        'bangunan': rumahAdat.bangunan,
        'ornamen': rumahAdat.ornamen,
        'fungsi': rumahAdat.fungsi,
        'pelestarian': rumahAdat.pelestarian,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding rumah adat by admin: $e");
      throw Exception("Failed to add rumah adat: $e");
    }
  }

  /// Mengupdate data rumah adat
  Future<void> updateRumahAdat(RumahAdat rumahAdat) async {
    try {
      if (rumahAdat.id == null) {
        throw Exception("RumahAdat ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          rumahAdat.id!,
          rumahAdat.toJson()
      );
    } catch (e) {
      print("Error updating rumah adat: $e");
      throw Exception("Failed to update rumah adat: $e");
    }
  }

  /// Menghapus rumah adat
  Future<void> deleteRumahAdat(int rumahAdatId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', rumahAdatId);
    } catch (e) {
      print("Error deleting rumah adat: $e");
      throw Exception("Failed to delete rumah adat: $e");
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

  /// Update foto rumah adat
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

  /// Mencari rumah adat berdasarkan nama (hanya yang validated)
  Future<List<RumahAdat>> searchRumahAdatByName(String name) async {
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

      return validated.map((json) => RumahAdat.fromJson(json)).toList();
    } catch (e) {
      print("Error searching rumah adat: $e");
      throw Exception("Failed to search rumah adat: $e");
    }
  }

  /// Check if rumah adat name already exists for a suku
  Future<bool> isRumahAdatNameExists(String nama, int sukuId, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          json['suku_id'] == sukuId &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking rumah adat name: $e");
      return false;
    }
  }
}