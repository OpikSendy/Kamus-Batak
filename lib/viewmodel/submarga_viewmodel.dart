// lib/viewmodel/submarga_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/submarga_repository.dart';
import '../models/submarga.dart';

class SubmargaViewModel extends ChangeNotifier {
  final SubmargaRepository _repository = SubmargaRepository();
  List<Submarga> _submargaList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<Submarga> get submargaList => _submargaList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua submarga untuk marga tertentu yang sudah validated
  Future<void> fetchSubmargaList(int margaId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _submargaList = await _repository.getSubmargaByMargaId(margaId);
    } catch (e) {
      _setError("Error fetching submarga list: $e");
      print("Error fetching submarga list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil data submarga berdasarkan ID
  Future<Submarga?> fetchSubmargaById(int submargaId) async {
    try {
      return await _repository.getSubmargaById(submargaId);
    } catch (e) {
      _setError("Error fetching submarga by ID: $e");
      print("Error fetching submarga by ID: $e");
      return null;
    }
  }

  /// Submit submarga baru oleh user (akan pending validation)
  Future<bool> submitSubmargaByUser({
    required int margaId,
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
        throw Exception("Nama submarga tidak boleh kosong");
      }

      // Validasi deskripsi
      if (deskripsi.trim().isEmpty) {
        throw Exception("Deskripsi submarga tidak boleh kosong");
      }

      // Check jika nama sudah ada di marga ini
      final exists = await _repository.isSubmargaNameExists(nama, margaId);
      if (exists) {
        throw Exception("Nama submarga sudah ada dalam marga ini");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create submarga object
      final newSubmarga = Submarga(
        margaId: margaId,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addSubmargaByUser(newSubmarga);

      _setSuccess(
          "Data submarga berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting submarga: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan submarga baru oleh admin
  Future<void> addSubmargaByAdmin(Submarga submarga, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = submarga.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newSubmarga = submarga.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addSubmargaByAdmin(newSubmarga);
      await fetchSubmargaList(submarga.margaId);

      _setSuccess("Submarga berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding submarga: $e");
      print("Error adding submarga: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Mengupdate data submarga
  Future<void> updateSubmarga(Submarga updatedSubmarga) async {
    try {
      await _repository.updateSubmarga(updatedSubmarga);

      // Update lokal
      final index = _submargaList.indexWhere((submarga) => submarga.id == updatedSubmarga.id);
      if (index != -1) {
        _submargaList[index] = updatedSubmarga;
        notifyListeners();
      }

      await fetchSubmargaList(updatedSubmarga.margaId);
    } catch (e) {
      _setError("Error updating submarga: $e");
      print("Error updating submarga: $e");
      rethrow;
    }
  }

  /// Menghapus submarga
  Future<void> deleteSubmarga(int submargaId, int margaId) async {
    try {
      await _repository.deleteSubmarga(submargaId);

      _submargaList.removeWhere((submarga) => submarga.id == submargaId);
      notifyListeners();

      await fetchSubmargaList(margaId);
    } catch (e) {
      _setError("Error deleting submarga: $e");
      print("Error deleting submarga: $e");
      rethrow;
    }
  }

  /// Mengupdate foto submarga
  Future<void> updateFoto(int id, File file, String bucketName, int margaId) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _submargaList.indexWhere((submarga) => submarga.id == id);
      if (index != -1) {
        _submargaList[index] = _submargaList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari submarga berdasarkan nama (local search)
  List<Submarga> searchSubmarga(String query) {
    if (query.isEmpty) return _submargaList;

    return _submargaList.where((submarga) =>
        submarga.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari submarga dari server
  Future<List<Submarga>> searchSubmargaFromServer(String query, int margaId) async {
    try {
      return await _repository.searchSubmargaByName(query, margaId);
    } catch (e) {
      _setError("Error searching submarga: $e");
      return [];
    }
  }

  /// Mendapatkan submarga berdasarkan ID (local)
  Submarga? getSubmargaById(int id) {
    try {
      return _submargaList.firstWhere((submarga) => submarga.id == id);
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
    _submargaList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData(int margaId) async {
    await fetchSubmargaList(margaId);
  }
}