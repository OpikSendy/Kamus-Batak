import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchData(String table) async {
    try {
      final response = await _supabase.from(table).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> insertData(String table, Map<String, dynamic> data) async {
    try {
      await _supabase.from(table).insert(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteData(String table, String idField, String idValue) async {
    try {
      await _supabase.from(table).delete().eq(idField, idValue);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadFoto(String filePath, String bucketName) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/temp_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        targetPath,
        quality: 70,
      );

      if (compressedFile == null) {
        throw Exception("Gagal mengompres gambar");
      }

      final fileName = "foto_${DateTime.now().millisecondsSinceEpoch}.jpg";
      final bucket = _supabase.storage.from(bucketName);

      File fileToUpload = File(compressedFile.path);
      await bucket.upload(fileName, fileToUpload);
      return bucket.getPublicUrl(fileName);
    } catch (e) {
      throw Exception("Gagal upload foto: ${e.toString()}");
    }
  }

  Future<void> updateFoto(String table, String idColumn, String idValue, String fotoUrl) async {
    try {
      await _supabase
          .from(table)
          .update({'foto': fotoUrl})
          .eq(idColumn, idValue);
    } catch (e) {
      throw Exception("Gagal update data: ${e.toString()}");
    }
  }
}
