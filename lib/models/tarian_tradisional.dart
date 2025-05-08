class TarianTradisional {
  final int id;
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

  TarianTradisional({
    required this.id,
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
  });

  factory TarianTradisional.fromJson(Map<String, dynamic> json) =>
      TarianTradisional(
        id: json['id'],
        sukuId: json['suku_id'],
        nama: json['nama'],
        foto: json['foto'],
        deskripsi: json['deskripsi'],
        sejarah: json['sejarah'],
        gerakan: json['gerakan'],
        kostum: json['kostum'],
        feature1: json['feature1'],
        feature2: json['feature2'],
        feature3: json['feature3'],
        video: json['video'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
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
  };
}
