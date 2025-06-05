// lib/service/supabase_service.dart

import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/komentar.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Mengambil data dari tabel
  Future<List<Map<String, dynamic>>> fetchData(String table) async {
    try {
      final response = await _supabase.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching data from $table: $e");
      rethrow;
    }
  }

  /// Mengambil data dengan kondisi tertentu
  Future<List<Map<String, dynamic>>> fetchDataWithCondition(
      String table,
      String column,
      dynamic value // Menerima dynamic untuk ID atau nilai lainnya
      ) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq(column, value);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetching data with condition from $table: $e");
      rethrow;
    }
  }

  /// Mengambil data dengan pencarian
  Future<List<Map<String, dynamic>>> searchData(
      String table,
      String column,
      String searchTerm
      ) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .ilike(column, '%$searchTerm%');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error searching data in $table: $e");
      rethrow;
    }
  }

  /// Menambahkan data baru
  Future<Map<String, dynamic>?> insertData(String table, Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from(table)
          .insert(data)
          .select()
          .single();
      return response;
    } catch (e) {
      print("Error inserting data to $table: $e");
      rethrow;
    }
  }

  /// Mengupdate data
  Future<void> updateData(
      String table,
      String idField,
      dynamic idValue, // Ubah ke dynamic
      Map<String, dynamic> data
      ) async {
    try {
      await _supabase
          .from(table)
          .update(data)
          .eq(idField, idValue);
    } catch (e) {
      print("Error updating data in $table: $e");
      rethrow;
    }
  }

  /// Menghapus data
  Future<void> deleteData(String table, String idField, dynamic idValue) async { // Ubah ke dynamic
    try {
      await _supabase
          .from(table)
          .delete()
          .eq(idField, idValue);
    } catch (e) {
      print("Error deleting data from $table: $e");
      rethrow;
    }
  }

  /// Menghapus multiple data
  Future<void> deleteMultipleData(
      String table,
      String idField,
      List<dynamic> idValues // Ubah ke List<dynamic>
      ) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq(idField, idValues);
    } catch (e) {
      print("Error deleting multiple data from $table: $e");
      rethrow;
    }
  }

  /// Upload foto dengan kompresi
  Future<String> uploadFoto(String filePath, String bucketName) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/temp_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Kompresi gambar
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 600,
        rotate: 0,
      );

      if (compressedFile == null) {
        throw Exception("Gagal mengompres gambar");
      }

      // Generate nama file unik
      final fileName = "foto_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final bucket = _supabase.storage.from(bucketName);

      // Upload file
      File fileToUpload = File(compressedFile.path);
      await bucket.upload(fileName, fileToUpload);

      // Dapatkan URL publik
      final publicUrl = bucket.getPublicUrl(fileName);

      // Hapus file temporary
      try {
        final tempFile = File(compressedFile.path);
        await tempFile.delete();
      } catch (e) {
        print("Warning: Failed to delete temporary file: $e");
      }


      return publicUrl;
    } catch (e) {
      print("Error uploading foto: $e");
      throw Exception("Gagal upload foto: ${e.toString()}");
    }
  }

  /// Upload multiple foto
  Future<List<String>> uploadMultipleFoto(
      List<String> filePaths,
      String bucketName
      ) async {
    try {
      List<String> urls = [];

      for (String filePath in filePaths) {
        final url = await uploadFoto(filePath, bucketName);
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print("Error uploading multiple foto: $e");
      throw Exception("Gagal upload multiple foto: ${e.toString()}");
    }
  }

  /// Update foto di record tertentu
  Future<void> updateFoto(String table, String idColumn, dynamic idValue, String fotoUrl) async { // Ubah ke dynamic
    try {
      await _supabase
          .from(table)
          .update({'foto': fotoUrl})
          .eq(idColumn, idValue);
    } catch (e) {
      print("Error updating foto in $table: $e");
      throw Exception("Gagal update data: ${e.toString()}");
    }
  }

  /// Hapus foto dari storage
  Future<void> deleteFoto(String bucketName, String fileName) async {
    try {
      final bucket = _supabase.storage.from(bucketName);
      await bucket.remove([fileName]);
    } catch (e) {
      print("Error deleting foto from storage: $e");
      throw Exception("Gagal hapus foto: ${e.toString()}");
    }
  }

  /// Get count data dari tabel
  Future<int> getDataCount(String table) async {
    try {
      final response = await _supabase
          .from(table)
          .select('count(*)')
          .single();
      return response['count'] ?? 0;
    } catch (e) {
      print("Error getting count from $table: $e");
      return 0;
    }
  }

  /// Check koneksi ke Supabase
  Future<bool> checkConnection() async {
    try {
      await _supabase.from('suku').select('id').limit(1);
      return true;
    } catch (e) {
      print("Connection check failed: $e");
      return false;
    }
  }

  /// Get current user info (jika menggunakan auth)
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Sign out user (jika menggunakan auth)
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print("Error signing out: $e");
      rethrow;
    }
  }

  Future<List<Komentar>> fetchApprovedComments({
    required int itemId,
    required String itemType,
  }) async {
    try {
      final response = await _supabase
          .from('komentar')
          .select('*')
          .eq('item_id', itemId)
          .eq('item_type', itemType)
          .eq('is_approved', true) // Hanya ambil komentar yang sudah disetujui
          .order('tanggal_komentar', ascending: false);

      if (response != null) {
        return (response as List).map((json) => Komentar.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching approved comments: $e');
      return Future.error('Failed to load comments');
    }
  }

  // Fungsi untuk mengirim komentar baru
  Future<void> addComment(Komentar komentar) async {
    try {
      // Supabase akan mengabaikan 'id' jika tabel disetel auto-increment
      await _supabase.from('komentar').insert(komentar.toJson());
    } catch (e) {
      print('Error adding comment: $e');
      return Future.error('Failed to add comment');
    }
  }
}