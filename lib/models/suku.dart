class Suku {
  final int id;
  final String nama;
  final String foto;

  Suku({
    required this.id,
    required this.nama,
    required this.foto,
  });

  Suku copyWith({String? newFoto}) {
    return Suku(
      id: id,
      nama: nama,
      foto: newFoto ?? foto,
    );
  }

  factory Suku.fromJson(Map<String, dynamic> json) {
    return Suku(
      id: json['id'],
      nama: json['nama'],
      foto: json['foto'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'foto': foto,
    };
  }
}