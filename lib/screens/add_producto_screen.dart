import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/producto_dao.dart';
import 'package:prac2/database/categoria_dao.dart';
import 'package:prac2/database/tienda_dao.dart';

class AddProductoScreen extends StatefulWidget {
  const AddProductoScreen({super.key});

  @override
  State<AddProductoScreen> createState() => _AddProductoScreenState();
}

class _AddProductoScreenState extends State<AddProductoScreen> {
  AlacenaDB? alacenaDB;

  // Controladores según ADN de la clase
  final conNombre = TextEditingController();
  final conUnidad = TextEditingController(text: 'pza');
  final conStockMin = TextEditingController(text: '2');

  // Controladores para el lote inicial opcional
  final conCantidad = TextEditingController(text: '1');
  final conFechaCad = TextEditingController();
  final conPrecio = TextEditingController(text: '20.00');

  int? _idCategoriaSeleccionada;
  int? _idTiendaSeleccionada;
  bool _registrarLoteInicial = true;
  bool _notificarAlarma = true;
  String? _rutaImagen;

  ProductoDAO? _productoEdicion;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
    conFechaCad.text = DateTime.now()
        .add(const Duration(days: 30))
        .toIso8601String()
        .substring(0, 10);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        _productoEdicion =
            ModalRoute.of(context)!.settings.arguments as ProductoDAO;
        conNombre.text = _productoEdicion!.nombre ?? '';
        conUnidad.text = _productoEdicion!.unidad ?? 'pza';
        conStockMin.text = '${_productoEdicion!.stockMinimo ?? 2}';
        _idCategoriaSeleccionada = _productoEdicion!.idCategoria;
        _idTiendaSeleccionada = _productoEdicion!.ultimaTiendaId;
        _rutaImagen = _productoEdicion!.imagen;
        _registrarLoteInicial = false; // Al editar solo editamos datos de catálogo
      }
      _inicializado = true;
    }
  }

  @override
  void dispose() {
    conNombre.dispose();
    conUnidad.dispose();
    conStockMin.dispose();
    conCantidad.dispose();
    conFechaCad.dispose();
    conPrecio.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _rutaImagen = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar la imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Declaración de widgets según ADN de la clase (txt..., btn..., space)
    final txtNombre = TextFormField(
      controller: conNombre,
      decoration: const InputDecoration(
        labelText: 'Nombre *',
        prefixIcon: Icon(Icons.shopping_bag_outlined),
      ),
    );

    final txtUnidad = TextFormField(
      controller: conUnidad,
      decoration: const InputDecoration(
        labelText: 'Unidad (pza, kg, lt)',
        prefixIcon: Icon(Icons.straighten),
      ),
    );

    final txtStockMin = TextFormField(
      controller: conStockMin,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Stock mínimo *',
        prefixIcon: Icon(Icons.low_priority),
      ),
    );

    final txtCantidad = TextFormField(
      controller: conCantidad,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Cantidad inicial *',
        prefixIcon: Icon(Icons.numbers),
      ),
    );

    final txtPrecio = TextFormField(
      controller: conPrecio,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Precio unitario (\$ MXN)',
        prefixIcon: Icon(Icons.attach_money),
      ),
    );

    final txtFechaCad = TextFormField(
      controller: conFechaCad,
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Fecha de caducidad *',
        prefixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 30)),
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 1800)),
        );
        if (d != null) {
          setState(() {
            conFechaCad.text = d.toIso8601String().substring(0, 10);
          });
        }
      },
    );

    final space = const SizedBox(height: 12);
    final space2 = const SizedBox(height: 20);

    // Botón Guardar (ADN de la clase: btnSave) con estilo M3 Expressive
    final btnSave = FilledButton.icon(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.save_outlined),
      label: Text(
        _productoEdicion == null ? 'Guardar' : 'Actualizar',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        // Validaciones directas sin FormKey según ADN
        if (conNombre.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El nombre del producto es obligatorio.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        if (_idCategoriaSeleccionada == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes seleccionar una categoría.'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        final int stockMin = int.tryParse(conStockMin.text) ?? 2;

        if (_productoEdicion == null) {
          // INSERTAR NUEVO PRODUCTO
          alacenaDB!.INSERT_PRODUCTO({
            'nombre': conNombre.text.trim(),
            'imagen': _rutaImagen ?? '',
            'unidad': conUnidad.text.trim().isEmpty ? 'pza' : conUnidad.text.trim(),
            'stockMinimo': stockMin,
            'idCategoria': _idCategoriaSeleccionada,
            'ultima_tienda_id': _idTiendaSeleccionada,
          }).then((idProd) {
            if (idProd > 0) {
              // Si se marcó registrar lote inicial
              if (_registrarLoteInicial) {
                final int cant = int.tryParse(conCantidad.text) ?? 1;
                final double precio = double.tryParse(conPrecio.text) ?? 0.0;

                alacenaDB!.INSERT_LOTE({
                  'idProducto': idProd,
                  'cantidad': cant,
                  'fechaCaducidad': conFechaCad.text,
                  'notificarAlarma': _notificarAlarma ? 1 : 0,
                  'horaAlarma': '09:00',
                });

                if (_idTiendaSeleccionada != null) {
                  final String hoy =
                      DateTime.now().toIso8601String().substring(0, 10);
                  alacenaDB!.INSERT_COMPRA_Y_LOTE(
                    idProducto: idProd,
                    idTienda: _idTiendaSeleccionada!,
                    cantidad: cant,
                    precioUnitario: precio,
                    fechaCompra: hoy,
                    fechaCaducidad: conFechaCad.text,
                    notificarAlarma: _notificarAlarma ? 1 : 0,
                  );
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Se guardó el artículo correctamente.'),
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.pop(context, true);
            }
          });
        } else {
          // ACTUALIZAR PRODUCTO EXISTENTE
          alacenaDB!.UPDATE_PRODUCTO({
            'idProducto': _productoEdicion!.idProducto,
            'nombre': conNombre.text.trim(),
            'imagen': _rutaImagen ?? '',
            'unidad': conUnidad.text.trim().isEmpty ? 'pza' : conUnidad.text.trim(),
            'stockMinimo': stockMin,
            'idCategoria': _idCategoriaSeleccionada,
            'ultima_tienda_id': _idTiendaSeleccionada,
          }).then((res) {
            if (res > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Artículo actualizado correctamente.'),
                  duration: Duration(seconds: 3),
                ),
              );
              Navigator.pop(context, true);
            }
          });
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_productoEdicion == null ? 'Nuevo producto' : 'Editar producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de Imagen de Galería / Cámara
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: _rutaImagen != null && _rutaImagen!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: File(_rutaImagen!).existsSync()
                                ? Image.file(File(_rutaImagen!), fit: BoxFit.cover)
                                : Icon(Icons.kitchen, size: 50, color: Theme.of(context).colorScheme.primary),
                          )
                        : Icon(Icons.add_a_photo_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 18,
                      child: PopupMenuButton<ImageSource>(
                        icon: Icon(Icons.camera_alt, size: 18, color: Theme.of(context).colorScheme.onPrimary),
                        onSelected: _seleccionarImagen,
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: ImageSource.camera,
                            child: Row(
                              children: [
                                Icon(Icons.camera_alt_outlined),
                                SizedBox(width: 8),
                                Text('Cámara'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: ImageSource.gallery,
                            child: Row(
                              children: [
                                Icon(Icons.photo_library_outlined),
                                SizedBox(width: 8),
                                Text('Galería'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Toca el ícono para agregar foto',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            space2,

            // Selector de Categoría
            FutureBuilder<List<CategoriaDAO>>(
              future: alacenaDB!.SELECT_CATEGORIAS(),
              builder: (context, snapshot) {
                final categorias = snapshot.data ?? [];
                if (_idCategoriaSeleccionada == null && categorias.isNotEmpty) {
                  _idCategoriaSeleccionada = categorias.first.idCategoria;
                }

                return DropdownButtonFormField<int>(
                  value: _idCategoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categorias.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat.idCategoria,
                      child: Text(cat.nombre ?? 'Sin Categoría'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _idCategoriaSeleccionada = val;
                    });
                  },
                );
              },
            ),
            space,
            txtNombre,
            space,
            Row(
              children: [
                Expanded(child: txtUnidad),
                const SizedBox(width: 10),
                Expanded(child: txtStockMin),
              ],
            ),
            space,

            // Selector de Tienda
            FutureBuilder<List<TiendaDAO>>(
              future: alacenaDB!.SELECT_TIENDAS(),
              builder: (context, snapshot) {
                final tiendas = snapshot.data ?? [];
                return DropdownButtonFormField<int?>(
                  value: _idTiendaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Tienda (opcional)',
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Ninguna'),
                    ),
                    ...tiendas.map((t) {
                      return DropdownMenuItem<int?>(
                        value: t.idTienda,
                        child: Text(t.nombre ?? 'Tienda'),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _idTiendaSeleccionada = val;
                    });
                  },
                );
              },
            ),
            space2,

            // Sección Opcional de Registro de Lote Inicial (Solo en Creación)
            if (_productoEdicion == null) ...[
              Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Existencia inicial',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Registrar primer lote con caducidad'),
                        value: _registrarLoteInicial,
                        onChanged: (val) {
                          setState(() {
                            _registrarLoteInicial = val;
                          });
                        },
                      ),
                      if (_registrarLoteInicial) ...[
                        const Divider(),
                        txtCantidad,
                        space,
                        txtPrecio,
                        space,
                        txtFechaCad,
                        space,
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Alarma de caducidad'),
                          subtitle: const Text('Avisar el día del vencimiento'),
                          value: _notificarAlarma,
                          onChanged: (val) {
                            setState(() {
                              _notificarAlarma = val;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              space2,
            ],

            btnSave,
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
