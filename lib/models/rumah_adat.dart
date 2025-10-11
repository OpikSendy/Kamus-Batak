// lib/models/rumah_adat.dart

class RumahAdat {
  final int? id;
  final int sukuId;
  final String nama;
  final String foto;
  final String deskripsi;
  final String feature1;
  final String feature2;
  final String feature3;
  final String item1;
  final String item2;
  final String item3;
  final String sejarah;
  final String bangunan;
  final String ornamen;
  final String fungsi;
  final String pelestarian;

  final String? inputSource;
  final bool? isValidated;
  final DateTime? validatedAt;
  final String? validatedBy;
  final DateTime? createdAt;

  RumahAdat({
    this.id,
    required this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.feature1,
    required this.feature2,
    required this.feature3,
    required this.item1,
    required this.item2,
    required this.item3,
    required this.sejarah,
    required this.bangunan,
    required this.ornamen,
    required this.fungsi,
    required this.pelestarian,
    this.inputSource,
    this.isValidated,
    this.validatedAt,
    this.validatedBy,
    this.createdAt,
  });

  RumahAdat copyWith({
    int? id,
    int? sukuId,
    String? nama,
    String? newFoto,
    String? deskripsi,
    String? feature1,
    String? feature2,
    String? feature3,
    String? item1,
    String? item2,
    String? item3,
    String? sejarah,
    String? bangunan,
    String? ornamen,
    String? fungsi,
    String? pelestarian,
    String? inputSource,
    bool? isValidated,
    DateTime? validatedAt,
    String? validatedBy,
    DateTime? createdAt,
  }) {
    return RumahAdat(
      id: id ?? this.id,
      sukuId: sukuId ?? this.sukuId,
      nama: nama ?? this.nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi ?? this.deskripsi,
      feature1: feature1 ?? this.feature1,
      feature2: feature2 ?? this.feature2,
      feature3: feature3 ?? this.feature3,
      item1: item1 ?? this.item1,
      item2: item2 ?? this.item2,
      item3: item3 ?? this.item3,
      sejarah: sejarah ?? this.sejarah,
      bangunan: bangunan ?? this.bangunan,
      ornamen: ornamen ?? this.ornamen,
      fungsi: fungsi ?? this.fungsi,
      pelestarian: pelestarian ?? this.pelestarian,
      inputSource: inputSource ?? this.inputSource,
      isValidated: isValidated ?? this.isValidated,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedBy: validatedBy ?? this.validatedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory RumahAdat.fromJson(Map<String, dynamic> json) {
    try {
      return RumahAdat(
        id: json['id'] as int?,
        sukuId: json['suku_id'] as int? ?? 0,
        nama: json['nama']?.toString() ?? '',
        foto: json['foto']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        feature1: json['feature1']?.toString() ?? '',
        feature2: json['feature2']?.toString() ?? '',
        feature3: json['feature3']?.toString() ?? '',
        item1: json['item1']?.toString() ?? '',
        item2: json['item2']?.toString() ?? '',
        item3: json['item3']?.toString() ?? '',
        sejarah: json['sejarah']?.toString() ?? '',
        bangunan: json['bangunan']?.toString() ?? '',
        ornamen: json['ornamen']?.toString() ?? '',
        fungsi: json['fungsi']?.toString() ?? '',
        pelestarian: json['pelestarian']?.toString() ?? '',
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
      print("Error parsing RumahAdat from JSON: $e");
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
      'item1': item1,
      'item2': item2,
      'item3': item3,
      'sejarah': sejarah,
      'bangunan': bangunan,
      'ornamen': ornamen,
      'fungsi': fungsi,
      'pelestarian': pelestarian,
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
    return 'RumahAdat(id: $id, nama: $nama, isValidated: $isValidated)';
  }
}