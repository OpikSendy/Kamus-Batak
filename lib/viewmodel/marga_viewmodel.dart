// lib/viewmodel/marga_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/marga_repository.dart';
import '../models/marga.dart';

class MargaViewModel extends ChangeNotifier {
  final MargaRepository _repository = MargaRepository();
  List<Marga> _margaList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<Marga> get margaList => _margaList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua data marga yang sudah validated berdasarkan suku ID
  Future<void> fetchMargaList(int sukuId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _margaList = await _repository.getMargaBySukuId(sukuId);
    } catch (e) {
      _setError("Error fetching marga list: $e");
      print("Error fetching marga list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil data marga berdasarkan ID
  Future<Marga?> fetchMargaById(int margaId) async {
    try {
      return await _repository.getMargaById(margaId);
    } catch (e) {
      _setError("Error fetching marga by ID: $e");
      print("Error fetching marga by ID: $e");
      return null;
    }
  }

  /// Submit marga baru oleh user (akan pending validation)
  Future<bool> submitMargaByUser({
    required int sukuId,
    required String nama,
    required String deskripsi,
    required File fotoFile,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama marga tidak boleh kosong");
      }

      // Validasi deskripsi
      if (deskripsi.trim().isEmpty) {
        throw Exception("Deskripsi tidak boleh kosong");
      }

      // Check jika nama sudah ada untuk suku ini
      final exists = await _repository.isMargaNameExists(nama, sukuId);
      if (exists) {
        throw Exception("Nama marga sudah ada dalam database untuk suku ini");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create marga object
      final newMarga = Marga(
        sukuId: sukuId,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addMargaByUser(newMarga);

      _setSuccess(
          "Data marga berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting marga: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan marga baru oleh admin
  Future<void> addMargaByAdmin(Marga marga, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = marga.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newMarga = marga.copyWith(
        foto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addMargaByAdmin(newMarga);
      await fetchMargaList(marga.sukuId);

      _setSuccess("Marga berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding marga: $e");
      print("Error adding marga: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Mengupdate data marga
  Future<void> updateMarga(Marga updatedMarga) async {
    try {
      await _repository.updateMarga(updatedMarga);

      // Update lokal
      final index = _margaList.indexWhere((marga) => marga.id == updatedMarga.id);
      if (index != -1) {
        _margaList[index] = updatedMarga;
        notifyListeners();
      }

      await fetchMargaList(updatedMarga.sukuId);
    } catch (e) {
      _setError("Error updating marga: $e");
      print("Error updating marga: $e");
      rethrow;
    }
  }

  /// Menghapus marga
  Future<void> deleteMarga(int margaId, int sukuId) async {
    try {
      await _repository.deleteMarga(margaId);

      _margaList.removeWhere((marga) => marga.id == margaId);
      notifyListeners();

      await fetchMargaList(sukuId);
    } catch (e) {
      _setError("Error deleting marga: $e");
      print("Error deleting marga: $e");
      rethrow;
    }
  }

  /// Mengupdate foto marga
  Future<void> updateFoto(int id, int sukuId, File file, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _margaList.indexWhere((marga) => marga.id == id);
      if (index != -1) {
        _margaList[index] = _margaList[index].copyWith(foto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari marga berdasarkan nama (local search)
  List<Marga> searchMarga(String query) {
    if (query.isEmpty) return _margaList;

    return _margaList.where((marga) =>
        marga.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari marga dari server
  Future<List<Marga>> searchMargaFromServer(String query, int sukuId) async {
    try {
      return await _repository.searchMargaByName(query, sukuId);
    } catch (e) {
      _setError("Error searching marga: $e");
      return [];
    }
  }

  /// Mendapatkan marga berdasarkan ID (local)
  Marga? getMargaById(int id) {
    try {
      return _margaList.firstWhere((marga) => marga.id == id);
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
    _margaList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData(int sukuId) async {
    await fetchMargaList(sukuId);
  }
}