// lib/models/tarian_tradisional.dart

class TarianTradisional {
  final int? id;
  final int sukuId;
  final String nama;
  final String foto;
  final String deskripsi;
  final String sejarah;
  final String gerakan;
  final String kostum;
  final String feature1;
  final String feature2;
  final String feature3;
  final String video;
  final String kategori;
  final String durasi;
  final String event;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  TarianTradisional({
    this.id,
    required this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.sejarah,
    required this.gerakan,
    required this.kostum,
    required this.feature1,
    required this.feature2,
    required this.feature3,
    required this.video,
    required this.kategori,
    required this.durasi,
    required this.event,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  TarianTradisional copyWith({
    int? id,
    int? sukuId,
    String? nama,
    String? newFoto,
    String? deskripsi,
    String? sejarah,
    String? gerakan,
    String? kostum,
    String? feature1,
    String? feature2,
    String? feature3,
    String? video,
    String? kategori,
    String? durasi,
    String? event,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return TarianTradisional(
      id: id ?? this.id,
      sukuId: sukuId ?? this.sukuId,
      nama: nama ?? this.nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi ?? this.deskripsi,
      sejarah: sejarah ?? this.sejarah,
      gerakan: gerakan ?? this.gerakan,
      kostum: kostum ?? this.kostum,
      feature1: feature1 ?? this.feature1,
      feature2: feature2 ?? this.feature2,
      feature3: feature3 ?? this.feature3,
      video: video ?? this.video,
      kategori: kategori ?? this.kategori,
      durasi: durasi ?? this.durasi,
      event: event ?? this.event,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory TarianTradisional.fromJson(Map<String, dynamic> json) {
    try {
      return TarianTradisional(
        id: json['id'] as int?,
        sukuId: json['suku_id'] as int? ?? 0,
        nama: json['nama']?.toString() ?? '',
        foto: json['foto']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        sejarah: json['sejarah']?.toString() ?? '',
        gerakan: json['gerakan']?.toString() ?? '',
        kostum: json['kostum']?.toString() ?? '',
        feature1: json['feature1']?.toString() ?? '',
        feature2: json['feature2']?.toString() ?? '',
        feature3: json['feature3']?.toString() ?? '',
        video: json['video']?.toString() ?? '',
        kategori: json['kategori']?.toString() ?? '',
        durasi: json['durasi']?.toString() ?? '',
        event: json['event']?.toString() ?? '',
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
      print("Error parsing TarianTradisional from JSON: $e");
      print("JSON data: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'suku_id': sukuId,
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
      'sejarah': sejarah,
      'gerakan': gerakan,
      'kostum': kostum,
      'feature1': feature1,
      'feature2': feature2,
      'feature3': feature3,
      'video': video,
      'kategori': kategori,
      'durasi': durasi,
      'event': event,
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
    return 'TarianTradisional(id: $id, nama: $nama, isValidated: $isValidated)';
  }
}