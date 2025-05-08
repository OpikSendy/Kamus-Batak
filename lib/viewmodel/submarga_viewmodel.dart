import 'package:flutter/material.dart';
import '../repository/submarga_repository.dart';
import '../models/submarga.dart';

class SubmargaViewModel extends ChangeNotifier {
  final SubmargaRepository _repository = SubmargaRepository();
  List<Submarga> _submargaList = [];
  bool _isLoading = false;

  List<Submarga> get submargaList => _submargaList;
  bool get isLoading => _isLoading;

  Future<void> fetchSubmargaList(int margaId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _submargaList = await _repository.getSubmargaByMargaId(margaId);
    } catch (e) {
      print("Error fetching submarga list: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSubmarga(Submarga submarga) async {
    await _repository.addSubmarga(submarga);
    await fetchSubmargaList(submarga.margaId); // Refresh data
  }

  Future<void> deleteSubmarga(int submargaId, int margaId) async {
    await _repository.deleteSubmarga(submargaId);
    await fetchSubmargaList(margaId); // Refresh data
  }
}