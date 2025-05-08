import 'package:flutter/material.dart';
import '../repository/marga_repository.dart';
import '../models/marga.dart';

class MargaViewModel extends ChangeNotifier {
  final MargaRepository _repository = MargaRepository();
  List<Marga> _margaList = [];
  bool _isLoading = false;

  List<Marga> get margaList => _margaList;
  bool get isLoading => _isLoading;

  Future<void> fetchMargaList(int sukuId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _margaList = await _repository.getMargaBySukuId(sukuId);
    } catch (e) {
      print("Error fetching marga list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMarga(Marga marga) async {
    await _repository.addMarga(marga);
    await fetchMargaList(marga.sukuId);
  }

  Future<void> deleteMarga(int margaId, int sukuId) async {
    await _repository.deleteMarga(margaId);
    await fetchMargaList(sukuId);
  }
}
