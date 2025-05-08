class PakaianTradisional {
  final int id;
  final int sukuId;
  final String nama;
  final String foto;
  final String deskripsi;
  final String sejarah;
  final String bahan;
  final String kelengkapan;
  final String feature1;
  final String feature2;
  final String feature3;

  PakaianTradisional({
    required this.id,
    required this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.sejarah,
    required this.bahan,
    required this.kelengkapan,
    required this.feature1,
    required this.feature2,
    required this.feature3,
  });

  factory PakaianTradisional.fromJson(Map<String, dynamic> json) =>
      PakaianTradisional(
        id: json['id'],
        sukuId: json['suku_id'],
        nama: json['nama'],
        foto: json['foto'],
        deskripsi: json['deskripsi'],
        sejarah: json['sejarah'],
        bahan: json['bahan'],
        kelengkapan: json['kelengkapan'],
        feature1: json['feature1'],
        feature2: json['feature2'],
        feature3: json['feature3'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'suku_id': sukuId,
    'nama': nama,
    'foto': foto,
    'deskripsi': deskripsi,
    'sejarah': sejarah,
    'bahan': bahan,
    'kelengkapan': kelengkapan,
    'feature1': feature1,
    'feature2': feature2,
    'feature3': feature3,
  };
}
