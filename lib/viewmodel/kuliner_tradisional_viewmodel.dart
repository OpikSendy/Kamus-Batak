import 'package:flutter/material.dart';
import '../repository/kuliner_tradisional_repository.dart';
import '../models/kuliner_tradisional.dart';

class KulinerTradisionalViewModel extends ChangeNotifier {
  final KulinerTradisionalRepository _repository = KulinerTradisionalRepository();

  List<KulinerTradisional> _kulinerList = []; // Untuk daftar kuliner (misal di halaman daftar utama)
  KulinerTradisional? _currentKulinerDetail; // Untuk detail kuliner tunggal di halaman ini

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<KulinerTradisional> get kulinerList => _kulinerList;
  KulinerTradisional? get currentKulinerDetail => _currentKulinerDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Metode untuk Halaman Daftar Kuliner ---
  // Mengambil daftar kuliner berdasarkan sukuId
  Future<void> fetchKulinerListBySukuId(int sukuId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _kulinerList = await _repository.getKulinerBySukuId(sukuId);
    } catch (e) {
      _errorMessage = "Gagal memuat daftar kuliner: $e";
      print("Error fetching kuliner list: $e");
      _kulinerList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Metode untuk Halaman Detail Kuliner (Yang Anda Perlukan Sekarang) ---
  // Mengambil detail satu kuliner berdasarkan kulinerId
  Future<void> fetchKulinerDetail(int kulinerId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentKulinerDetail = null; // Reset detail sebelumnya
    notifyListeners();
    try {
      // Pastikan ada metode getKulinerById di KulinerTradisionalRepository
      _currentKulinerDetail = await _repository.getKulinerById(kulinerId);
    } catch (e) {
      _errorMessage = "Gagal memuat detail kuliner: $e";
      print("Error fetching kuliner detail: $e");
      _currentKulinerDetail = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Metode untuk Manajemen Data (Add/Delete) ---
  Future<void> addKuliner(KulinerTradisional kuliner) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.addKuliner(kuliner);
      // Anda mungkin ingin memanggil fetchKulinerListBySukuId jika ini memengaruhi daftar
      // atau fetchKulinerDetail jika Anda ingin menampilkan detail yang baru ditambahkan.
      // Untuk tujuan tampilan detail, ini mungkin tidak langsung relevan.
    } catch (e) {
      _errorMessage = "Gagal menambahkan kuliner: $e";
      print("Error adding kuliner: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteKuliner(int kulinerId, int sukuId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _repository.deleteKuliner(kulinerId);
      // Setelah menghapus, refresh daftar kuliner terkait suku ID
      // Ini akan relevan jika Anda kembali ke halaman daftar.
      await fetchKulinerListBySukuId(sukuId);
    } catch (e) {
      _errorMessage = "Gagal menghapus kuliner: $e";
      print("Error deleting kuliner: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}