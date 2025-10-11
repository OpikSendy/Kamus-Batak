// lib/models/submarga.dart

class Submarga {
  final int? id;
  final int margaId;
  final String nama;
  final String foto;
  final String deskripsi;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  Submarga({
    this.id,
    required this.margaId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  Submarga copyWith({
    int? id,
    int? margaId,
    String? nama,
    String? newFoto,
    String? deskripsi,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return Submarga(
      id: id ?? this.id,
      margaId: margaId ?? this.margaId,
      nama: nama ?? this.nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi ?? this.deskripsi,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Submarga.fromJson(Map<String, dynamic> json) {
    try {
      return Submarga(
        id: json['id'] as int?,
        margaId: json['marga_id'] as int,
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
      print("Error parsing Submarga from JSON: $e");
      print("JSON data: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'marga_id': margaId,
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
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
    return 'Submarga(id: $id, nama: $nama, margaId: $margaId, isValidated: $isValidated)';
  }
}