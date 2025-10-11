// lib/viewmodel/kuliner_tradisional_viewmodel.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/kuliner_tradisional_repository.dart';
import '../models/kuliner_tradisional.dart';

class KulinerTradisionalViewModel extends ChangeNotifier {
  final KulinerTradisionalRepository _repository = KulinerTradisionalRepository();
  List<KulinerTradisional> _kulinerList = [];
  KulinerTradisional? _currentKulinerDetail;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<KulinerTradisional> get kulinerList => _kulinerList;
  KulinerTradisional? get currentKulinerDetail => _currentKulinerDetail;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua data kuliner yang sudah validated berdasarkan suku
  Future<void> fetchKulinerListBySukuId(int sukuId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _kulinerList = await _repository.getKulinerBySukuId(sukuId);
    } catch (e) {
      _setError("Error fetching kuliner list: $e");
      print("Error fetching kuliner list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Mengambil data kuliner berdasarkan ID (untuk detail page)
  Future<void> fetchKulinerDetail(int kulinerId) async {
    _setLoading(true);
    _clearMessages();
    _currentKulinerDetail = null;

    try {
      _currentKulinerDetail = await _repository.getKulinerById(kulinerId);
    } catch (e) {
      _setError("Error fetching kuliner detail: $e");
      print("Error fetching kuliner detail: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Submit kuliner baru oleh user (akan pending validation)
  Future<bool> submitKulinerByUser({
    required int sukuId,
    required String jenis,
    required String nama,
    required File fotoFile,
    required String deskripsi,
    required String rating,
    required String waktu,
    required String resep,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama kuliner tidak boleh kosong");
      }

      // Check jika nama sudah ada
      final exists = await _repository.isKulinerNameExists(nama);
      if (exists) {
        throw Exception("Nama kuliner sudah ada dalam database");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create kuliner object
      final newKuliner = KulinerTradisional(
        sukuId: sukuId,
        jenis: jenis,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        rating: rating,
        waktu: waktu,
        resep: resep.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addKulinerByUser(newKuliner);

      _setSuccess(
          "Data kuliner berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting kuliner: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan kuliner baru oleh admin
  Future<void> addKulinerByAdmin(KulinerTradisional kuliner, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = kuliner.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newKuliner = kuliner.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addKulinerByAdmin(newKuliner);

      _setSuccess("Kuliner berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding kuliner: $e");
      print("Error adding kuliner: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Mengupdate data kuliner
  Future<void> updateKuliner(KulinerTradisional updatedKuliner) async {
    try {
      await _repository.updateKuliner(updatedKuliner);

      // Update lokal
      final index = _kulinerList.indexWhere((kuliner) => kuliner.id == updatedKuliner.id);
      if (index != -1) {
        _kulinerList[index] = updatedKuliner;
        notifyListeners();
      }

      // Update detail jika sedang melihat detail kuliner ini
      if (_currentKulinerDetail?.id == updatedKuliner.id) {
        _currentKulinerDetail = updatedKuliner;
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating kuliner: $e");
      print("Error updating kuliner: $e");
      rethrow;
    }
  }

  /// Menghapus kuliner
  Future<void> deleteKuliner(int kulinerId, int sukuId) async {
    try {
      await _repository.deleteKuliner(kulinerId);

      _kulinerList.removeWhere((kuliner) => kuliner.id == kulinerId);
      notifyListeners();

      await fetchKulinerListBySukuId(sukuId);
    } catch (e) {
      _setError("Error deleting kuliner: $e");
      print("Error deleting kuliner: $e");
      rethrow;
    }
  }

  /// Mengupdate foto kuliner
  Future<void> updateFoto(int id, File file, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl);

      final index = _kulinerList.indexWhere((kuliner) => kuliner.id == id);
      if (index != -1) {
        _kulinerList[index] = _kulinerList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }

      // Update detail jika sedang melihat detail kuliner ini
      if (_currentKulinerDetail?.id == id) {
        _currentKulinerDetail = _currentKulinerDetail!.copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari kuliner berdasarkan nama (local search)
  List<KulinerTradisional> searchKuliner(String query) {
    if (query.isEmpty) return _kulinerList;

    return _kulinerList.where((kuliner) =>
        kuliner.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari kuliner dari server
  Future<List<KulinerTradisional>> searchKulinerFromServer(String query) async {
    try {
      return await _repository.searchKulinerByName(query);
    } catch (e) {
      _setError("Error searching kuliner: $e");
      return [];
    }
  }

  /// Mendapatkan kuliner berdasarkan ID (local)
  KulinerTradisional? getKulinerById(int id) {
    try {
      return _kulinerList.firstWhere((kuliner) => kuliner.id == id);
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
    _kulinerList.clear();
    _currentKulinerDetail = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data berdasarkan suku
  Future<void> refreshData(int sukuId) async {
    await fetchKulinerListBySukuId(sukuId);
  }
}