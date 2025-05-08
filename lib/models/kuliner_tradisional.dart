class KulinerTradisional {
  final int id;
  final int sukuId;
  final String jenis; // 'makanan' atau 'minuman'
  final String nama;
  final String foto;
  final String deskripsi;
  final String rating;
  final String waktu;
  final String resep;

  KulinerTradisional({
    required this.id,
    required this.sukuId,
    required this.jenis,
    required this.nama,
    required this.foto,
    required this.deskripsi,
    required this.rating,
    required this.waktu,
    required this.resep,
  });

  factory KulinerTradisional.fromJson(Map<String, dynamic> json) =>
      KulinerTradisional(
        id: json['id'],
        sukuId: json['suku_id'],
        jenis: json['jenis'],
        nama: json['nama'],
        foto: json['foto'],
        deskripsi: json['deskripsi'],
        rating: json['rating'],
        waktu: json['waktu'],
        resep: json['resep'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'suku_id': sukuId,
    'jenis': jenis,
    'nama': nama,
    'foto': foto,
    'deskripsi': deskripsi,
    'rating': rating,
    'waktu': waktu,
    'resep': resep,
  };
}
