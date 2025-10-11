import 'dart:io';
import 'package:flutter/material.dart';
import '../repository/senjata_tradisional_repository.dart';
import '../models/senjata_tradisional.dart';

class SenjataTradisionalViewModel extends ChangeNotifier {
  final SenjataTradisionalRepository _repository = SenjataTradisionalRepository();
  List<SenjataTradisional> _senjataList = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  List<SenjataTradisional> get senjataList => _senjataList;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Mengambil semua senjata yang sudah validated berdasarkan suku
  Future<void> fetchSenjataListBySukuId(int sukuId) async {
    _setLoading(true);
    _clearMessages();

    try {
      _senjataList = await _repository.getSenjataBySukuId(sukuId);
    } catch (e) {
      _setError("Error fetching senjata list: $e");
      print("Error fetching senjata list: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Alias untuk fetchSenjataListBySukuId
  Future<void> fetchSenjataList(int sukuId) async {
    await fetchSenjataListBySukuId(sukuId);
  }

  /// Mengambil data senjata berdasarkan ID
  Future<SenjataTradisional?> fetchSenjataById(int senjataId) async {
    try {
      return await _repository.getSenjataById(senjataId);
    } catch (e) {
      _setError("Error fetching senjata by ID: $e");
      print("Error fetching senjata by ID: $e");
      return null;
    }
  }

  /// Submit senjata baru oleh user (akan pending validation)
  Future<bool> submitSenjataByUser({
    required int sukuId,
    required String nama,
    required File fotoFile,
    required String deskripsi,
    required String feature1,
    required String feature2,
    required String feature3,
    required String sejarah,
    required String material,
    required String simbol,
    required String penggunaan,
    required String pertahanan,
    required String perburuan,
    required String seremonial,
    required String bucketName,
  }) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      // Validasi nama
      if (nama.trim().isEmpty) {
        throw Exception("Nama senjata tidak boleh kosong");
      }

      // Check jika nama sudah ada
      final exists = await _repository.isSenjataNameExists(nama);
      if (exists) {
        throw Exception("Nama senjata sudah ada dalam database");
      }

      // Upload foto
      final fotoUrl = await _repository.uploadFoto(
          fotoFile.path,
          bucketName
      );

      // Create senjata object
      final newSenjata = SenjataTradisional(
        id: 0,
        sukuId: sukuId,
        nama: nama.trim(),
        foto: fotoUrl,
        deskripsi: deskripsi.trim(),
        feature1: feature1.trim(),
        feature2: feature2.trim(),
        feature3: feature3.trim(),
        sejarah: sejarah.trim(),
        material: material.trim(),
        simbol: simbol.trim(),
        penggunaan: penggunaan.trim(),
        pertahanan: pertahanan.trim(),
        perburuan: perburuan.trim(),
        seremonial: seremonial.trim(),
        inputSource: 'user',
        isValidated: false,
        createdAt: DateTime.now(),
      );

      // Submit ke database
      await _repository.addSenjataByUser(newSenjata);

      _setSuccess(
          "Data senjata tradisional berhasil dikirim! "
              "Menunggu validasi dari admin."
      );

      return true;
    } catch (e) {
      _setError("Gagal mengirim data: ${e.toString()}");
      print("Error submitting senjata: $e");
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan senjata baru oleh admin
  Future<void> addSenjataByAdmin(SenjataTradisional senjata, {File? fotoFile, String? bucketName}) async {
    _setSubmitting(true);
    _clearMessages();

    try {
      String fotoUrl = senjata.foto;

      // Upload foto jika ada
      if (fotoFile != null && bucketName != null) {
        fotoUrl = await _repository.uploadFoto(fotoFile.path, bucketName);
      }

      final newSenjata = senjata.copyWith(
        newFoto: fotoUrl,
        inputSource: 'admin',
        isValidated: true,
      );

      await _repository.addSenjataByAdmin(newSenjata);
      await fetchSenjataList(newSenjata.sukuId);

      _setSuccess("Senjata berhasil ditambahkan");
    } catch (e) {
      _setError("Error adding senjata: $e");
      print("Error adding senjata: $e");
      rethrow;
    } finally {
      _setSubmitting(false);
    }
  }

  /// Menambahkan senjata (alias untuk backward compatibility)
  Future<void> addSenjata(SenjataTradisional senjata) async {
    await _repository.addSenjataByUser(senjata);
    await fetchSenjataList(senjata.sukuId);
  }

  /// Mengupdate data senjata
  Future<void> updateSenjata(SenjataTradisional updatedSenjata) async {
    try {
      await _repository.updateSenjata(updatedSenjata);

      // Update lokal
      final index = _senjataList.indexWhere((senjata) => senjata.id == updatedSenjata.id);
      if (index != -1) {
        _senjataList[index] = updatedSenjata;
        notifyListeners();
      }

      await fetchSenjataList(updatedSenjata.sukuId);
    } catch (e) {
      _setError("Error updating senjata: $e");
      print("Error updating senjata: $e");
      rethrow;
    }
  }

  /// Menghapus senjata
  Future<void> deleteSenjata(int senjataId, int sukuId) async {
    try {
      await _repository.deleteSenjata(senjataId);

      _senjataList.removeWhere((senjata) => senjata.id == senjataId);
      notifyListeners();

      await fetchSenjataList(sukuId);
    } catch (e) {
      _setError("Error deleting senjata: $e");
      print("Error deleting senjata: $e");
      rethrow;
    }
  }

  /// Mengupdate foto senjata
  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl, sukuId);

      final index = _senjataList.indexWhere((senjata) => senjata.id == id);
      if (index != -1) {
        _senjataList[index] = _senjataList[index].copyWith(newFoto: fotoUrl);
        notifyListeners();
      }
    } catch (e) {
      _setError("Error updating foto: $e");
      print("Error updating foto: $e");
      rethrow;
    }
  }

  /// Mencari senjata berdasarkan nama (local search)
  List<SenjataTradisional> searchSenjata(String query) {
    if (query.isEmpty) return _senjataList;

    return _senjataList.where((senjata) =>
        senjata.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mencari senjata dari server
  Future<List<SenjataTradisional>> searchSenjataFromServer(String query) async {
    try {
      return await _repository.searchSenjataByName(query);
    } catch (e) {
      _setError("Error searching senjata: $e");
      return [];
    }
  }

  /// Mendapatkan senjata berdasarkan ID (local)
  SenjataTradisional? getSenjataById(int id) {
    try {
      return _senjataList.firstWhere((senjata) => senjata.id == id);
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
    _senjataList.clear();
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData(int sukuId) async {
    await fetchSenjataList(sukuId);
  }
}