class CarritoDAO {
  int? idCarrito;
  int? idProducto;
  int? cantidadAComprar;

  // Campos de JOIN
  String? productoNombre;
  String? unidad;
  String? imagen;
  String? categoriaNombre;
  String? colorHex;
  int? stockTotal;
  int? stockMinimo;
  String? ultimaTiendaNombre;
  int? ultimaTiendaId;

  CarritoDAO({
    this.idCarrito,
    this.idProducto,
    this.cantidadAComprar = 1,
    this.productoNombre,
    this.unidad,
    this.imagen,
    this.categoriaNombre,
    this.colorHex,
    this.stockTotal,
    this.stockMinimo,
    this.ultimaTiendaNombre,
    this.ultimaTiendaId,
  });

  factory CarritoDAO.fromMap(Map<String, dynamic> map) {
    return CarritoDAO(
      idCarrito: map['idCarrito'],
      idProducto: map['idProducto'],
      cantidadAComprar: map['cantidadAComprar'] != null
          ? int.tryParse(map['cantidadAComprar'].toString()) ?? 1
          : 1,
      productoNombre: map['productoNombre'],
      unidad: map['unidad'] ?? 'pza',
      imagen: map['imagen'],
      categoriaNombre: map['categoriaNombre'],
      colorHex: map['colorHex'],
      stockTotal: map['stockTotal'] != null
          ? int.tryParse(map['stockTotal'].toString()) ?? 0
          : 0,
      stockMinimo: map['stockMinimo'] != null
          ? int.tryParse(map['stockMinimo'].toString()) ?? 2
          : 2,
      ultimaTiendaNombre: map['ultimaTiendaNombre'],
      ultimaTiendaId: map['ultima_tienda_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCarrito': idCarrito,
      'idProducto': idProducto,
      'cantidadAComprar': cantidadAComprar,
    };
  }
}
