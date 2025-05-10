import 'dart:io';

import 'package:flutter/material.dart';
import '../repository/rumah_adat_repository.dart';
import '../models/rumah_adat.dart';

class RumahAdatViewModel extends ChangeNotifier {
  final RumahAdatRepository _repository = RumahAdatRepository();
  List<RumahAdat> _rumahAdatList = [];
  bool _isLoading = false;

  List<RumahAdat> get rumahAdatList => _rumahAdatList;
  bool get isLoading => _isLoading;

  Future<void> fetchRumahAdatListBySukuId(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _rumahAdatList = await _repository.getRumahAdatBySukuId(sukuId);
    } catch (e) {
      print("Error fetching rumah adat list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRumahAdatList(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _rumahAdatList = await _repository.getRumahAdatBySukuId(sukuId);
    } catch (e) {
      print("Error fetching rumah adat list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRumahAdat(RumahAdat rumahAdat) async {
    await _repository.addRumahAdat(rumahAdat);
    await fetchRumahAdatList(rumahAdat.sukuId);
  }

  Future<void> deleteRumahAdat(int rumahAdatId, int sukuId) async {
    await _repository.deleteRumahAdat(rumahAdatId);
    await fetchRumahAdatList(sukuId);
  }

  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
    await _repository.updateFoto(id, fotoUrl, sukuId);
    final index = _rumahAdatList.indexWhere((p) => p.id == id);
    if (index != -1) {
      _rumahAdatList[index] = _rumahAdatList[index].copyWith(newFoto: fotoUrl);
      notifyListeners();
    }
  }

}