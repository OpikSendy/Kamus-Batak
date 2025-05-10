import 'dart:io';

import 'package:flutter/material.dart';
import '../repository/suku_repository.dart';
import '../models/suku.dart';

class SukuViewModel extends ChangeNotifier {
  final SukuRepository _repository = SukuRepository();
  List<Suku> _sukuList = [];
  bool _isLoading = false;

  List<Suku> get sukuList => _sukuList;
  bool get isLoading => _isLoading;

  Future<void> fetchSukuListById(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _sukuList = await _repository.getAllSuku();
      _sukuList = _sukuList.where((suku) => suku.id == sukuId).toList();
    } catch (e) {
      // Show error dialog or snackbar here
      print("Error fetching suku list by ID: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSukuList() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sukuList = await _repository.getAllSuku();
    } catch (e) {
      // Show error dialog or snackbar here
      print("Error fetching suku list: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSuku(Suku suku) async {
    try {
      await _repository.addSuku(suku);
      await fetchSukuList();
    } catch (e) {
      print("Error adding suku: $e");
    }
  }

  Future<void> deleteSuku(String sukuId) async {
    try {
      await _repository.deleteSuku(sukuId);
      await fetchSukuList();
    } catch (e) {
      print("Error deleting suku: $e");
    }
  }

  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
    await _repository.updateFoto(id, fotoUrl, sukuId);
    final index = _sukuList.indexWhere((p) => p.id == id);
    if (index != -1) {
      _sukuList[index] = _sukuList[index].copyWith(newFoto: fotoUrl);
      notifyListeners();
    }
  }

}