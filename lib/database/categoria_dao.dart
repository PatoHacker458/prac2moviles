class CategoriaDAO {
  int? idCategoria;
  String? nombre;
  String? colorHex;

  CategoriaDAO({
    this.idCategoria,
    this.nombre,
    this.colorHex,
  });

  factory CategoriaDAO.fromMap(Map<String, dynamic> map) {
    return CategoriaDAO(
      idCategoria: map['idCategoria'],
      nombre: map['nombre'],
      colorHex: map['colorHex'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCategoria': idCategoria,
      'nombre': nombre,
      'colorHex': colorHex,
    };
  }
}
