import 'dart:io';

import 'package:flutter/material.dart';
import '../repository/pakaian_tradisional_repository.dart';
import '../models/pakaian_tradisional.dart';

class PakaianTradisionalViewModel extends ChangeNotifier {
  final PakaianTradisionalRepository _repository = PakaianTradisionalRepository();
  List<PakaianTradisional> _pakaianList = [];
  bool _isLoading = false;

  List<PakaianTradisional> get pakaianList => _pakaianList;
  bool get isLoading => _isLoading;

  Future<void> fetchPakaianListBySukuId(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _pakaianList = await _repository.getPakaianBySukuId(sukuId);
    } catch (e) {
      print("Error fetching pakaian list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPakaianList(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _pakaianList = await _repository.getPakaianBySukuId(sukuId);
    } catch (e) {
      print("Error fetching pakaian list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPakaian(PakaianTradisional pakaian) async {
    await _repository.addPakaian(pakaian);
    await fetchPakaianList(pakaian.sukuId);
  }

  Future<void> deletePakaian(int pakaianId, int sukuId) async {
    await _repository.deletePakaian(pakaianId);
    await fetchPakaianList(sukuId);
  }

  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
    await _repository.updateFoto(id, fotoUrl, sukuId);
    final index = _pakaianList.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pakaianList[index] = _pakaianList[index].copyWith(newFoto: fotoUrl);
      notifyListeners();
    }
  }

}