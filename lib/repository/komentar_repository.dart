import '../models/komentar.dart';
import '../service/supabase_service.dart';

class KomentarRepository {
  final SupabaseService _supabaseService;

  KomentarRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  /// Ambil komentar yang sudah disetujui untuk item tertentu
  Future<List<Komentar>> getApprovedComments({
    required int itemId,
    required String itemType,
  }) async {
    return await _supabaseService.fetchApprovedComments(
      itemId: itemId,
      itemType: itemType,
    );
  }

  /// Tambahkan komentar baru (dengan status default belum disetujui)
  Future<void> submitComment(Komentar komentar) async {
    await _supabaseService.addComment(komentar);
  }
}
