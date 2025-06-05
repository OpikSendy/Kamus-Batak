// Contoh perbaikan KomentarViewModel untuk DI
import 'package:flutter/material.dart';
import '../models/komentar.dart';
import '../repository/komentar_repository.dart';

class KomentarViewModel extends ChangeNotifier {
  final KomentarRepository _komentarRepository; // Jadikan final

  KomentarViewModel({KomentarRepository? komentarRepository}) // Terima di konstruktor
      : _komentarRepository = komentarRepository ?? KomentarRepository(); // Default jika null

  List<Komentar> _comments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Komentar> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchComments({
    required int itemId,
    required String itemType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comments = await _komentarRepository.getApprovedComments(
        itemId: itemId,
        itemType: itemType,
      );
    } catch (e) {
      _errorMessage = e.toString();
      print('Error in KomentarViewModel fetchComments: $e');
      // Anda bisa memutuskan untuk tidak rethrow di sini jika ViewModel menangani display error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment({
    required int itemId,
    required String itemType,
    required String namaAnonim,
    required String komentarText,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newComment = Komentar(
        id: 0,
        itemId: itemId,
        itemType: itemType,
        namaAnonim: namaAnonim,
        komentarText: komentarText,
        tanggalKomentar: DateTime.now(),
        isApproved: false,
      );
      await _komentarRepository.submitComment(newComment);
      // Jika berhasil menambahkan, Anda mungkin ingin melakukan refresh daftar komentar yang disetujui.
      // Namun, karena komentar baru belum disetujui, ia tidak akan muncul di daftar 'approvedComments'.
      // Ini adalah perilaku yang diinginkan sesuai deskripsi Anda.
      // Jika Anda perlu memberi tahu UI bahwa pengiriman berhasil, Anda bisa menambahkan callback atau event.
    } catch (e) {
      _errorMessage = e.toString();
      print('Error in KomentarViewModel addComment: $e');
      rethrow; // Penting untuk rethrow jika Anda ingin UI menampilkan error pop-up atau dialog
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}