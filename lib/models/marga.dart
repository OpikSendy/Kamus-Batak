class Marga {
  final int id;
  final int sukuId;
  final String nama;
  final String foto;
  final String deskripsi;

  Marga({
    required this.id,
    required this.sukuId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
  });

  factory Marga.fromJson(Map<String, dynamic> json) {
    return Marga(
      id: json['id'],
      sukuId: json['suku_id'],
      nama: json['nama'],
      foto: json['foto'],
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'suku_id': sukuId,
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
    };
  }
}