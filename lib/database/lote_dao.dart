class LoteDAO {
  int? idLote;
  int? idProducto;
  int? cantidad;
  String? fechaCaducidad;
  int? notificarAlarma;
  String? horaAlarma;

  // Campos calculados y de JOIN
  String? productoNombre;
  String? unidad;
  String? imagen;
  String? categoriaNombre;
  String? colorHex;
  String? ultimaTiendaNombre;
  int? diasParaCaducar;

  LoteDAO({
    this.idLote,
    this.idProducto,
    this.cantidad,
    this.fechaCaducidad,
    this.notificarAlarma = 1,
    this.horaAlarma = '09:00',
    this.productoNombre,
    this.unidad,
    this.imagen,
    this.categoriaNombre,
    this.colorHex,
    this.ultimaTiendaNombre,
    this.diasParaCaducar,
  });

  factory LoteDAO.fromMap(Map<String, dynamic> map) {
    return LoteDAO(
      idLote: map['idLote'],
      idProducto: map['idProducto'],
      cantidad: map['cantidad'] != null
          ? int.tryParse(map['cantidad'].toString()) ?? 0
          : 0,
      fechaCaducidad: map['fechaCaducidad'],
      notificarAlarma: map['notificarAlarma'] ?? 1,
      horaAlarma: map['horaAlarma'] ?? '09:00',
      productoNombre: map['productoNombre'],
      unidad: map['unidad'] ?? 'pza',
      imagen: map['imagen'],
      categoriaNombre: map['categoriaNombre'],
      colorHex: map['colorHex'],
      ultimaTiendaNombre: map['ultimaTiendaNombre'],
      diasParaCaducar: map['diasParaCaducar'] != null
          ? int.tryParse(map['diasParaCaducar'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idLote': idLote,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'fechaCaducidad': fechaCaducidad,
      'notificarAlarma': notificarAlarma,
      'horaAlarma': horaAlarma,
    };
  }
}
