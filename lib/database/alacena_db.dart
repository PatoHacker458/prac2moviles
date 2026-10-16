import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:prac2/database/categoria_dao.dart';
import 'package:prac2/database/tienda_dao.dart';
import 'package:prac2/database/producto_dao.dart';
import 'package:prac2/database/lote_dao.dart';
import 'package:prac2/database/historial_compra_dao.dart';
import 'package:prac2/database/carrito_dao.dart';

class AlacenaDB {
  static final nameDB = "ALACENADB";
  static final versionDB = 1;
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    return _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, nameDB);
    return openDatabase(
      pathDB,
      version: versionDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: createTables,
    );
  }

  FutureOr<void> createTables(Database db, int version) async {
    // 1. tblCategorias
    await db.execute('''
      CREATE TABLE tblCategorias(
        idCategoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(50) NOT NULL UNIQUE,
        colorHex VARCHAR(15) NOT NULL
      )
    ''');

    // 2. tblTiendas
    await db.execute('''
      CREATE TABLE tblTiendas(
        idTienda INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(60) NOT NULL UNIQUE,
        direccion VARCHAR(100),
        telefono VARCHAR(20)
      )
    ''');

    // 3. tblProductos
    await db.execute('''
      CREATE TABLE tblProductos(
        idProducto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre VARCHAR(60) NOT NULL,
        imagen TEXT,
        unidad VARCHAR(20) NOT NULL DEFAULT 'pza',
        stockMinimo INTEGER NOT NULL DEFAULT 2 CHECK(stockMinimo >= 0),
        idCategoria INTEGER NOT NULL,
        ultima_tienda_id INTEGER,
        FOREIGN KEY (idCategoria) REFERENCES tblCategorias(idCategoria) ON DELETE RESTRICT,
        FOREIGN KEY (ultima_tienda_id) REFERENCES tblTiendas(idTienda) ON DELETE SET NULL
      )
    ''');

    // 4. tblLotes
    await db.execute('''
      CREATE TABLE tblLotes(
        idLote INTEGER PRIMARY KEY AUTOINCREMENT,
        idProducto INTEGER NOT NULL,
        cantidad INTEGER NOT NULL CHECK(cantidad >= 0),
        fechaCaducidad CHAR(10) NOT NULL,
        notificarAlarma INTEGER NOT NULL DEFAULT 1 CHECK(notificarAlarma IN (0, 1)),
        horaAlarma CHAR(5) DEFAULT '09:00',
        FOREIGN KEY (idProducto) REFERENCES tblProductos(idProducto) ON DELETE CASCADE
      )
    ''');

    // 5. tblHistorialCompras
    await db.execute('''
      CREATE TABLE tblHistorialCompras(
        idCompra INTEGER PRIMARY KEY AUTOINCREMENT,
        idProducto INTEGER NOT NULL,
        idTienda INTEGER NOT NULL,
        cantidad INTEGER NOT NULL CHECK(cantidad > 0),
        precioUnitario REAL NOT NULL CHECK(precioUnitario >= 0),
        fechaCompra CHAR(10) NOT NULL,
        FOREIGN KEY (idProducto) REFERENCES tblProductos(idProducto) ON DELETE CASCADE,
        FOREIGN KEY (idTienda) REFERENCES tblTiendas(idTienda) ON DELETE RESTRICT
      )
    ''');

    // 6. tblCarrito
    await db.execute('''
      CREATE TABLE tblCarrito(
        idCarrito INTEGER PRIMARY KEY AUTOINCREMENT,
        idProducto INTEGER NOT NULL UNIQUE,
        cantidadAComprar INTEGER NOT NULL DEFAULT 1 CHECK(cantidadAComprar > 0),
        FOREIGN KEY (idProducto) REFERENCES tblProductos(idProducto) ON DELETE CASCADE
      )
    ''');

    // Inserción de Datos Semilla con fechas relativas al día actual
    await _insertSeedData(db);
  }

  Future<void> _insertSeedData(Database db) async {
    final now = DateTime.now();
    String fmtDate(DateTime d) => d.toIso8601String().substring(0, 10);

    final fHoy = fmtDate(now);
    final fHace5Dias = fmtDate(now.subtract(const Duration(days: 5)));
    final fHace2Dias = fmtDate(now.subtract(const Duration(days: 2)));
    final fEn3Dias = fmtDate(now.add(const Duration(days: 3)));
    final fEn15Dias = fmtDate(now.add(const Duration(days: 15)));
    final fEn30Dias = fmtDate(now.add(const Duration(days: 30)));
    final fEn60Dias = fmtDate(now.add(const Duration(days: 60)));

    // Categorías
    await db.insert('tblCategorias', {'nombre': 'Lácteos', 'colorHex': '#3498DB'});
    await db.insert('tblCategorias', {'nombre': 'Enlatados', 'colorHex': '#E67E22'});
    await db.insert('tblCategorias', {'nombre': 'Carnes y Embutidos', 'colorHex': '#E74C3C'});
    await db.insert('tblCategorias', {'nombre': 'Limpieza', 'colorHex': '#2ECC71'});

    // Tiendas
    await db.insert('tblTiendas', {
      'nombre': 'Walmart Celaya',
      'direccion': 'Av. Irrigación #100',
      'telefono': '461-123-4567'
    });
    await db.insert('tblTiendas', {
      'nombre': 'La Comer',
      'direccion': 'Blvd. Adolfo López Mateos #800',
      'telefono': '461-765-4321'
    });
    await db.insert('tblTiendas', {
      'nombre': 'Mercado Hidalgo',
      'direccion': 'Zona Centro, Celaya',
      'telefono': '461-987-6543'
    });

    // 6 Productos con estados diferenciados
    // 1. Caducado (hace 2 días)
    await db.insert('tblProductos', {
      'idProducto': 1,
      'nombre': 'Leche Entera 1L',
      'imagen': '',
      'unidad': 'lt',
      'stockMinimo': 2,
      'idCategoria': 1,
      'ultima_tienda_id': 1
    });
    await db.insert('tblLotes', {
      'idProducto': 1,
      'cantidad': 2,
      'fechaCaducidad': fHace2Dias,
      'notificarAlarma': 1,
      'horaAlarma': '08:30'
    });

    // 2. Por Caducar HOY (con alarma activa para la pantalla de alarmas y calendario)
    await db.insert('tblProductos', {
      'idProducto': 2,
      'nombre': 'Yogur Griego 900g',
      'imagen': '',
      'unidad': 'pza',
      'stockMinimo': 2,
      'idCategoria': 1,
      'ultima_tienda_id': 2
    });
    await db.insert('tblLotes', {
      'idProducto': 2,
      'cantidad': 2,
      'fechaCaducidad': fHoy,
      'notificarAlarma': 1,
      'horaAlarma': '09:00'
    });

    // 3. Por Caducar en 3 días con múltiples lotes para probar FEFO
    await db.insert('tblProductos', {
      'idProducto': 3,
      'nombre': 'Atún en Agua 140g',
      'imagen': '',
      'unidad': 'pza',
      'stockMinimo': 3,
      'idCategoria': 2,
      'ultima_tienda_id': 1
    });
    // Lote próximo a vencer (FEFO 1)
    await db.insert('tblLotes', {
      'idProducto': 3,
      'cantidad': 2,
      'fechaCaducidad': fEn3Dias,
      'notificarAlarma': 1,
      'horaAlarma': '10:00'
    });
    // Lote posterior (FEFO 2)
    await db.insert('tblLotes', {
      'idProducto': 3,
      'cantidad': 4,
      'fechaCaducidad': fEn15Dias,
      'notificarAlarma': 1,
      'horaAlarma': '10:00'
    });

    // 4. Agotado (stock total = 0)
    await db.insert('tblProductos', {
      'idProducto': 4,
      'nombre': 'Jamón de Pavo 500g',
      'imagen': '',
      'unidad': 'paq',
      'stockMinimo': 2,
      'idCategoria': 3,
      'ultima_tienda_id': 2
    });
    await db.insert('tblLotes', {
      'idProducto': 4,
      'cantidad': 0,
      'fechaCaducidad': fHace5Dias,
      'notificarAlarma': 0,
      'horaAlarma': '09:00'
    });

    // 5. Por Agotarse (stock = 1 <= stockMinimo = 3)
    await db.insert('tblProductos', {
      'idProducto': 5,
      'nombre': 'Detergente Líquido 3L',
      'imagen': '',
      'unidad': 'pza',
      'stockMinimo': 3,
      'idCategoria': 4,
      'ultima_tienda_id': 1
    });
    await db.insert('tblLotes', {
      'idProducto': 5,
      'cantidad': 1,
      'fechaCaducidad': fEn30Dias,
      'notificarAlarma': 1,
      'horaAlarma': '09:00'
    });

    // 6. Óptimo / Disponible (stock = 8, caducidad lejana)
    await db.insert('tblProductos', {
      'idProducto': 6,
      'nombre': 'Frijoles Negros 1kg',
      'imagen': '',
      'unidad': 'kg',
      'stockMinimo': 2,
      'idCategoria': 2,
      'ultima_tienda_id': 3
    });
    await db.insert('tblLotes', {
      'idProducto': 6,
      'cantidad': 8,
      'fechaCaducidad': fEn60Dias,
      'notificarAlarma': 0,
      'horaAlarma': '09:00'
    });

    // Historial de compras (trazabilidad de tiendas)
    await db.insert('tblHistorialCompras', {
      'idProducto': 1,
      'idTienda': 1,
      'cantidad': 3,
      'precioUnitario': 28.50,
      'fechaCompra': fHace5Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 1,
      'idTienda': 2,
      'cantidad': 2,
      'precioUnitario': 29.90,
      'fechaCompra': fHace2Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 2,
      'idTienda': 2,
      'cantidad': 2,
      'precioUnitario': 65.00,
      'fechaCompra': fHace5Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 3,
      'idTienda': 1,
      'cantidad': 4,
      'precioUnitario': 18.00,
      'fechaCompra': fHace5Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 3,
      'idTienda': 3,
      'cantidad': 2,
      'precioUnitario': 16.50,
      'fechaCompra': fHace2Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 4,
      'idTienda': 2,
      'cantidad': 1,
      'precioUnitario': 54.00,
      'fechaCompra': fHace5Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 5,
      'idTienda': 1,
      'cantidad': 2,
      'precioUnitario': 120.00,
      'fechaCompra': fHace5Dias
    });
    await db.insert('tblHistorialCompras', {
      'idProducto': 6,
      'idTienda': 3,
      'cantidad': 8,
      'precioUnitario': 34.00,
      'fechaCompra': fHace2Dias
    });

    // 1 item en carrito inicialmente para mostrar el badge
    await db.insert('tblCarrito', {
      'idProducto': 4,
      'cantidadAComprar': 2
    });
  }

  // ==========================================
  // MÉTODOS CRUD CATEGORIAS (MAYÚSCULAS)
  // ==========================================
  Future<int> INSERT_CATEGORIA(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.insert('tblCategorias', data);
  }

  Future<int> UPDATE_CATEGORIA(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.update(
      'tblCategorias',
      data,
      where: 'idCategoria = ?',
      whereArgs: [data['idCategoria']],
    );
  }

  Future<int> DELETE_CATEGORIA(int idCategoria) async {
    var conexion = await database;
    try {
      return await conexion!.delete(
        'tblCategorias',
        where: 'idCategoria = ?',
        whereArgs: [idCategoria],
      );
    } catch (e) {
      // Captura restricción de llave foránea ON DELETE RESTRICT
      return -1;
    }
  }

  Future<List<CategoriaDAO>> SELECT_CATEGORIAS() async {
    var conexion = await database;
    final res = await conexion!.query('tblCategorias', orderBy: 'nombre ASC');
    return res.map((cat) => CategoriaDAO.fromMap(cat)).toList();
  }

  // ==========================================
  // MÉTODOS CRUD TIENDAS (MAYÚSCULAS)
  // ==========================================
  Future<int> INSERT_TIENDA(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.insert('tblTiendas', data);
  }

  Future<int> UPDATE_TIENDA(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.update(
      'tblTiendas',
      data,
      where: 'idTienda = ?',
      whereArgs: [data['idTienda']],
    );
  }

  Future<int> DELETE_TIENDA(int idTienda) async {
    var conexion = await database;
    try {
      return await conexion!.delete(
        'tblTiendas',
        where: 'idTienda = ?',
        whereArgs: [idTienda],
      );
    } catch (e) {
      // Captura restricción de llave foránea ON DELETE RESTRICT
      return -1;
    }
  }

  Future<List<TiendaDAO>> SELECT_TIENDAS() async {
    var conexion = await database;
    final res = await conexion!.query('tblTiendas', orderBy: 'nombre ASC');
    return res.map((t) => TiendaDAO.fromMap(t)).toList();
  }

  // ==========================================
  // MÉTODOS CRUD PRODUCTOS (MAYÚSCULAS)
  // ==========================================
  Future<int> INSERT_PRODUCTO(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.insert('tblProductos', data);
  }

  Future<int> UPDATE_PRODUCTO(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.update(
      'tblProductos',
      data,
      where: 'idProducto = ?',
      whereArgs: [data['idProducto']],
    );
  }

  Future<int> DELETE_PRODUCTO(int idProducto) async {
    var conexion = await database;
    return await conexion!.delete(
      'tblProductos',
      where: 'idProducto = ?',
      whereArgs: [idProducto],
    );
  }

  Future<List<ProductoDAO>> SELECT_PRODUCTOS() async {
    var conexion = await database;
    final res = await conexion!.query('tblProductos', orderBy: 'nombre ASC');
    return res.map((p) => ProductoDAO.fromMap(p)).toList();
  }

  // CONSULTA COMPLETA CON ESTADO SEMÁNTICO Y STOCK
  Future<List<ProductoDAO>> SELECT_PRODUCTOS_COMPLETO({String? filtroEstatus}) async {
    var conexion = await database;
    final String query = '''
      SELECT 
        p.idProducto,
        p.nombre,
        p.imagen,
        p.unidad,
        p.stockMinimo,
        p.idCategoria,
        p.ultima_tienda_id,
        c.nombre AS categoriaNombre,
        c.colorHex,
        t.nombre AS ultimaTiendaNombre,
        COALESCE(SUM(CASE WHEN l.cantidad > 0 THEN l.cantidad ELSE 0 END), 0) AS stockTotal,
        MIN(CASE WHEN l.cantidad > 0 THEN l.fechaCaducidad ELSE NULL END) AS fechaCaducidadProxima
      FROM tblProductos p
      LEFT JOIN tblCategorias c ON p.idCategoria = c.idCategoria
      LEFT JOIN tblTiendas t ON p.ultima_tienda_id = t.idTienda
      LEFT JOIN tblLotes l ON p.idProducto = l.idProducto
      GROUP BY p.idProducto
      ORDER BY p.nombre ASC
    ''';

    final List<Map<String, dynamic>> rawList = await conexion!.rawQuery(query);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List<ProductoDAO> resultado = [];

    for (var row in rawList) {
      final prod = ProductoDAO.fromMap(row);
      final int stockTotal = prod.stockTotal ?? 0;
      final int stockMinimo = prod.stockMinimo ?? 2;
      final String? proxCaducidad = prod.fechaCaducidadProxima;

      DateTime? fechaProx;
      int? diasRestantes;
      if (proxCaducidad != null && proxCaducidad.isNotEmpty) {
        try {
          fechaProx = DateTime.parse(proxCaducidad);
          diasRestantes = fechaProx.difference(today).inDays;
        } catch (_) {}
      }
      prod.diasParaCaducar = diasRestantes;

      // Determinación estricta del estatus con la prioridad de negocio:
      // 1. SIN EXISTENCIA / AGOTADO (stockTotal == 0)
      // 2. CADUCADO (al menos un lote activo vencido)
      // 3. POR CADUCAR (vence hoy o dentro de 5 días)
      // 4. POR AGOTARSE (stockTotal > 0 y stockTotal <= stockMinimo)
      // 5. DISPONIBLE / ÓPTIMO
      if (stockTotal == 0) {
        prod.estatus = 'SIN EXISTENCIA';
      } else if (diasRestantes != null && diasRestantes < 0) {
        prod.estatus = 'CADUCADO';
      } else if (diasRestantes != null && diasRestantes <= 5) {
        prod.estatus = 'POR CADUCAR';
      } else if (stockTotal <= stockMinimo) {
        prod.estatus = 'POR AGOTARSE';
      } else {
        prod.estatus = 'DISPONIBLE';
      }

      // Aplicar filtro si se solicita
      if (filtroEstatus == 'ALERTAS') {
        if (prod.estatus == 'POR CADUCAR' || prod.estatus == 'POR AGOTARSE') {
          resultado.add(prod);
        }
      } else if (filtroEstatus == 'CRITICOS') {
        if (prod.estatus == 'CADUCADO' || prod.estatus == 'SIN EXISTENCIA') {
          resultado.add(prod);
        }
      } else {
        resultado.add(prod);
      }
    }

    return resultado;
  }

  // ==========================================
  // REGLA FEFO (First Expired, First Out)
  // ==========================================
  Future<Map<String, dynamic>> CONSUMIR_PRODUCTO_FEFO(
      int idProducto, int unidadesAConsumir) async {
    var conexion = await database;
    if (unidadesAConsumir <= 0) {
      return {'success': false, 'mensaje': 'La cantidad debe ser mayor a 0'};
    }

    return await conexion!.transaction((txn) async {
      // Consultar lotes activos ordenados por fecha de caducidad ascendente
      final List<Map<String, dynamic>> lotesActivos = await txn.query(
        'tblLotes',
        where: 'idProducto = ? AND cantidad > 0',
        whereArgs: [idProducto],
        orderBy: 'fechaCaducidad ASC',
      );

      if (lotesActivos.isEmpty) {
        return {
          'success': false,
          'mensaje': 'No hay lotes con existencia para este producto.'
        };
      }

      int restantesPorConsumir = unidadesAConsumir;
      int consumidasTotal = 0;
      List<String> detalleConsumo = [];

      for (var loteMap in lotesActivos) {
        int idLote = loteMap['idLote'];
        int cantLote = loteMap['cantidad'];
        String fecha = loteMap['fechaCaducidad'];

        if (cantLote <= restantesPorConsumir) {
          // Descuenta todo el lote y continúa al siguiente
          await txn.update(
            'tblLotes',
            {'cantidad': 0},
            where: 'idLote = ?',
            whereArgs: [idLote],
          );
          restantesPorConsumir -= cantLote;
          consumidasTotal += cantLote;
          detalleConsumo.add('$cantLote ud(s) del lote ($fecha)');
        } else {
          // Descuenta parcialmente este lote
          int nuevaCant = cantLote - restantesPorConsumir;
          await txn.update(
            'tblLotes',
            {'cantidad': nuevaCant},
            where: 'idLote = ?',
            whereArgs: [idLote],
          );
          consumidasTotal += restantesPorConsumir;
          detalleConsumo.add('$restantesPorConsumir ud(s) del lote ($fecha)');
          restantesPorConsumir = 0;
        }

        if (restantesPorConsumir == 0) break;
      }

      String mensaje =
          'Se consumieron $consumidasTotal ud(s) bajo criterio FEFO: ${detalleConsumo.join(', ')}';
      if (restantesPorConsumir > 0) {
        mensaje += ' (Quedaron pendientes $restantesPorConsumir ud(s) por falta de stock).';
      }

      return {
        'success': true,
        'mensaje': mensaje,
        'unidadesConsumidas': consumidasTotal,
      };
    });
  }

  // ==========================================
  // TRAZABILIDAD DE TIENDAS Y COMPRA INTELIGENTE
  // ==========================================
  Future<int> INSERT_COMPRA_Y_LOTE({
    required int idProducto,
    required int idTienda,
    required int cantidad,
    required double precioUnitario,
    required String fechaCompra,
    required String fechaCaducidad,
    int notificarAlarma = 1,
    String horaAlarma = '09:00',
  }) async {
    var conexion = await database;
    return await conexion!.transaction((txn) async {
      // 1. Insertar en tblHistorialCompras
      int idCompra = await txn.insert('tblHistorialCompras', {
        'idProducto': idProducto,
        'idTienda': idTienda,
        'cantidad': cantidad,
        'precioUnitario': precioUnitario,
        'fechaCompra': fechaCompra,
      });

      // 2. Actualizar automáticamente ultima_tienda_id en tblProductos
      await txn.update(
        'tblProductos',
        {'ultima_tienda_id': idTienda},
        where: 'idProducto = ?',
        whereArgs: [idProducto],
      );

      // 3. Insertar el nuevo lote en tblLotes
      await txn.insert('tblLotes', {
        'idProducto': idProducto,
        'cantidad': cantidad,
        'fechaCaducidad': fechaCaducidad,
        'notificarAlarma': notificarAlarma,
        'horaAlarma': horaAlarma,
      });

      return idCompra;
    });
  }

  Future<List<HistorialCompraDAO>> SELECT_TIENDAS_POR_PRODUCTO(int idProducto) async {
    var conexion = await database;
    final String query = '''
      SELECT 
        h.idCompra,
        h.idProducto,
        h.idTienda,
        h.cantidad,
        h.precioUnitario,
        h.fechaCompra,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        t.nombre AS tiendaNombre
      FROM tblHistorialCompras h
      INNER JOIN tblProductos p ON h.idProducto = p.idProducto
      INNER JOIN tblTiendas t ON h.idTienda = t.idTienda
      WHERE h.idProducto = ?
      ORDER BY h.fechaCompra DESC
    ''';

    final res = await conexion!.rawQuery(query, [idProducto]);
    return res.map((row) => HistorialCompraDAO.fromMap(row)).toList();
  }

  // ==========================================
  // CRUD LOTES (MAYÚSCULAS)
  // ==========================================
  Future<int> INSERT_LOTE(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.insert('tblLotes', data);
  }

  Future<int> UPDATE_LOTE(Map<String, dynamic> data) async {
    var conexion = await database;
    return await conexion!.update(
      'tblLotes',
      data,
      where: 'idLote = ?',
      whereArgs: [data['idLote']],
    );
  }

  Future<int> DELETE_LOTE(int idLote) async {
    var conexion = await database;
    return await conexion!.delete(
      'tblLotes',
      where: 'idLote = ?',
      whereArgs: [idLote],
    );
  }

  Future<List<LoteDAO>> SELECT_LOTES_POR_PRODUCTO(int idProducto) async {
    var conexion = await database;
    final String query = '''
      SELECT 
        l.idLote,
        l.idProducto,
        l.cantidad,
        l.fechaCaducidad,
        l.notificarAlarma,
        l.horaAlarma,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        c.nombre AS categoriaNombre,
        c.colorHex,
        t.nombre AS ultimaTiendaNombre
      FROM tblLotes l
      INNER JOIN tblProductos p ON l.idProducto = p.idProducto
      LEFT JOIN tblCategorias c ON p.idCategoria = c.idCategoria
      LEFT JOIN tblTiendas t ON p.ultima_tienda_id = t.idTienda
      WHERE l.idProducto = ?
      ORDER BY l.fechaCaducidad ASC
    ''';

    final res = await conexion!.rawQuery(query, [idProducto]);
    return res.map((row) => LoteDAO.fromMap(row)).toList();
  }

  Future<List<LoteDAO>> SELECT_LOTES_CALENDARIO() async {
    var conexion = await database;
    final String query = '''
      SELECT 
        l.idLote,
        l.idProducto,
        l.cantidad,
        l.fechaCaducidad,
        l.notificarAlarma,
        l.horaAlarma,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        c.nombre AS categoriaNombre,
        c.colorHex,
        t.nombre AS ultimaTiendaNombre
      FROM tblLotes l
      INNER JOIN tblProductos p ON l.idProducto = p.idProducto
      LEFT JOIN tblCategorias c ON p.idCategoria = c.idCategoria
      LEFT JOIN tblTiendas t ON p.ultima_tienda_id = t.idTienda
      WHERE l.cantidad > 0
      ORDER BY l.fechaCaducidad ASC
    ''';

    final res = await conexion!.rawQuery(query);
    return res.map((row) => LoteDAO.fromMap(row)).toList();
  }

  Future<List<LoteDAO>> SELECT_LOTES_FECHA(String fecha) async {
    var conexion = await database;
    final String query = '''
      SELECT 
        l.idLote,
        l.idProducto,
        l.cantidad,
        l.fechaCaducidad,
        l.notificarAlarma,
        l.horaAlarma,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        c.nombre AS categoriaNombre,
        c.colorHex,
        t.nombre AS ultimaTiendaNombre
      FROM tblLotes l
      INNER JOIN tblProductos p ON l.idProducto = p.idProducto
      LEFT JOIN tblCategorias c ON p.idCategoria = c.idCategoria
      LEFT JOIN tblTiendas t ON p.ultima_tienda_id = t.idTienda
      WHERE l.fechaCaducidad = ? AND l.cantidad > 0
      ORDER BY p.nombre ASC
    ''';

    final res = await conexion!.rawQuery(query, [fecha]);
    return res.map((row) => LoteDAO.fromMap(row)).toList();
  }

  Future<List<LoteDAO>> SELECT_LOTES_HOY_Y_VENCIDOS() async {
    var conexion = await database;
    final String fHoy = DateTime.now().toIso8601String().substring(0, 10);
    final String query = '''
      SELECT 
        l.idLote,
        l.idProducto,
        l.cantidad,
        l.fechaCaducidad,
        l.notificarAlarma,
        l.horaAlarma,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        c.nombre AS categoriaNombre,
        c.colorHex,
        t.nombre AS ultimaTiendaNombre
      FROM tblLotes l
      INNER JOIN tblProductos p ON l.idProducto = p.idProducto
      LEFT JOIN tblCategorias c ON p.idCategoria = c.idCategoria
      LEFT JOIN tblTiendas t ON p.ultima_tienda_id = t.idTienda
      WHERE l.cantidad > 0 AND l.fechaCaducidad <= ? AND l.notificarAlarma = 1
      ORDER BY l.fechaCaducidad ASC
    ''';

    final res = await conexion!.rawQuery(query, [fHoy]);
    return res.map((row) => LoteDAO.fromMap(row)).toList();
  }

  // ==========================================
  // CARRITO DE COMPRAS (MAYÚSCULAS)
  // ==========================================
  Future<int> INSERT_CARRITO(int idProducto, int cantidad) async {
    var conexion = await database;
    final existe = await conexion!.query(
      'tblCarrito',
      where: 'idProducto = ?',
      whereArgs: [idProducto],
    );

    if (existe.isNotEmpty) {
      int actual = existe.first['cantidadAComprar'] as int;
      return await conexion.update(
        'tblCarrito',
        {'cantidadAComprar': actual + cantidad},
        where: 'idProducto = ?',
        whereArgs: [idProducto],
      );
    } else {
      return await conexion.insert('tblCarrito', {
        'idProducto': idProducto,
        'cantidadAComprar': cantidad,
      });
    }
  }

  Future<int> UPDATE_CARRITO(int idCarrito, int cantidad) async {
    var conexion = await database;
    return await conexion!.update(
      'tblCarrito',
      {'cantidadAComprar': cantidad},
      where: 'idCarrito = ?',
      whereArgs: [idCarrito],
    );
  }

  Future<int> DELETE_CARRITO(int idCarrito) async {
    var conexion = await database;
    return await conexion!.delete(
      'tblCarrito',
      where: 'idCarrito = ?',
      whereArgs: [idCarrito],
    );
  }

  Future<int> VACIAR_CARRITO() async {
    var conexion = await database;
    return await conexion!.delete('tblCarrito');
  }

  Future<int> COUNT_CARRITO() async {
    var conexion = await database;
    final res = await conexion!.rawQuery('SELECT COUNT(*) as total FROM tblCarrito');
    if (res.isNotEmpty && res.first['total'] != null) {
      return int.tryParse(res.first['total'].toString()) ?? 0;
    }
    return 0;
  }

  Future<List<CarritoDAO>> SELECT_CARRITO() async {
    var conexion = await database;
    final String query = '''
      SELECT 
        car.idCarrito,
        car.idProducto,
        car.cantidadAComprar,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        p.stockMinimo,
        p.ultima_tienda_id,
        c.nombre AS categoriaNombre,
        c.colorHex,
        t.nombre AS ultimaTiendaNombre,
        COALESCE(SUM(CASE WHEN l.cantidad > 0 THEN l.cantidad ELSE 0 END), 0) AS stockTotal
      FROM tblCarrito car
      INNER JOIN tblProductos p ON car.idProducto = p.idProducto
      LEFT JOIN tblCategorias c ON p.idCategoria = c.idCategoria
      LEFT JOIN tblTiendas t ON p.ultima_tienda_id = t.idTienda
      LEFT JOIN tblLotes l ON p.idProducto = l.idProducto
      GROUP BY car.idCarrito
      ORDER BY p.nombre ASC
    ''';

    final res = await conexion!.rawQuery(query);
    return res.map((row) => CarritoDAO.fromMap(row)).toList();
  }

  // ==========================================
  // HISTORIAL Y ESTADÍSTICAS (MAYÚSCULAS)
  // ==========================================
  Future<List<HistorialCompraDAO>> SELECT_HISTORIAL_COMPRAS() async {
    var conexion = await database;
    final String query = '''
      SELECT 
        h.idCompra,
        h.idProducto,
        h.idTienda,
        h.cantidad,
        h.precioUnitario,
        h.fechaCompra,
        p.nombre AS productoNombre,
        p.unidad,
        p.imagen,
        t.nombre AS tiendaNombre
      FROM tblHistorialCompras h
      INNER JOIN tblProductos p ON h.idProducto = p.idProducto
      INNER JOIN tblTiendas t ON h.idTienda = t.idTienda
      ORDER BY h.fechaCompra DESC
    ''';

    final res = await conexion!.rawQuery(query);
    return res.map((row) => HistorialCompraDAO.fromMap(row)).toList();
  }

  Future<Map<String, dynamic>> SELECT_ESTADISTICAS() async {
    var conexion = await database;

    // Gasto por tienda
    final String queryGastoTiendas = '''
      SELECT 
        t.nombre AS tiendaNombre,
        SUM(h.cantidad * h.precioUnitario) AS totalGastado,
        COUNT(h.idCompra) AS totalCompras
      FROM tblHistorialCompras h
      INNER JOIN tblTiendas t ON h.idTienda = t.idTienda
      GROUP BY t.idTienda
      ORDER BY totalGastado DESC
    ''';
    final rawGastoTiendas = await conexion!.rawQuery(queryGastoTiendas);

    // Productos y sus estados
    final productos = await SELECT_PRODUCTOS_COMPLETO();
    int countOptimo = 0;
    int countPorCaducar = 0;
    int countCaducado = 0;
    int countPorAgotarse = 0;
    int countAgotado = 0;

    for (var p in productos) {
      switch (p.estatus) {
        case 'DISPONIBLE':
          countOptimo++;
          break;
        case 'POR CADUCAR':
          countPorCaducar++;
          break;
        case 'CADUCADO':
          countCaducado++;
          break;
        case 'POR AGOTARSE':
          countPorAgotarse++;
          break;
        case 'SIN EXISTENCIA':
          countAgotado++;
          break;
      }
    }

    // Valor monetario en riesgo por productos por caducar o caducados
    // Calculado multiplicando la cantidad de unidades en lotes en riesgo por el último precio registrado
    double valorEnRiesgo = 0.0;
    for (var p in productos) {
      if (p.estatus == 'POR CADUCAR' || p.estatus == 'CADUCADO') {
        final historial = await SELECT_TIENDAS_POR_PRODUCTO(p.idProducto!);
        double precioRef = 25.0; // Precio base fallback
        if (historial.isNotEmpty && historial.first.precioUnitario != null) {
          precioRef = historial.first.precioUnitario!;
        }
        valorEnRiesgo += (p.stockTotal ?? 0) * precioRef;
      }
    }

    return {
      'gastoPorTienda': rawGastoTiendas,
      'conteoEstados': {
        'optimo': countOptimo,
        'porCaducar': countPorCaducar,
        'caducado': countCaducado,
        'porAgotarse': countPorAgotarse,
        'agotado': countAgotado,
        'total': productos.length,
      },
      'valorEnRiesgo': valorEnRiesgo,
    };
  }
}
