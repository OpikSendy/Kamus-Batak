// lib/repository/kuliner_tradisional_repository.dart

import '../models/kuliner_tradisional.dart';
import '../service/supabase_service.dart';

class KulinerTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'kuliner_tradisional';

  /// Mengambil semua data kuliner yang sudah divalidasi berdasarkan suku_id
  Future<List<KulinerTradisional>> getKulinerBySukuId(int sukuId) async {
    try {
      print("Fetching validated kuliner for suku_id: $sukuId...");

      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'suku_id',
        sukuId,
      );

      // Filter hanya yang sudah validated
      final validated = data.where((json) =>
      json['is_validated'] == true
      ).toList();

      print("Received ${validated.length} validated kuliner records");

      return validated.map((json) {
        print("Parsing kuliner: ${json['nama']}");
        return KulinerTradisional.fromJson(json);
      }).toList();
    } catch (e) {
      print("Error fetching kuliner by suku_id: $e");
      throw Exception("Failed to load kuliner list: $e");
    }
  }

  /// Mengambil semua kuliner yang sudah validated (tanpa filter suku)
  Future<List<KulinerTradisional>> getAllKuliner() async {
    try {
      print("Fetching all validated kuliner...");

      final data = await _supabaseService.fetchValidatedData(_tableName);

      print("Received ${data.length} kuliner records");

      final kulinerList = data.map((json) {
        print("Parsing kuliner: ${json['nama']}");
        return KulinerTradisional.fromJson(json);
      }).toList();

      return kulinerList;
    } catch (e) {
      print("Error fetching kuliner data: $e");
      throw Exception("Failed to load kuliner list: $e");
    }
  }

  /// Mengambil kuliner berdasarkan ID
  Future<KulinerTradisional?> getKulinerById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return KulinerTradisional.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching kuliner by ID: $e");
      throw Exception("Failed to load kuliner: $e");
    }
  }

  /// Menambahkan kuliner baru oleh user (pending validation)
  Future<void> addKulinerByUser(KulinerTradisional kuliner) async {
    try {
      final data = {
        'suku_id': kuliner.sukuId,
        'jenis': kuliner.jenis,
        'nama': kuliner.nama,
        'foto': kuliner.foto,
        'deskripsi': kuliner.deskripsi,
        'rating': kuliner.rating,
        'waktu': kuliner.waktu,
        'resep': kuliner.resep,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding kuliner by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Kuliner added successfully");
    } catch (e) {
      print("Error adding kuliner by user: $e");
      throw Exception("Failed to add kuliner: $e");
    }
  }

  /// Menambahkan kuliner baru oleh admin (langsung validated)
  Future<void> addKulinerByAdmin(KulinerTradisional kuliner) async {
    try {
      final data = {
        'suku_id': kuliner.sukuId,
        'jenis': kuliner.jenis,
        'nama': kuliner.nama,
        'foto': kuliner.foto,
        'deskripsi': kuliner.deskripsi,
        'rating': kuliner.rating,
        'waktu': kuliner.waktu,
        'resep': kuliner.resep,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding kuliner by admin: $e");
      throw Exception("Failed to add kuliner: $e");
    }
  }

  /// Mengupdate data kuliner
  Future<void> updateKuliner(KulinerTradisional kuliner) async {
    try {
      if (kuliner.id == null) {
        throw Exception("Kuliner ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          kuliner.id!,
          kuliner.toJson()
      );
    } catch (e) {
      print("Error updating kuliner: $e");
      throw Exception("Failed to update kuliner: $e");
    }
  }

  /// Menghapus kuliner
  Future<void> deleteKuliner(int kulinerId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', kulinerId);
    } catch (e) {
      print("Error deleting kuliner: $e");
      throw Exception("Failed to delete kuliner: $e");
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

  /// Update foto kuliner
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

  /// Mencari kuliner berdasarkan nama (hanya yang validated)
  Future<List<KulinerTradisional>> searchKulinerByName(String name) async {
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

      return validated.map((json) => KulinerTradisional.fromJson(json)).toList();
    } catch (e) {
      print("Error searching kuliner: $e");
      throw Exception("Failed to search kuliner: $e");
    }
  }

  /// Check if kuliner name already exists
  Future<bool> isKulinerNameExists(String nama, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking kuliner name: $e");
      return false;
    }
  }
}