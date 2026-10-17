import 'dart:io';
import 'package:flutter/material.dart';

import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/producto_dao.dart';
import 'package:prac2/database/historial_compra_dao.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  AlacenaDB? alacenaDB;
  final conBusqueda = TextEditingController();
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
  }

  @override
  void dispose() {
    conBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txtBusqueda = TextField(
      controller: conBusqueda,
      decoration: InputDecoration(
        hintText: 'Buscar productos...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: conBusqueda.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  conBusqueda.clear();
                  setState(() => _busqueda = '');
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (val) {
        setState(() {
          _busqueda = val.toLowerCase();
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: txtBusqueda,
          ),
          Expanded(
            child: FutureBuilder<List<ProductoDAO>>(
              future: alacenaDB!.SELECT_PRODUCTOS_COMPLETO(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final productos = (snapshot.data ?? []).where((p) {
                  if (_busqueda.isEmpty) return true;
                  return (p.nombre ?? '').toLowerCase().contains(_busqueda) ||
                      (p.categoriaNombre ?? '').toLowerCase().contains(_busqueda);
                }).toList();

                if (productos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 60,
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No se encontraron artículos.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    return ItemProducto(productos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        onPressed: () {
          Navigator.pushNamed(context, '/addProducto').then((_) {
            setState(() {});
          });
        },
      ),
    );
  }

  Widget ItemProducto(ProductoDAO prod) {
    Color estadoColor = Colors.teal;
    if (prod.estatus == 'CADUCADO') estadoColor = Colors.red.shade700;
    if (prod.estatus == 'POR CADUCAR') estadoColor = Colors.orange.shade800;
    if (prod.estatus == 'POR AGOTARSE') estadoColor = Colors.amber.shade900;
    if (prod.estatus == 'SIN EXISTENCIA') estadoColor = Colors.blueGrey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildFoto(prod.imagen),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.nombre ?? 'Sin Nombre',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${prod.categoriaNombre ?? "General"} • Mín: ${prod.stockMinimo} ${prod.unidad}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Corrección principal: Wrap evita el desborde horizontal (RIGHT OVERFLOWED)
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: estadoColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              prod.estatus ?? 'DISPONIBLE',
                              style: TextStyle(
                                color: estadoColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            'Total: ${prod.stockTotal} ${prod.unidad}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar',
                  onPressed: () {
                    Navigator.pushNamed(context, '/addProducto', arguments: prod)
                        .then((_) => setState(() {}));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  tooltip: 'Eliminar',
                  onPressed: () {
                    _confirmarEliminacion(prod);
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.storefront_outlined, size: 16),
                  label: const Text('Tiendas'),
                  onPressed: () => _mostrarModalTiendas(prod),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.add_box_outlined, size: 16),
                  label: const Text('Surtir'),
                  onPressed: () => _mostrarDialogoNuevoLote(prod),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoto(String? ruta) {
    if (ruta != null && ruta.isNotEmpty) {
      final f = File(ruta);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(f, width: 48, height: 48, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(Icons.kitchen, color: Theme.of(context).colorScheme.primary, size: 26),
    );
  }

  void _confirmarEliminacion(ProductoDAO prod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: Text(
            '¿Deseas eliminar "${prod.nombre}"? Se eliminarán también todos sus lotes asociados.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: const Text('Eliminar'),
              onPressed: () {
                alacenaDB!.DELETE_PRODUCTO(prod.idProducto!).then((val) {
                  Navigator.pop(context);
                  if (val > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Producto eliminado exitosamente.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    setState(() {});
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoNuevoLote(ProductoDAO prod) async {
    final conCant = TextEditingController(text: '1');
    final conFecha = TextEditingController(
      text: DateTime.now().add(const Duration(days: 30)).toIso8601String().substring(0, 10),
    );
    int notifAlarma = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final txtCant = TextFormField(
              controller: conCant,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad (${prod.unidad}) *',
                prefixIcon: const Icon(Icons.numbers),
              ),
            );

            final txtFecha = TextFormField(
              controller: conFecha,
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
                  setDialogState(() {
                    conFecha.text = d.toIso8601String().substring(0, 10);
                  });
                }
              },
            );

            return AlertDialog(
              title: Text('Nuevo lote: ${prod.nombre}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    txtCant,
                    const SizedBox(height: 12),
                    txtFecha,
                    const SizedBox(height: 10),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Alarma de caducidad', style: TextStyle(fontSize: 14)),
                      value: notifAlarma == 1,
                      onChanged: (val) {
                        setDialogState(() {
                          notifAlarma = val ? 1 : 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                FilledButton(
                  child: const Text('Guardar'),
                  onPressed: () {
                    final int? cant = int.tryParse(conCant.text);
                    if (cant == null || cant <= 0 || conFecha.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingresa una cantidad y fecha válidas.')),
                      );
                      return;
                    }

                    alacenaDB!.INSERT_LOTE({
                      'idProducto': prod.idProducto,
                      'cantidad': cant,
                      'fechaCaducidad': conFecha.text,
                      'notificarAlarma': notifAlarma,
                      'horaAlarma': '09:00',
                    }).then((id) {
                      if (id > 0) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('¡Lote agregado exitosamente!')),
                        );
                        setState(() {});
                      }
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarModalTiendas(ProductoDAO prod) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return FutureBuilder<List<HistorialCompraDAO>>(
          future: alacenaDB!.SELECT_TIENDAS_POR_PRODUCTO(prod.idProducto!),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiendas: ${prod.nombre}',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (!snapshot.hasData)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.data!.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Sin historial de compras para este producto.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final h = snapshot.data![index];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              child: const Icon(Icons.storefront),
                            ),
                            title: Text(h.tiendaNombre ?? 'Tienda'),
                            subtitle: Text('Fecha: ${h.fechaCompra} • Cantidad: ${h.cantidad}'),
                            trailing: Text(
                              '\$${h.precioUnitario?.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}