import 'dart:io';

import 'package:flutter/material.dart';
import '../repository/senjata_tradisional_repository.dart';
import '../models/senjata_tradisional.dart';

class SenjataTradisionalViewModel extends ChangeNotifier {
  final SenjataTradisionalRepository _repository = SenjataTradisionalRepository();
  List<SenjataTradisional> _senjataList = [];
  bool _isLoading = false;

  List<SenjataTradisional> get senjataList => _senjataList;
  bool get isLoading => _isLoading;

  Future<void> fetchSenjataListBySukuId(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _senjataList = await _repository.getSenjataBySukuId(sukuId);
    } catch (e) {
      print("Error fetching senjata list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSenjataList(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _senjataList = await _repository.getSenjataBySukuId(sukuId);
    } catch (e) {
      print("Error fetching senjata list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSenjata(SenjataTradisional senjata) async {
    await _repository.addSenjata(senjata);
    await fetchSenjataList(senjata.sukuId); // Refresh data
  }

  Future<void> deleteSenjata(int senjataId, int sukuId) async {
    await _repository.deleteSenjata(senjataId);
    await fetchSenjataList(sukuId); // Refresh data
  }

  Future<void> updateFoto(int id, File file, int sukuId, String bucketName) async {
    final fotoUrl = await _repository.uploadFoto(file.path, bucketName);
    await _repository.updateFoto(id, fotoUrl, sukuId);
    final index = _senjataList.indexWhere((p) => p.id == id);
    if (index != -1) {
      _senjataList[index] = _senjataList[index].copyWith(newFoto: fotoUrl);
      notifyListeners();
    }
  }
}