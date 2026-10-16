class ProductoDAO {
  int? idProducto;
  String? nombre;
  String? imagen;
  String? unidad;
  int? stockMinimo;
  int? idCategoria;
  int? ultimaTiendaId;

  // Campos calculados y provenientes de JOINs
  String? categoriaNombre;
  String? colorHex;
  String? ultimaTiendaNombre;
  int? stockTotal;
  String? fechaCaducidadProxima;
  String? estatus;
  int? diasParaCaducar;

  ProductoDAO({
    this.idProducto,
    this.nombre,
    this.imagen,
    this.unidad = 'pza',
    this.stockMinimo = 2,
    this.idCategoria,
    this.ultimaTiendaId,
    this.categoriaNombre,
    this.colorHex,
    this.ultimaTiendaNombre,
    this.stockTotal,
    this.fechaCaducidadProxima,
    this.estatus,
    this.diasParaCaducar,
  });

  factory ProductoDAO.fromMap(Map<String, dynamic> map) {
    return ProductoDAO(
      idProducto: map['idProducto'],
      nombre: map['nombre'],
      imagen: map['imagen'],
      unidad: map['unidad'] ?? 'pza',
      stockMinimo: map['stockMinimo'] ?? 2,
      idCategoria: map['idCategoria'],
      ultimaTiendaId: map['ultima_tienda_id'],
      categoriaNombre: map['categoriaNombre'],
      colorHex: map['colorHex'],
      ultimaTiendaNombre: map['ultimaTiendaNombre'],
      stockTotal: map['stockTotal'] != null
          ? int.tryParse(map['stockTotal'].toString()) ?? 0
          : 0,
      fechaCaducidadProxima: map['fechaCaducidadProxima'],
      estatus: map['estatus'],
      diasParaCaducar: map['diasParaCaducar'] != null
          ? int.tryParse(map['diasParaCaducar'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'imagen': imagen,
      'unidad': unidad,
      'stockMinimo': stockMinimo,
      'idCategoria': idCategoria,
      'ultima_tienda_id': ultimaTiendaId,
    };
  }
}
