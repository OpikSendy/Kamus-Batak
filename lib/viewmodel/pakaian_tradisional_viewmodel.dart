// lib/viewmodel/pakaian_tradisional_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/pakaian_tradisional_repository.dart';
import '../models/pakaian_tradisional.dart';

class PakaianTradisionalViewModel extends ChangeNotifier {
  final PakaianTradisionalRepository _repository = PakaianTradisionalRepository();
  List<PakaianTradisional> _pakaianList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<PakaianTradisional> get pakaianList => _pakaianList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua data pakaian yang sudah validated berdasarkan suku
  Future<void> fetchPakaianList(int sukuId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _pakaianList = await _repository.getPakaianBySukuId(sukuId);
    } catch (e) {
      _setError("Error fetching pakaian list: $e");
      print("Error fetching pakaian list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil data pakaian berdasarkan ID
  Future<PakaianTradisional?> fetchPakaianById(int pakaianId) async {
    try {
      return await _repository.getPakaianById(pakaianId);
    } catch (e) {
      _setError("Error fetching pakaian by ID: $e");
      print("Error fetching pakaian by ID: $e");
      return null;
    }
  }

  /// Submit pakaian baru oleh user (akan pending validation)
  Future<bool> submitPakaianByUser({
    required int sukuId,
    required String nama,
    required String deskripsi,
    required String sejarah,
    required String bahan,
    required String kelengkapan,
    required String feature1,
    required String feature2,
    required String feature3,
    required File fotoFile,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama pakaian tidak boleh kosong");
      }

      // Check jika nama sudah ada
      final exists = await _repository.isPakaianNameExists(nama);
      if (exists) {
        throw Exception("Nama pakaian sudah ada dalam database");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
        fotoFile.path,
        bucketName,
      );

      // Create pakaian object
      final newPakaian = PakaianTradisional(
        sukuId: sukuId,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        sejarah: sejarah.trim(),
        bahan: bahan.trim(),
        kelengkapan: kelengkapan.trim(),
        feature1: feature1.trim(),
        feature2: feature2.trim(),
        feature3: feature3.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addPakaianByUser(newPakaian);

      _setSuccess(
          "Data pakaian berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting pakaian: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan pakaian baru oleh admin
  Future<void> addPakaianByAdmin(
      PakaianTradisional pakaian, {
        File? fotoFile,
        String? bucketName,
      }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = pakaian.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newPakaian = pakaian.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addPakaianByAdmin(newPakaian);

      if (pakaian.sukuId != null) {
        await fetchPakaianList(pakaian.sukuId!);
      }

      _setSuccess("Pakaian berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding pakaian: $e");
      print("Error adding pakaian: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Mengupdate data pakaian
  Future<void> updatePakaian(PakaianTradisional updatedPakaian) async {
    try {
      await _repository.updatePakaian(updatedPakaian);

      // Update lokal
      final index = _pakaianList.indexWhere((p) => p.id == updatedPakaian.id);
      if (index != -1) {
        _pakaianList[index] = updatedPakaian;
        notifyListeners();
      }

      if (updatedPakaian.sukuId != null) {
        await fetchPakaianList(updatedPakaian.sukuId!);
      }
    } catch (e) {
      _setError("Error updating pakaian: $e");
      print("Error updating pakaian: $e");
      rethrow;
    }
  }

  /// Menghapus pakaian
  Future<void> deletePakaian(int pakaianId, int sukuId) async {
    try {
      await _repository.deletePakaian(pakaianId);

      _pakaianList.removeWhere((p) => p.id == pakaianId);
      notifyListeners();

      await fetchPakaianList(sukuId);
    } catch (e) {
      _setError("Error deleting pakaian: $e");
      print("Error deleting pakaian: $e");
      rethrow;
    }
  }

  /// Mengupdate foto pakaian
  Future<void> updateFoto(int id, File file, String bucketName, int sukuId) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _pakaianList.indexWhere((p) => p.id == id);
      if (index != -1) {
        _pakaianList[index] = _pakaianList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari pakaian berdasarkan nama (local search)
  List<PakaianTradisional> searchPakaian(String query) {
    if (query.isEmpty) return _pakaianList;

    return _pakaianList.where((pakaian) =>
        pakaian.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari pakaian dari server
  Future<List<PakaianTradisional>> searchPakaianFromServer(String query) async {
    try {
      return await _repository.searchPakaianByName(query);
    } catch (e) {
      _setError("Error searching pakaian: $e");
      return [];
    }
  }

  /// Mendapatkan pakaian berdasarkan ID (local)
  PakaianTradisional? getPakaianById(int id) {
    try {
      return _pakaianList.firstWhere((p) => p.id == id);
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
    _pakaianList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData(int sukuId) async {
    await fetchPakaianList(sukuId);
  }

  // Backward compatibility methods
  Future<void> fetchPakaianListBySukuId(int sukuId) async {
    await fetchPakaianList(sukuId);
  }

  Future<void> addPakaian(PakaianTradisional pakaian) async {
    await addPakaianByAdmin(pakaian);
  }
}