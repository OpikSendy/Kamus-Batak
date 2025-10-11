// lib/repository/tarian_tradisional_repository.dart

import '../models/tarian_tradisional.dart';
import '../service/supabase_service.dart';

class TarianTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'tarian_tradisional';

  /// Mengambil semua data tarian yang sudah divalidasi
  Future<List<TarianTradisional>> getTarianBySukuId(int sukuId) async {
    try {
      print("Fetching validated tarian for suku_id: $sukuId...");

      final data = await _supabaseService
          .fetchValidatedData(_tableName);

      // Filter berdasarkan suku_id
      final filteredData = data.where((item) =>
      item['suku_id'] == sukuId
      ).toList();

      print("Received ${filteredData.length} tarian records");

      final tarianList = filteredData.map((json) {
        print("Parsing tarian: ${json['nama']}");
        return TarianTradisional.fromJson(json);
      }).toList();

      return tarianList;
    } catch (e) {
      print("Error fetching tarian data: $e");
      throw Exception("Failed to load tarian list: $e");
    }
  }

  /// Mengambil tarian berdasarkan ID
  Future<TarianTradisional?> getTarianById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return TarianTradisional.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching tarian by ID: $e");
      throw Exception("Failed to load tarian: $e");
    }
  }

  /// Menambahkan tarian baru oleh user (pending validation)
  Future<void> addTarianByUser(TarianTradisional tarian) async {
    try {
      final data = {
        'suku_id': tarian.sukuId,
        'nama': tarian.nama,
        'foto': tarian.foto,
        'deskripsi': tarian.deskripsi,
        'sejarah': tarian.sejarah,
        'gerakan': tarian.gerakan,
        'kostum': tarian.kostum,
        'feature1': tarian.feature1,
        'feature2': tarian.feature2,
        'feature3': tarian.feature3,
        'video': tarian.video,
        'kategori': tarian.kategori,
        'durasi': tarian.durasi,
        'event': tarian.event,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding tarian by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Tarian added successfully");
    } catch (e) {
      print("Error adding tarian by user: $e");
      throw Exception("Failed to add tarian: $e");
    }
  }

  /// Menambahkan tarian baru oleh admin (langsung validated)
  Future<void> addTarianByAdmin(TarianTradisional tarian) async {
    try {
      final data = {
        'suku_id': tarian.sukuId,
        'nama': tarian.nama,
        'foto': tarian.foto,
        'deskripsi': tarian.deskripsi,
        'sejarah': tarian.sejarah,
        'gerakan': tarian.gerakan,
        'kostum': tarian.kostum,
        'feature1': tarian.feature1,
        'feature2': tarian.feature2,
        'feature3': tarian.feature3,
        'video': tarian.video,
        'kategori': tarian.kategori,
        'durasi': tarian.durasi,
        'event': tarian.event,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding tarian by admin: $e");
      throw Exception("Failed to add tarian: $e");
    }
  }

  /// Mengupdate data tarian
  Future<void> updateTarian(TarianTradisional tarian) async {
    try {
      if (tarian.id == null) {
        throw Exception("Tarian ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          tarian.id!,
          tarian.toJson()
      );
    } catch (e) {
      print("Error updating tarian: $e");
      throw Exception("Failed to update tarian: $e");
    }
  }

  /// Menghapus tarian
  Future<void> deleteTarian(int tarianId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', tarianId);
    } catch (e) {
      print("Error deleting tarian: $e");
      throw Exception("Failed to delete tarian: $e");
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

  /// Update foto tarian
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

  /// Mencari tarian berdasarkan nama (hanya yang validated)
  Future<List<TarianTradisional>> searchTarianByName(String name, int sukuId) async {
    try {
      final data = await _supabaseService.searchData(
        _tableName,
        'nama',
        name,
      );

      // Filter hanya yang sudah validated dan sesuai suku_id
      final validated = data.where((json) =>
      json['is_validated'] == true &&
          json['suku_id'] == sukuId
      ).toList();

      return validated.map((json) => TarianTradisional.fromJson(json)).toList();
    } catch (e) {
      print("Error searching tarian: $e");
      throw Exception("Failed to search tarian: $e");
    }
  }

  /// Check if tarian name already exists for specific suku
  Future<bool> isTarianNameExists(String nama, int sukuId, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          json['suku_id'] == sukuId &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking tarian name: $e");
      return false;
    }
  }
}