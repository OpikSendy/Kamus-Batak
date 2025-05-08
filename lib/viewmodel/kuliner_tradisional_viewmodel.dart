import 'package:flutter/material.dart';
import '../repository/kuliner_tradisional_repository.dart';
import '../models/kuliner_tradisional.dart';

class KulinerTradisionalViewModel extends ChangeNotifier {
  final KulinerTradisionalRepository _repository = KulinerTradisionalRepository();
  List<KulinerTradisional> _kulinerList = [];
  bool _isLoading = false;

  List<KulinerTradisional> get kulinerList => _kulinerList;
  bool get isLoading => _isLoading;

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
}