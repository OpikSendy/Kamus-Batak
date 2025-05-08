class Submarga {
  final int id;
  final int margaId;
  final String nama;
  final String foto;
  final String deskripsi;

  Submarga({
    required this.id,
    required this.margaId,
    required this.nama,
    required this.foto,
    required this.deskripsi,
  });

  factory Submarga.fromJson(Map<String, dynamic> json) {
    return Submarga(
      id: json['id'],
      margaId: json['marga_id'],
      nama: json['nama'],
      foto: json['foto'],
      deskripsi: json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marga_id': margaId,
      'nama': nama,
      'foto': foto,
      'deskripsi': deskripsi,
    };
  }
}