import 'package:flutter/material.dart';
import '../repository/tarian_tradisional_repository.dart';
import '../models/tarian_tradisional.dart';

class TarianTradisionalViewModel extends ChangeNotifier {
  final TarianTradisionalRepository _repository = TarianTradisionalRepository();
  List<TarianTradisional> _tarianList = [];
  bool _isLoading = false;

  List<TarianTradisional> get tarianList => _tarianList;
  bool get isLoading => _isLoading;

  Future<void> fetchTarianList(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _tarianList = await _repository.getTarianBySukuId(sukuId);
    } catch (e) {
      print("Error fetching tarian list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTarian(TarianTradisional tarian) async {
    await _repository.addTarian(tarian);
    await fetchTarianList(tarian.sukuId); // Refresh data
  }

  Future<void> deleteTarian(int tarianId, int sukuId) async {
    await _repository.deleteTarian(tarianId);
    await fetchTarianList(sukuId); // Refresh data
  }
}