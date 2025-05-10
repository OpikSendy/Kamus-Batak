class RumahAdat {
  final int id;
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

  RumahAdat({
    required this.id,
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
  });

  RumahAdat copyWith({String? newFoto}) {
    return RumahAdat(
      id: id,
      sukuId: sukuId,
      nama: nama,
      foto: newFoto ?? foto,
      deskripsi: deskripsi,
      feature1: feature1,
      feature2: feature2,
      feature3: feature3,
      item1: item1,
      item2: item2,
      item3: item3,
      sejarah: sejarah,
      bangunan: bangunan,
      ornamen: ornamen,
      fungsi: fungsi,
      pelestarian: pelestarian,
    );
  }

  factory RumahAdat.fromJson(Map<String, dynamic> json) => RumahAdat(
    id: json['id'],
    sukuId: json['suku_id'],
    nama: json['nama'],
    foto: json['foto'],
    deskripsi: json['deskripsi'],
    feature1: json['feature1'],
    feature2: json['feature2'],
    feature3: json['feature3'],
    item1: json['item1'],
    item2: json['item2'],
    item3: json['item3'],
    sejarah: json['sejarah'],
    bangunan: json['bangunan'],
    ornamen: json['ornamen'],
    fungsi: json['fungsi'],
    pelestarian: json['pelestarian'],
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
    'item1': item1,
    'item2': item2,
    'item3': item3,
    'sejarah': sejarah,
    'bangunan': bangunan,
    'ornamen': ornamen,
    'fungsi': fungsi,
    'pelestarian': pelestarian,
  };
}
