import 'dart:io';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import 'package:prac2/components/global_values.dart';
import 'package:prac2/components/menu_circular.dart';
import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/producto_dao.dart';
import 'package:prac2/database/lote_dao.dart';
import 'package:prac2/database/historial_compra_dao.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AlacenaDB? alacenaDB;
  String _filtroSeleccionado = 'ALERTAS';

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
    _actualizarBadge();
  }

  void _actualizarBadge() async {
    final count = await alacenaDB!.COUNT_CARRITO();
    GlobalValues.actualizarCarrito(count);
  }

  @override
  Widget build(BuildContext context) {
    final space = const SizedBox(height: 10);
    final space2 = const SizedBox(height: 16);

    final btnCartBadge = ValueListenableBuilder<int>(
      valueListenable: GlobalValues.banCartCount,
      builder: (context, count, _) {
        return badges.Badge(
          position: badges.BadgePosition.topEnd(top: 2, end: 4),
          showBadge: count > 0,
          badgeContent: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Carrito de Compras',
            onPressed: () {
              Navigator.pushNamed(context, '/carrito').then((_) {
                _actualizarBadge();
                setState(() {});
              });
            },
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Alacena'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Calendario',
            onPressed: () {
              Navigator.pushNamed(context, '/calendario').then((_) {
                _actualizarBadge();
                setState(() {});
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Alertas',
            onPressed: () {
              Navigator.pushNamed(context, '/alarmasHoy').then((_) {
                _actualizarBadge();
                setState(() {});
              });
            },
          ),
          btnCartBadge,
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.kitchen_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Mi Alacena',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: const Text('Inventario'),
                    subtitle: const Text('Productos y lotes'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/productos').then((_) {
                        _actualizarBadge();
                        setState(() {});
                      });
                    },
                  ),
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Categorías'),
                    subtitle: const Text('Clasificación'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/categorias').then((_) {
                        setState(() {});
                      });
                    },
                  ),
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.storefront_outlined),
                    title: const Text('Tiendas'),
                    subtitle: const Text('Establecimientos'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tiendas').then((_) {
                        setState(() {});
                      });
                    },
                  ),
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Historial'),
                    subtitle: const Text('Compras anteriores'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/historial').then((_) {
                        setState(() {});
                      });
                    },
                  ),
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.bar_chart_outlined),
                    title: const Text('Estadísticas'),
                    subtitle: const Text('Métricas y consumo'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/estadisticas').then((_) {
                        setState(() {});
                      });
                    },
                  ),
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Alertas'),
                    subtitle: const Text('Caducidades de hoy'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/alarmasHoy').then((_) {
                        setState(() {});
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  ListTile(
                    shape: const StadiumBorder(),
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Acerca de'),
                    subtitle: const Text('Información de la app'),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: 'Mi Alacena',
                        applicationVersion: '1.0.0',
                        applicationLegalese: 'Control FEFO y Trazabilidad de Alacena',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // SliverToBoxAdapter: Resumen rápido y Filtro interactivo (Widget Nuevo #1: SegmentedButton)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildKpiSummary(),
                  space2,
                  // Widget Nuevo #1: SegmentedButton
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'ALERTAS',
                        label: Text('Alertas'),
                        icon: Icon(Icons.warning_amber_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: 'CRITICOS',
                        label: Text('Críticos'),
                        icon: Icon(Icons.dangerous_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: 'TODOS',
                        label: Text('Todos'),
                        icon: Icon(Icons.list_alt, size: 18),
                      ),
                    ],
                    selected: {_filtroSeleccionado},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _filtroSeleccionado = newSelection.first;
                      });
                    },
                  ),
                  space,
                ],
              ),
            ),
          ),

          // SliverList: Listado de artículos de la alacena
          FutureBuilder<List<ProductoDAO>>(
            future: alacenaDB!.SELECT_PRODUCTOS_COMPLETO(
              filtroEstatus: _filtroSeleccionado,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text('Error al cargar alacena: ${snapshot.error}'),
                  ),
                );
              }

              final productos = snapshot.data ?? [];
              if (productos.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No hay productos en la categoría "$_filtroSeleccionado".',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return ItemProductoAlerta(productos[index]);
                    },
                    childCount: productos.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: const MenuCircular(),
    );
  }

  Widget _buildKpiSummary() {
    return FutureBuilder<List<ProductoDAO>>(
      future: alacenaDB!.SELECT_PRODUCTOS_COMPLETO(),
      builder: (context, snapshot) {
        int porCaducar = 0;
        int porAgotarse = 0;
        int caducados = 0;
        if (snapshot.hasData) {
          for (var p in snapshot.data!) {
            if (p.estatus == 'POR CADUCAR') porCaducar++;
            if (p.estatus == 'POR AGOTARSE') porAgotarse++;
            if (p.estatus == 'CADUCADO') caducados++;
          }
        }

        return Row(
          children: [
            _buildKpiCard(
              'Por Caducar',
              '$porCaducar',
              Colors.orange.shade800,
              Icons.hourglass_bottom,
            ),
            const SizedBox(width: 8),
            _buildKpiCard(
              'Por Agotar',
              '$porAgotarse',
              Colors.amber.shade900,
              Icons.trending_down,
            ),
            const SizedBox(width: 8),
            _buildKpiCard(
              'Caducados',
              '$caducados',
              Colors.red.shade700,
              Icons.dangerous,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String titulo, String valor, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget ItemProductoAlerta(ProductoDAO prod) {
    // Configuración visual según el estatus de negocio
    Color statusColor;
    IconData statusIcon;
    String statusTexto = prod.estatus ?? 'DISPONIBLE';

    switch (statusTexto) {
      case 'CADUCADO':
        statusColor = Colors.red.shade700;
        statusIcon = Icons.dangerous;
        break;
      case 'POR CADUCAR':
        statusColor = Colors.orange.shade800;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case 'POR AGOTARSE':
        statusColor = Colors.amber.shade900;
        statusIcon = Icons.production_quantity_limits;
        break;
      case 'SIN EXISTENCIA':
        statusColor = Colors.blueGrey.shade700;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.green.shade700;
        statusIcon = Icons.check_circle_outline;
        break;
    }

    final int stockTotal = prod.stockTotal ?? 0;
    final int stockMin = prod.stockMinimo ?? 2;
    // Widget Nuevo #2: LinearProgressIndicator cálculo proporcional
    final double progresoStock = (stockMin > 0)
        ? (stockTotal / (stockMin * 2)).clamp(0.0, 1.0)
        : (stockTotal > 0 ? 1.0 : 0.0);

    // Botón Agregar al Carrito (ADN: btnAddCart) con estilo M3 Expressive
    final btnAddCart = FilledButton.icon(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      icon: const Icon(Icons.add_shopping_cart, size: 16),
      label: const Text('Al carrito'),
      onPressed: () {
        alacenaDB!.INSERT_CARRITO(prod.idProducto!, 1).then((val) {
          if (val > 0) {
            _actualizarBadge();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.fixed,
                content: Text(
                  'Se agregó "${prod.nombre}" al carrito.',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
      },
    );

    // Botón Rápido Consumir (ADN: btnConsumirFEFO) con estilo M3 Expressive
    final btnConsumirFEFO = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      icon: const Icon(Icons.restaurant, size: 16),
      label: const Text('Consumir'),
      onPressed: stockTotal > 0
          ? () {
              alacenaDB!
                  .CONSUMIR_PRODUCTO_FEFO(prod.idProducto!, 1)
                  .then((res) {
                final bool success = res['success'] ?? false;
                final String msg = res['mensaje'] ?? '';
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.fixed,
                    content: Text(msg),
                    backgroundColor:
                        success ? Colors.green.shade800 : Colors.red.shade800,
                    duration: const Duration(seconds: 3),
                  ),
                );
                setState(() {});
              });
            }
          : null,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: statusColor.withOpacity(0.35), width: 1.2),
      ),
      elevation: 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: statusColor, width: 6),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            // Widget Nuevo #3: ExpansionTile
            child: ExpansionTile(
              leading: _buildImagenProducto(prod.imagen, prod.categoriaNombre),
              title: Text(
                prod.nombre ?? 'Sin Nombre',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Chip Semántico de Estatus estilo Pill / Stadium
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 13, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusTexto,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        prod.categoriaNombre ?? 'General',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Widget Nuevo #2: LinearProgressIndicator para comparar stock vs mínimo
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progresoStock,
                            minHeight: 7,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stockTotal <= stockMin
                                  ? Colors.redAccent
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$stockTotal / min $stockMin ${prod.unidad}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const Text(
                        'Lotes activos (FEFO):',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildLotesFefoList(prod.idProducto!),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Última tienda: ${prod.ultimaTiendaNombre ?? "Sin registro"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.storefront_outlined, size: 16),
                            label: const Text('Tiendas'),
                            onPressed: () {
                              _mostrarModalTiendas(prod);
                            },
                          ),
                          btnConsumirFEFO,
                          btnAddCart,
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagenProducto(String? ruta, String? categoria) {
    if (ruta != null && ruta.isNotEmpty) {
      final file = File(ruta);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(file, width: 46, height: 46, fit: BoxFit.cover),
        );
      }
    }
    // Fallback a ícono ilustrativo por categoría
    IconData iconData = Icons.fastfood;
    Color iconColor = Theme.of(context).colorScheme.primary;
    if (categoria != null) {
      if (categoria.toLowerCase().contains('lácteo')) {
        iconData = Icons.icecream;
        iconColor = Colors.blue;
      } else if (categoria.toLowerCase().contains('enlatado')) {
        iconData = Icons.takeout_dining;
        iconColor = Colors.orange;
      } else if (categoria.toLowerCase().contains('carne')) {
        iconData = Icons.kebab_dining;
        iconColor = Colors.red;
      } else if (categoria.toLowerCase().contains('limpieza')) {
        iconData = Icons.cleaning_services;
        iconColor = Colors.green;
      }
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildLotesFefoList(int idProducto) {
    return FutureBuilder<List<LoteDAO>>(
      future: alacenaDB!.SELECT_LOTES_POR_PRODUCTO(idProducto),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: LinearProgressIndicator());
        }
        final lotes = snapshot.data!.where((l) => (l.cantidad ?? 0) > 0).toList();
        if (lotes.isEmpty) {
          return Text(
            'Sin lotes activos en inventario.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          children: lotes.map((lote) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_right,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    '${lote.cantidad} ${lote.unidad ?? "pza"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '— Vence: ${lote.fechaCaducidad}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (lote.notificarAlarma == 1)
                    const Icon(Icons.alarm, size: 14, color: Colors.orange),
                ],
              ),
            );
          }).toList(),
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
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
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
                          'Sin registro de tiendas para este producto.',
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
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              child: const Icon(Icons.storefront),
                            ),
                            title: Text(
                              h.tiendaNombre ?? 'Tienda',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Fecha: ${h.fechaCompra} • Cantidad: ${h.cantidad} ${h.unidad}'),
                            trailing: Text(
                              '\$${h.precioUnitario?.toStringAsFixed(2)} c/u',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14,
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
