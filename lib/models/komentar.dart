// lib/models/komentar.dart
class Komentar {
  final int id; // ID unik komentar, biasanya auto-increment dari Supabase
  final int itemId; // ID item yang dikomentari (misal: ID suku, kuliner)
  final String itemType; // Tipe item yang dikomentari (misal: 'suku', 'kuliner')
  final String namaAnonim;
  final String komentarText;
  final DateTime tanggalKomentar;
  final bool isApproved;

  Komentar({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.namaAnonim,
    required this.komentarText,
    required this.tanggalKomentar,
    required this.isApproved,
  });

  // Factory constructor untuk membuat objek Komentar dari JSON (dari Supabase)
  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      id: json['id'],
      itemId: json['item_id'], // Sesuaikan dengan nama kolom di Supabase
      itemType: json['item_type'], // Sesuaikan dengan nama kolom di Supabase
      namaAnonim: json['nama_anonim'] ?? 'Anonim', // Handle null, default 'Anonim'
      komentarText: json['komentar_text'],
      tanggalKomentar: DateTime.parse(json['tanggal_komentar']),
      isApproved: json['is_approved'] ?? false, // Default false jika null
    );
  }

  // Metode untuk mengkonversi objek Komentar ke JSON (untuk dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'item_type': itemType,
      'nama_anonim': namaAnonim,
      'komentar_text': komentarText,
      'tanggal_komentar': tanggalKomentar.toIso8601String(),
      'is_approved': isApproved,
    };
  }
}