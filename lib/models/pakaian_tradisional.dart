// lib/models/pakaian_tradisional.dart

class PakaianTradisional {
  final int? id;
  final int? sukuId;
  final String nama;
  final String foto;
  final String deskripsi;
  final String sejarah;
  final String bahan;
  final String kelengkapan;
  final String feature1;
  final String feature2;
  final String feature3;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  PakaianTradisional({
    this.id,
    this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.sejarah,
    required this.bahan,
    required this.kelengkapan,
    required this.feature1,
    required this.feature2,
    required this.feature3,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  PakaianTradisional copyWith({
    int? id,
    int? sukuId,
    String? nama,
    String? newFoto,
    String? deskripsi,
    String? sejarah,
    String? bahan,
    String? kelengkapan,
    String? feature1,
    String? feature2,
    String? feature3,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return PakaianTradisional(
      id: id ?? this.id,
      sukuId: sukuId ?? this.sukuId,
      nama: nama ?? this.nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi ?? this.deskripsi,
      sejarah: sejarah ?? this.sejarah,
      bahan: bahan ?? this.bahan,
      kelengkapan: kelengkapan ?? this.kelengkapan,
      feature1: feature1 ?? this.feature1,
      feature2: feature2 ?? this.feature2,
      feature3: feature3 ?? this.feature3,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory PakaianTradisional.fromJson(Map<String, dynamic> json) {
    try {
      return PakaianTradisional(
        id: json['id'] as int?,
        sukuId: json['suku_id'] as int?,
        nama: json['nama']?.toString() ?? '',
        foto: json['foto']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        sejarah: json['sejarah']?.toString() ?? '',
        bahan: json['bahan']?.toString() ?? '',
        kelengkapan: json['kelengkapan']?.toString() ?? '',
        feature1: json['feature1']?.toString() ?? '',
        feature2: json['feature2']?.toString() ?? '',
        feature3: json['feature3']?.toString() ?? '',
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
      print("Error parsing PakaianTradisional from JSON: $e");
      print("JSON data: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
      'sejarah': sejarah,
      'bahan': bahan,
      'kelengkapan': kelengkapan,
      'feature1': feature1,
      'feature2': feature2,
      'feature3': feature3,
      'input_source': inputSource ?? 'user',
      'is_validated': isValidated ?? false,
    };

    // Hanya tambahkan ID jika ada (untuk update)
    if (id != null) {
      data['id'] = id!;
    }

    if (sukuId != null) {
      data['suku_id'] = sukuId!;
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
    return 'PakaianTradisional(id: $id, nama: $nama, isValidated: $isValidated)';
  }
}