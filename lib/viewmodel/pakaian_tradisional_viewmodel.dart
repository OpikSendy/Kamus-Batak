import 'package:flutter/material.dart';
import '../repository/pakaian_tradisional_repository.dart';
import '../models/pakaian_tradisional.dart';

class PakaianTradisionalViewModel extends ChangeNotifier {
  final PakaianTradisionalRepository _repository = PakaianTradisionalRepository();
  List<PakaianTradisional> _pakaianList = [];
  bool _isLoading = false;

  List<PakaianTradisional> get pakaianList => _pakaianList;
  bool get isLoading => _isLoading;

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
}