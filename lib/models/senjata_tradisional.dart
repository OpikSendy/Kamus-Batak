class SenjataTradisional {
  final int? id;
  final int sukuId;
  final String nama;
  final String foto;
  final String deskripsi;
  final String feature1;
  final String feature2;
  final String feature3;
  final String sejarah;
  final String material;
  final String simbol;
  final String penggunaan;
  final String pertahanan;
  final String perburuan;
  final String seremonial;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  SenjataTradisional({
    this.id,
    required this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.feature1,
    required this.feature2,
    required this.feature3,
    required this.sejarah,
    required this.material,
    required this.simbol,
    required this.penggunaan,
    required this.pertahanan,
    required this.perburuan,
    required this.seremonial,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  SenjataTradisional copyWith({
    int? id,
    int? sukuId,
    String? nama,
    String? newFoto,
    String? deskripsi,
    String? feature1,
    String? feature2,
    String? feature3,
    String? sejarah,
    String? material,
    String? simbol,
    String? penggunaan,
    String? pertahanan,
    String? perburuan,
    String? seremonial,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return SenjataTradisional(
      id: id ?? this.id,
      sukuId: sukuId ?? this.sukuId,
      nama: nama ?? this.nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi ?? this.deskripsi,
      feature1: feature1 ?? this.feature1,
      feature2: feature2 ?? this.feature2,
      feature3: feature3 ?? this.feature3,
      sejarah: sejarah ?? this.sejarah,
      material: material ?? this.material,
      simbol: simbol ?? this.simbol,
      penggunaan: penggunaan ?? this.penggunaan,
      pertahanan: pertahanan ?? this.pertahanan,
      perburuan: perburuan ?? this.perburuan,
      seremonial: seremonial ?? this.seremonial,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SenjataTradisional.fromJson(Map<String, dynamic> json) {
    try {
      return SenjataTradisional(
        id: json['id'] as int?,
        sukuId: json['suku_id'] as int? ?? 0,
        nama: json['nama']?.toString() ?? '',
        foto: json['foto']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        feature1: json['feature1']?.toString() ?? '',
        feature2: json['feature2']?.toString() ?? '',
        feature3: json['feature3']?.toString() ?? '',
        sejarah: json['sejarah']?.toString() ?? '',
        material: json['material']?.toString() ?? '',
        simbol: json['simbol']?.toString() ?? '',
        penggunaan: json['penggunaan']?.toString() ?? '',
        pertahanan: json['pertahanan']?.toString() ?? '',
        perburuan: json['perburuan']?.toString() ?? '',
        seremonial: json['seremonial']?.toString() ?? '',
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
      print("Error parsing SenjataTradisional from JSON: $e");
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
      'feature1': feature1,
      'feature2': feature2,
      'feature3': feature3,
      'sejarah': sejarah,
      'material': material,
      'simbol': simbol,
      'penggunaan': penggunaan,
      'pertahanan': pertahanan,
      'perburuan': perburuan,
      'seremonial': seremonial,
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
    return 'SenjataTradisional(id: $id, nama: $nama, isValidated: $isValidated)';
  }
}