// lib/viewmodel/rumah_adat_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/rumah_adat_repository.dart';
import '../models/rumah_adat.dart';

class RumahAdatViewModel extends ChangeNotifier {
  final RumahAdatRepository _repository = RumahAdatRepository();
  List<RumahAdat> _rumahAdatList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<RumahAdat> get rumahAdatList => _rumahAdatList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua data rumah adat yang sudah validated berdasarkan suku
  Future<void> fetchRumahAdatListBySukuId(int sukuId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _rumahAdatList = await _repository.getRumahAdatBySukuId(sukuId);
    } catch (e) {
      _setError("Error fetching rumah adat list: $e");
      print("Error fetching rumah adat list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Alias untuk fetchRumahAdatListBySukuId
  Future<void> fetchRumahAdatList(int sukuId) async {
    await fetchRumahAdatListBySukuId(sukuId);
  }

  /// Mengambil data rumah adat berdasarkan ID
  Future<RumahAdat?> fetchRumahAdatById(int rumahAdatId) async {
    try {
      return await _repository.getRumahAdatById(rumahAdatId);
    } catch (e) {
      _setError("Error fetching rumah adat by ID: $e");
      print("Error fetching rumah adat by ID: $e");
      return null;
    }
  }

  /// Submit rumah adat baru oleh user (akan pending validation)
  Future<bool> submitRumahAdatByUser({
    required int sukuId,
    required String nama,
    required File fotoFile,
    required String deskripsi,
    required String feature1,
    required String feature2,
    required String feature3,
    required String item1,
    required String item2,
    required String item3,
    required String sejarah,
    required String bangunan,
    required String ornamen,
    required String fungsi,
    required String pelestarian,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama rumah adat tidak boleh kosong");
      }

      // Check jika nama sudah ada untuk suku ini
      final exists = await _repository.isRumahAdatNameExists(nama, sukuId);
      if (exists) {
        throw Exception("Nama rumah adat sudah ada untuk suku ini");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create rumah adat object
      final newRumahAdat = RumahAdat(
        sukuId: sukuId,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        feature1: feature1.trim(),
        feature2: feature2.trim(),
        feature3: feature3.trim(),
        item1: item1.trim(),
        item2: item2.trim(),
        item3: item3.trim(),
        sejarah: sejarah.trim(),
        bangunan: bangunan.trim(),
        ornamen: ornamen.trim(),
        fungsi: fungsi.trim(),
        pelestarian: pelestarian.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addRumahAdatByUser(newRumahAdat);

      _setSuccess(
          "Data rumah adat berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting rumah adat: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan rumah adat baru oleh admin
  Future<void> addRumahAdatByAdmin(RumahAdat rumahAdat, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = rumahAdat.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newRumahAdat = rumahAdat.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addRumahAdatByAdmin(newRumahAdat);
      await fetchRumahAdatList(rumahAdat.sukuId);

      _setSuccess("Rumah adat berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding rumah adat: $e");
      print("Error adding rumah adat: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan rumah adat (legacy method untuk backward compatibility)
  Future<void> addRumahAdat(RumahAdat rumahAdat) async {
    await _repository.addRumahAdatByUser(rumahAdat);
    await fetchRumahAdatList(rumahAdat.sukuId);
  }

  /// Mengupdate data rumah adat
  Future<void> updateRumahAdat(RumahAdat updatedRumahAdat) async {
    try {
      await _repository.updateRumahAdat(updatedRumahAdat);

      // Update lokal
      final index = _rumahAdatList.indexWhere((ra) => ra.id == updatedRumahAdat.id);
      if (index != -1) {
        _rumahAdatList[index] = updatedRumahAdat;
        notifyListeners();
      }

      await fetchRumahAdatList(updatedRumahAdat.sukuId);
    } catch (e) {
      _setError("Error updating rumah adat: $e");
      print("Error updating rumah adat: $e");
      rethrow;
    }
  }

  /// Menghapus rumah adat
  Future<void> deleteRumahAdat(int rumahAdatId, int sukuId) async {
    try {
      await _repository.deleteRumahAdat(rumahAdatId);

      _rumahAdatList.removeWhere((ra) => ra.id == rumahAdatId);
      notifyListeners();

      await fetchRumahAdatList(sukuId);
    } catch (e) {
      _setError("Error deleting rumah adat: $e");
      print("Error deleting rumah adat: $e");
      rethrow;
    }
  }

  /// Mengupdate foto rumah adat
  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _rumahAdatList.indexWhere((ra) => ra.id == id);
      if (index != -1) {
        _rumahAdatList[index] = _rumahAdatList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari rumah adat berdasarkan nama (local search)
  List<RumahAdat> searchRumahAdat(String query) {
    if (query.isEmpty) return _rumahAdatList;

    return _rumahAdatList.where((ra) =>
        ra.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari rumah adat dari server
  Future<List<RumahAdat>> searchRumahAdatFromServer(String query) async {
    try {
      return await _repository.searchRumahAdatByName(query);
    } catch (e) {
      _setError("Error searching rumah adat: $e");
      return [];
    }
  }

  /// Mendapatkan rumah adat berdasarkan ID (local)
  RumahAdat? getRumahAdatById(int id) {
    try {
      return _rumahAdatList.firstWhere((ra) => ra.id == id);
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
    _rumahAdatList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData(int sukuId) async {
    await fetchRumahAdatList(sukuId);
  }
}