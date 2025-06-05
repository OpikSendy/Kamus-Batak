import 'dart:io';

import 'package:flutter/material.dart';
import '../repository/suku_repository.dart';
import '../models/suku.dart';

class SukuViewModel extends ChangeNotifier {
  final SukuRepository _repository = SukuRepository();
  List<Suku> _sukuList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Suku> get sukuList => _sukuList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Mengambil semua data suku
  Future<void> fetchSukuList() async {
    _setLoading(true);
    _clearError();

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
  Future<void> fetchSukuListById(int sukuId) async {
    _setLoading(true);
    _clearError();

    try {
      _sukuList = await _repository.getAllSuku();
      _sukuList = _sukuList.where((suku) => suku.id == sukuId).toList();
    } catch (e) {
      _setError("Error fetching suku list by ID: $e");
      print("Error fetching suku list by ID: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// Menambahkan suku baru
  Future<void> addSuku(Suku suku) async {
    try {
      await _repository.addSuku(suku);
      await fetchSukuList(); // Refresh data setelah menambah
    } catch (e) {
      _setError("Error adding suku: $e");
      print("Error adding suku: $e");
      rethrow;
    }
  }

  /// Mengupdate data suku
  Future<void> updateSuku(Suku updatedSuku) async {
    try {
      // Note: Anda perlu menambahkan method updateSuku di repository
      // await _repository.updateSuku(updatedSuku);

      // Sementara, update lokal dulu
      final index = _sukuList.indexWhere((suku) => suku.id == updatedSuku.id);
      if (index != -1) {
        _sukuList[index] = updatedSuku;
        notifyListeners();
      }

      // Kemudian refresh dari server
      await fetchSukuList();
    } catch (e) {
      _setError("Error updating suku: $e");
      print("Error updating suku: $e");
      rethrow;
    }
  }

  /// Menghapus suku
  Future<void> deleteSuku(String sukuId) async {
    try {
      await _repository.deleteSuku(sukuId);

      // Update lokal
      _sukuList.removeWhere((suku) => suku.id.toString() == sukuId);
      notifyListeners();

      // Refresh dari server untuk memastikan konsistensi
      await fetchSukuList();
    } catch (e) {
      _setError("Error deleting suku: $e");
      print("Error deleting suku: $e");
      rethrow;
    }
  }

  /// Mengupdate foto suku
  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    try {
      final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
      await _repository.updateFoto(id, fotoUrl, sukuId);

      // Update lokal
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

  /// Mengupload foto tanpa mengupdate data suku
  Future<String> uploadFoto(String filePath, String bucketName) async {
    try {
      return await _repository.uploadFoto(filePath, bucketName);
    } catch (e) {
      _setError("Error uploading foto: $e");
      print("Error uploading foto: $e");
      rethrow;
    }
  }

  /// Mencari suku berdasarkan nama
  List<Suku> searchSuku(String query) {
    if (query.isEmpty) return _sukuList;

    return _sukuList.where((suku) =>
        suku.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Mendapatkan suku berdasarkan ID
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

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Method untuk clear data (berguna saat logout atau reset)
  void clearData() {
    _sukuList.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Method untuk refresh data
  Future<void> refreshData() async {
    await fetchSukuList();
  }
}