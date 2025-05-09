class SenjataTradisional {
  final int id;
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

  SenjataTradisional({
    required this.id,
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
  });

  factory SenjataTradisional.fromJson(Map<String, dynamic> json) =>
      SenjataTradisional(
        id: json['id'],
        sukuId: json['suku_id'],
        nama: json['nama'],
        foto: json['foto'],
        deskripsi: json['deskripsi'],
        feature1: json['feature1'],
        feature2: json['feature2'],
        feature3: json['feature3'],
        sejarah: json['sejarah'],
        material: json['material'],
        simbol: json['simbol'],
        penggunaan: json['penggunaan'],
        pertahanan: json['pertahanan'],
        perburuan: json['perburuan'],
        seremonial: json['seremonial'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
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
  };
}
