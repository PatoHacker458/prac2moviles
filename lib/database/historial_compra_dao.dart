class HistorialCompraDAO {
  int? idCompra;
  int? idProducto;
  int? idTienda;
  int? cantidad;
  double? precioUnitario;
  String? fechaCompra;

  // Campos de JOIN
  String? productoNombre;
  String? tiendaNombre;
  String? unidad;
  String? imagen;

  HistorialCompraDAO({
    this.idCompra,
    this.idProducto,
    this.idTienda,
    this.cantidad,
    this.precioUnitario,
    this.fechaCompra,
    this.productoNombre,
    this.tiendaNombre,
    this.unidad,
    this.imagen,
  });

  double get totalCompra =>
      (cantidad != null && precioUnitario != null)
          ? cantidad! * precioUnitario!
          : 0.0;

  factory HistorialCompraDAO.fromMap(Map<String, dynamic> map) {
    return HistorialCompraDAO(
      idCompra: map['idCompra'],
      idProducto: map['idProducto'],
      idTienda: map['idTienda'],
      cantidad: map['cantidad'] != null
          ? int.tryParse(map['cantidad'].toString()) ?? 0
          : 0,
      precioUnitario: map['precioUnitario'] != null
          ? double.tryParse(map['precioUnitario'].toString()) ?? 0.0
          : 0.0,
      fechaCompra: map['fechaCompra'],
      productoNombre: map['productoNombre'],
      tiendaNombre: map['tiendaNombre'],
      unidad: map['unidad'] ?? 'pza',
      imagen: map['imagen'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idCompra': idCompra,
      'idProducto': idProducto,
      'idTienda': idTienda,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'fechaCompra': fechaCompra,
    };
  }
}
