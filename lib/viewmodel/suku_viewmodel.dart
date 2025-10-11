// lib/viewmodel/suku_viewmodel.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/suku_repository.dart';
import '../models/suku.dart';

class SukuViewModel extends ChangeNotifier {
  final SukuRepository _repository = SukuRepository();
  List<Suku> _sukuList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<Suku> get sukuList => _sukuList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua data suku yang sudah validated
  Future<void> fetchSukuList() async {
    _setLoading(true);
    _clearMessages();

    try {
      _sukuList = await _repository.getAllSuku();
    } catch (e) {
      _setError("Error fetching suku list: $e");
      print("Error fetching suku list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil data suku berdasarkan ID
  Future<Suku?> fetchSukuById(int sukuId) async {
    try {
      return await _repository.getSukuById(sukuId);
    } catch (e) {
      _setError("Error fetching suku by ID: $e");
      print("Error fetching suku by ID: $e");
      return null;
    }
  }

  /// Submit suku baru oleh user (akan pending validation)
  Future<bool> submitSukuByUser({
    required String nama,
    required File fotoFile,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama suku tidak boleh kosong");
      }

      // Check jika nama sudah ada
      final exists = await _repository.isSukuNameExists(nama);
      if (exists) {
        throw Exception("Nama suku sudah ada dalam database");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create suku object
      final newSuku = Suku(
        nama: nama.trim(),
        foto: fotoUrl,
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addSukuByUser(newSuku);

      _setSuccess(
          "Data suku berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting suku: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan suku baru oleh admin
  Future<void> addSukuByAdmin(Suku suku, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = suku.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newSuku = suku.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addSukuByAdmin(newSuku);
      await fetchSukuList();

      _setSuccess("Suku berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding suku: $e");
      print("Error adding suku: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Mengupdate data suku
  Future<void> updateSuku(Suku updatedSuku) async {
    try {
      await _repository.updateSuku(updatedSuku);

      // Update lokal
      final index = _sukuList.indexWhere((suku) => suku.id == updatedSuku.id);
      if (index != -1) {
        _sukuList[index] = updatedSuku;
        notifyListeners();
      }

      await fetchSukuList();
    } catch (e) {
      _setError("Error updating suku: $e");
      print("Error updating suku: $e");
      rethrow;
    }
  }

  /// Menghapus suku
  Future<void> deleteSuku(int sukuId) async {
    try {
      await _repository.deleteSuku(sukuId);

      _sukuList.removeWhere((suku) => suku.id == sukuId);
      notifyListeners();

      await fetchSukuList();
    } catch (e) {
      _setError("Error deleting suku: $e");
      print("Error deleting suku: $e");
      rethrow;
    }
  }

  /// Mengupdate foto suku
  Future<void> updateFoto(int id, File file, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _sukuList.indexWhere((suku) => suku.id == id);
      if (index != -1) {
        _sukuList[index] = _sukuList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari suku berdasarkan nama (local search)
  List<Suku> searchSuku(String query) {
    if (query.isEmpty) return _sukuList;

    return _sukuList.where((suku) =>
        suku.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari suku dari server
  Future<List<Suku>> searchSukuFromServer(String query) async {
    try {
      return await _repository.searchSukuByName(query);
    } catch (e) {
      _setError("Error searching suku: $e");
      return [];
    }
  }

  /// Mendapatkan suku berdasarkan ID (local)
  Suku? getSukuById(int id) {
    try {
      return _sukuList.firstWhere((suku) => suku.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Helper methods untuk state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  /// Clear data
  void clearData() {
    _sukuList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await fetchSukuList();
  }
}