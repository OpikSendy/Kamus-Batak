// lib/models/marga.dart

class Marga {
  final int? id;
  final int sukuId;
  final String nama;
  final String foto;
  final String deskripsi;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  Marga({
    this.id,
    required this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  Marga copyWith({
    int? id,
    int? sukuId,
    String? nama,
    String? foto,
    String? deskripsi,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return Marga(
      id: id ?? this.id,
      sukuId: sukuId ?? this.sukuId,
      nama: nama ?? this.nama,
      foto: foto ?? this.foto,
      deskripsi: deskripsi ?? this.deskripsi,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Marga.fromJson(Map<String, dynamic> json) {
    try {
      return Marga(
        id: json['id'] as int?,
        sukuId: json['suku_id'] as int,
        nama: json['nama']?.toString() ?? '',
        foto: json['foto']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
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
      print("Error parsing Marga from JSON: $e");
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
      'input_source': inputSource ?? 'user',
      'is_validated': isValidated ?? false,
    };

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
    return 'Marga(id: $id, sukuId: $sukuId, nama: $nama, isValidated: $isValidated)';
  }
}