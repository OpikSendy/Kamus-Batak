import '../models/senjata_tradisional.dart';
import '../service/supabase_service.dart';

class SenjataTradisionalRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final String _tableName = 'senjata_tradisional';

  /// Mengambil semua senjata yang sudah divalidasi berdasarkan suku
  Future<List<SenjataTradisional>> getSenjataBySukuId(int sukuId) async {
    try {
      print("Fetching validated senjata for suku: $sukuId");

      final data = await _supabaseService.fetchValidatedData(_tableName);

      final filteredData = data.where((item) =>
      item['suku_id'] == sukuId
      ).toList();

      print("Received ${filteredData.length} senjata records");

      return filteredData.map((json) =>
          SenjataTradisional.fromJson(json)
      ).toList();
    } catch (e) {
      print("Error fetching senjata data: $e");
      throw Exception("Failed to load senjata list: $e");
    }
  }

  /// Mengambil semua senjata yang sudah divalidasi
  Future<List<SenjataTradisional>> getAllSenjata() async {
    try {
      print("Fetching all validated senjata...");

      final data = await _supabaseService.fetchValidatedData(_tableName);

      print("Received ${data.length} senjata records");

      return data.map((json) =>
          SenjataTradisional.fromJson(json)
      ).toList();
    } catch (e) {
      print("Error fetching senjata data: $e");
      throw Exception("Failed to load senjata list: $e");
    }
  }

  /// Mengambil senjata berdasarkan ID
  Future<SenjataTradisional?> getSenjataById(int id) async {
    try {
      final data = await _supabaseService.fetchDataWithCondition(
        _tableName,
        'id',
        id,
      );

      if (data.isNotEmpty) {
        return SenjataTradisional.fromJson(data.first);
      }
      return null;
    } catch (e) {
      print("Error fetching senjata by ID: $e");
      throw Exception("Failed to load senjata: $e");
    }
  }

  /// Menambahkan senjata baru oleh user (pending validation)
  Future<void> addSenjataByUser(SenjataTradisional senjata) async {
    try {
      final data = {
        'suku_id': senjata.sukuId,
        'nama': senjata.nama,
        'foto': senjata.foto,
        'deskripsi': senjata.deskripsi,
        'feature1': senjata.feature1,
        'feature2': senjata.feature2,
        'feature3': senjata.feature3,
        'sejarah': senjata.sejarah,
        'material': senjata.material,
        'simbol': senjata.simbol,
        'penggunaan': senjata.penggunaan,
        'pertahanan': senjata.pertahanan,
        'perburuan': senjata.perburuan,
        'seremonial': senjata.seremonial,
        'input_source': 'user',
        'is_validated': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      print("Adding senjata by user: $data");
      await _supabaseService.insertData(_tableName, data);
      print("Senjata added successfully");
    } catch (e) {
      print("Error adding senjata by user: $e");
      throw Exception("Failed to add senjata: $e");
    }
  }

  /// Menambahkan senjata baru oleh admin (langsung validated)
  Future<void> addSenjataByAdmin(SenjataTradisional senjata) async {
    try {
      final data = {
        'suku_id': senjata.sukuId,
        'nama': senjata.nama,
        'foto': senjata.foto,
        'deskripsi': senjata.deskripsi,
        'feature1': senjata.feature1,
        'feature2': senjata.feature2,
        'feature3': senjata.feature3,
        'sejarah': senjata.sejarah,
        'material': senjata.material,
        'simbol': senjata.simbol,
        'penggunaan': senjata.penggunaan,
        'pertahanan': senjata.pertahanan,
        'perburuan': senjata.perburuan,
        'seremonial': senjata.seremonial,
        'input_source': 'admin',
        'is_validated': true,
        'validated_at': DateTime.now().toIso8601String(),
        'validated_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      await _supabaseService.insertData(_tableName, data);
    } catch (e) {
      print("Error adding senjata by admin: $e");
      throw Exception("Failed to add senjata: $e");
    }
  }

  /// Mengupdate data senjata
  Future<void> updateSenjata(SenjataTradisional senjata) async {
    try {
      if (senjata.id == null) {
        throw Exception("Senjata ID cannot be null for update");
      }

      await _supabaseService.updateData(
          _tableName,
          'id',
          senjata.id!,
          senjata.toJson()
      );
    } catch (e) {
      print("Error updating senjata: $e");
      throw Exception("Failed to update senjata: $e");
    }
  }

  /// Menghapus senjata
  Future<void> deleteSenjata(int senjataId) async {
    try {
      await _supabaseService.deleteData(_tableName, 'id', senjataId);
    } catch (e) {
      print("Error deleting senjata: $e");
      throw Exception("Failed to delete senjata: $e");
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

  /// Update foto senjata
  Future<void> updateFoto(int id, String fotoUrl, int sukuId) async {
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

  /// Mencari senjata berdasarkan nama (hanya yang validated)
  Future<List<SenjataTradisional>> searchSenjataByName(String name) async {
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

      return validated.map((json) => SenjataTradisional.fromJson(json)).toList();
    } catch (e) {
      print("Error searching senjata: $e");
      throw Exception("Failed to search senjata: $e");
    }
  }

  /// Check if senjata name already exists
  Future<bool> isSenjataNameExists(String nama, {int? excludeId}) async {
    try {
      final data = await _supabaseService.fetchData(_tableName);
      final exists = data.any((json) =>
      json['nama'].toString().toLowerCase() == nama.toLowerCase() &&
          (excludeId == null || json['id'] != excludeId)
      );
      return exists;
    } catch (e) {
      print("Error checking senjata name: $e");
      return false;
    }
  }
}