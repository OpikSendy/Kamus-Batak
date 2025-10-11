// lib/models/kuliner_tradisional.dart

class KulinerTradisional {
  final int? id;
  final int sukuId;
  final String jenis;
  final String nama;
  final String foto;
  final String deskripsi;
  final String rating;
  final String waktu;
  final String resep;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  KulinerTradisional({
    this.id,
    required this.sukuId,
    required this.jenis,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.rating,
    required this.waktu,
    required this.resep,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  KulinerTradisional copyWith({
    int? id,
    int? sukuId,
    String? jenis,
    String? nama,
    String? newFoto,
    String? deskripsi,
    String? rating,
    String? waktu,
    String? resep,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return KulinerTradisional(
      id: id ?? this.id,
      sukuId: sukuId ?? this.sukuId,
      jenis: jenis ?? this.jenis,
      nama: nama ?? this.nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi ?? this.deskripsi,
      rating: rating ?? this.rating,
      waktu: waktu ?? this.waktu,
      resep: resep ?? this.resep,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory KulinerTradisional.fromJson(Map<String, dynamic> json) {
    try {
      return KulinerTradisional(
        id: json['id'] as int?,
        sukuId: json['suku_id'] as int? ?? 0,
        jenis: json['jenis']?.toString() ?? '',
        nama: json['nama']?.toString() ?? '',
        foto: json['foto']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        rating: json['rating']?.toString() ?? '',
        waktu: json['waktu']?.toString() ?? '',
        resep: json['resep']?.toString() ?? '',
        inputSource: json['input_source']?.toString(),
        isValidated: json['is_validated'] as bool?,
        validatedAt: json['validated_at'] != null
            ? DateTime.parse(json['validated_at'].toString())
            : null,
        validatedBy: json['validated_by']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : null,
      );
    } catch (e) {
      print("Error parsing KulinerTradisional from JSON: $e");
      print("JSON data: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'suku_id': sukuId,
      'jenis': jenis,
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
      'rating': rating,
      'waktu': waktu,
      'resep': resep,
      'input_source': inputSource ?? 'user',
      'is_validated': isValidated ?? false,
    };

    // Hanya tambahkan ID jika ada (untuk update)
    if (id != null) {
      data['id'] = id!;
    }

    if (validatedAt != null) {
      data['validated_at'] = validatedAt!.toIso8601String();
    }

    if (validatedBy != null) {
      data['validated_by'] = validatedBy!;
    }

    if (createdAt != null) {
      data['created_at'] = createdAt!.toIso8601String();
    }

    return data;
  }

  @override
  String toString() {
    return 'KulinerTradisional(id: $id, nama: $nama, jenis: $jenis, isValidated: $isValidated)';
  }
}