// lib/viewmodel/tarian_tradisional_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/tarian_tradisional_repository.dart';
import '../models/tarian_tradisional.dart';

class TarianTradisionalViewModel extends ChangeNotifier {
  final TarianTradisionalRepository _repository = TarianTradisionalRepository();
  List<TarianTradisional> _tarianList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<TarianTradisional> get tarianList => _tarianList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua data tarian yang sudah validated
  Future<void> fetchTarianListBySukuId(int sukuId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _tarianList = await _repository.getTarianBySukuId(sukuId);
    } catch (e) {
      _setError("Error fetching tarian list: $e");
      print("Error fetching tarian list: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTarianList(int sukuId) async {
    await fetchTarianListBySukuId(sukuId);
  }

  /// Mengambil data tarian berdasarkan ID
  Future<TarianTradisional?> fetchTarianById(int tarianId) async {
    try {
      return await _repository.getTarianById(tarianId);
    } catch (e) {
      _setError("Error fetching tarian by ID: $e");
      print("Error fetching tarian by ID: $e");
      return null;
    }
  }

  /// Submit tarian baru oleh user (akan pending validation)
  Future<bool> submitTarianByUser({
    required int sukuId,
    required String nama,
    required String deskripsi,
    required String sejarah,
    required String gerakan,
    required String kostum,
    required String feature1,
    required String feature2,
    required String feature3,
    required String video,
    required String kategori,
    required String durasi,
    required String event,
    required File fotoFile,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama tarian tidak boleh kosong");
      }

      // Check jika nama sudah ada
      final exists = await _repository.isTarianNameExists(nama, sukuId);
      if (exists) {
        throw Exception("Nama tarian sudah ada dalam database");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create tarian object
      final newTarian = TarianTradisional(
        sukuId: sukuId,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        sejarah: sejarah.trim(),
        gerakan: gerakan.trim(),
        kostum: kostum.trim(),
        feature1: feature1.trim(),
        feature2: feature2.trim(),
        feature3: feature3.trim(),
        video: video.trim(),
        kategori: kategori.trim(),
        durasi: durasi.trim(),
        event: event.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addTarianByUser(newTarian);

      _setSuccess(
          "Data tarian berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting tarian: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan tarian baru oleh admin
  Future<void> addTarianByAdmin(TarianTradisional tarian, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = tarian.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newTarian = tarian.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addTarianByAdmin(newTarian);
      await fetchTarianList(tarian.sukuId);

      _setSuccess("Tarian berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding tarian: $e");
      print("Error adding tarian: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan tarian (legacy method untuk kompatibilitas)
  Future<void> addTarian(TarianTradisional tarian) async {
    await addTarianByAdmin(tarian);
  }

  /// Mengupdate data tarian
  Future<void> updateTarian(TarianTradisional updatedTarian) async {
    try {
      await _repository.updateTarian(updatedTarian);

      // Update lokal
      final index = _tarianList.indexWhere((tarian) => tarian.id == updatedTarian.id);
      if (index != -1) {
        _tarianList[index] = updatedTarian;
        notifyListeners();
      }

      await fetchTarianList(updatedTarian.sukuId);
    } catch (e) {
      _setError("Error updating tarian: $e");
      print("Error updating tarian: $e");
      rethrow;
    }
  }

  /// Menghapus tarian
  Future<void> deleteTarian(int tarianId, int sukuId) async {
    try {
      await _repository.deleteTarian(tarianId);

      _tarianList.removeWhere((tarian) => tarian.id == tarianId);
      notifyListeners();

      await fetchTarianList(sukuId);
    } catch (e) {
      _setError("Error deleting tarian: $e");
      print("Error deleting tarian: $e");
      rethrow;
    }
  }

  /// Mengupdate foto tarian
  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _tarianList.indexWhere((tarian) => tarian.id == id);
      if (index != -1) {
        _tarianList[index] = _tarianList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari tarian berdasarkan nama (local search)
  List<TarianTradisional> searchTarian(String query) {
    if (query.isEmpty) return _tarianList;

    return _tarianList.where((tarian) =>
        tarian.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari tarian dari server
  Future<List<TarianTradisional>> searchTarianFromServer(String query, int sukuId) async {
    try {
      return await _repository.searchTarianByName(query, sukuId);
    } catch (e) {
      _setError("Error searching tarian: $e");
      return [];
    }
  }

  /// Mendapatkan tarian berdasarkan ID (local)
  TarianTradisional? getTarianById(int id) {
    try {
      return _tarianList.firstWhere((tarian) => tarian.id == id);
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
    _tarianList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData(int sukuId) async {
    await fetchTarianList(sukuId);
  }
}