import 'dart:io';
import 'package:flutter/material.dart';

import 'package:prac2/components/global_values.dart';
import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/carrito_dao.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  AlacenaDB? alacenaDB;

  // Controladores para el diálogo de Compra Inteligente
  final conPrecio = TextEditingController();
  final conFechaCad = TextEditingController();
  final conCantidadCompra = TextEditingController();

  int? _tiendaSeleccionadaId;

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
  }

  @override
  void dispose() {
    conPrecio.dispose();
    conFechaCad.dispose();
    conCantidadCompra.dispose();
    super.dispose();
  }

  void _actualizarBadge() async {
    final count = await alacenaDB!.COUNT_CARRITO();
    GlobalValues.actualizarCarrito(count);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vaciar',
            onPressed: () {
              alacenaDB!.VACIAR_CARRITO().then((_) {
                _actualizarBadge();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Carrito vaciado exitosamente.'),
                    duration: Duration(seconds: 3),
                  ),
                );
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CarritoDAO>>(
        future: alacenaDB!.SELECT_CARRITO(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 70,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Carrito vacío',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Agrega artículos desde la alacena para surtirlos.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Desliza para eliminar o presiona Comprar para ingresar a la alacena.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: Key('cart_${item.idCarrito}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white, size: 26),
                        ),
                        onDismissed: (direction) {
                          alacenaDB!.DELETE_CARRITO(item.idCarrito!).then((_) {
                            _actualizarBadge();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('"${item.productoNombre}" eliminado del carrito.'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          });
                        },
                        child: ItemCarrito(item),
                      );
                    },
                    childCount: items.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  Widget ItemCarrito(CarritoDAO item) {
    final int cantidadActual = item.cantidadAComprar ?? 1;

    // Botón Registrar Compra Inteligente (M3 Expressive: conciso)
    final btnRegistrarCompra = FilledButton.icon(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      icon: const Icon(Icons.shopping_bag_outlined, size: 16),
      label: const Text('Comprar'),
      onPressed: () {
        _mostrarDialogoCompraInteligente(item);
      },
    );

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
                _buildFotoCarrito(item.imagen),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productoNombre ?? 'Artículo',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'En alacena: ${item.stockTotal} ${item.unidad} (mín: ${item.stockMinimo})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.ultimaTiendaNombre != null)
                        Text(
                          'Última tienda: ${item.ultimaTiendaNombre}',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Controles de Cantidad + / - estilo M3 Expressive
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        iconSize: 18,
                        icon: const Icon(Icons.remove),
                        onPressed: cantidadActual > 1
                            ? () {
                                alacenaDB!
                                    .UPDATE_CARRITO(item.idCarrito!, cantidadActual - 1)
                                    .then((_) {
                                  setState(() {});
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$cantidadActual',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      IconButton(
                        iconSize: 18,
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          alacenaDB!
                              .UPDATE_CARRITO(item.idCarrito!, cantidadActual + 1)
                              .then((_) {
                            setState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${item.cantidadAComprar} ${item.unidad} a comprar',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                btnRegistrarCompra,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFotoCarrito(String? ruta) {
    if (ruta != null && ruta.isNotEmpty) {
      final f = File(ruta);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(f, width: 44, height: 44, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.shopping_basket, color: Colors.teal, size: 24),
    );
  }

  // DIÁLOGO COMPRA INTELIGENTE DESDE EL CARRITO (Funcionalidad Estrella)
  void _mostrarDialogoCompraInteligente(CarritoDAO item) async {
    final tiendas = await alacenaDB!.SELECT_TIENDAS();
    if (tiendas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes registrar al menos una tienda primero.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _tiendaSeleccionadaId = item.ultimaTiendaId ?? tiendas.first.idTienda;
    conCantidadCompra.text = '${item.cantidadAComprar ?? 1}';
    conPrecio.text = '25.00';
    conFechaCad.text = DateTime.now()
        .add(const Duration(days: 30))
        .toIso8601String()
        .substring(0, 10);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final txtPrecio = TextFormField(
              controller: conPrecio,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio unitario (\$ MXN)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            );

            final txtCantidad = TextFormField(
              controller: conCantidadCompra,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cantidad (${item.unidad}) *',
                prefixIcon: const Icon(Icons.numbers),
              ),
            );

            final txtFechaCaducidad = TextFormField(
              controller: conFechaCad,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha de caducidad *',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              onTap: () async {
                final fecha = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 1800)),
                );
                if (fecha != null) {
                  setDialogState(() {
                    conFechaCad.text = fecha.toIso8601String().substring(0, 10);
                  });
                }
              },
            );

            final spaceDialog = const SizedBox(height: 12);

            final btnConfirmar = FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Confirmar'),
              onPressed: () {
                if (conPrecio.text.isEmpty ||
                    conCantidadCompra.text.isEmpty ||
                    conFechaCad.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor completa todos los campos requeridos.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                final double? precio = double.tryParse(conPrecio.text);
                final int? cant = int.tryParse(conCantidadCompra.text);

                if (precio == null || precio < 0 || cant == null || cant <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa cantidades y precios válidos.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                final String hoy =
                    DateTime.now().toIso8601String().substring(0, 10);

                // Ejecuta la compra y actualización
                alacenaDB!
                    .INSERT_COMPRA_Y_LOTE(
                  idProducto: item.idProducto!,
                  idTienda: _tiendaSeleccionadaId!,
                  cantidad: cant,
                  precioUnitario: precio,
                  fechaCompra: hoy,
                  fechaCaducidad: conFechaCad.text,
                )
                    .then((idCompra) {
                  if (idCompra > 0) {
                    // Quitar del carrito
                    alacenaDB!.DELETE_CARRITO(item.idCarrito!).then((_) {
                      _actualizarBadge();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '¡Compra de "${item.productoNombre}" registrada con éxito!',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      setState(() {});
                    });
                  }
                });
              },
            );

            return AlertDialog(
              title: Text('Comprar: ${item.productoNombre}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _tiendaSeleccionadaId,
                      decoration: const InputDecoration(
                        labelText: 'Tienda *',
                        prefixIcon: Icon(Icons.storefront_outlined),
                      ),
                      items: tiendas.map((t) {
                        return DropdownMenuItem<int>(
                          value: t.idTienda,
                          child: Text(t.nombre ?? 'Tienda'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          _tiendaSeleccionadaId = val;
                        });
                      },
                    ),
                    spaceDialog,
                    txtCantidad,
                    spaceDialog,
                    txtPrecio,
                    spaceDialog,
                    txtFechaCaducidad,
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.pop(context),
                ),
                btnConfirmar,
              ],
            );
          },
        );
      },
    );
  }
}
