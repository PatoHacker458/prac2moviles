class TiendaDAO {
  int? idTienda;
  String? nombre;
  String? direccion;
  String? telefono;

  TiendaDAO({
    this.idTienda,
    this.nombre,
    this.direccion,
    this.telefono,
  });

  factory TiendaDAO.fromMap(Map<String, dynamic> map) {
    return TiendaDAO(
      idTienda: map['idTienda'],
      nombre: map['nombre'],
      direccion: map['direccion'],
      telefono: map['telefono'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTienda': idTienda,
      'nombre': nombre,
      'direccion': direccion,
      'telefono': telefono,
    };
  }
}
