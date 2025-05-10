import 'dart:io';

import 'package:flutter/material.dart';
import '../repository/kuliner_tradisional_repository.dart';
import '../models/kuliner_tradisional.dart';

class KulinerTradisionalViewModel extends ChangeNotifier {
  final KulinerTradisionalRepository _repository = KulinerTradisionalRepository();
  List<KulinerTradisional> _kulinerList = [];
  bool _isLoading = false;

  List<KulinerTradisional> get kulinerList => _kulinerList;
  bool get isLoading => _isLoading;

  Future<void> fetchKulinerListBySukuId(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _kulinerList = await _repository.getKulinerBySukuId(sukuId);
    } catch (e) {
      print("Error fetching kuliner list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchKulinerList(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _kulinerList = await _repository.getKulinerBySukuId(sukuId);
    } catch (e) {
      print("Error fetching kuliner list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addKuliner(KulinerTradisional kuliner) async {
    await _repository.addKuliner(kuliner);
    await fetchKulinerList(kuliner.sukuId);
  }

  Future<void> deleteKuliner(int kulinerId, int sukuId) async {
    await _repository.deleteKuliner(kulinerId);
    await fetchKulinerList(sukuId);
  }

  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
    await _repository.updateFoto(id, fotoUrl, sukuId);
    final index = _kulinerList.indexWhere((p) => p.id == id);
    if (index != -1) {
      _kulinerList[index] = _kulinerList[index].copyWith(newFoto: fotoUrl);
      notifyListeners();
    }
  }

}