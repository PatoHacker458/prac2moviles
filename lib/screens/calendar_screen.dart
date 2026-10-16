import 'dart:io';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:prac2/components/global_values.dart';
import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/lote_dao.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  AlacenaDB? alacenaDB;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<LoteDAO>> _lotesPorFecha = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
    _selectedDay = _focusedDay;
    _cargarLotesCalendario();
  }

  void _cargarLotesCalendario() async {
    final lotes = await alacenaDB!.SELECT_LOTES_CALENDARIO();
    Map<String, List<LoteDAO>> agrupados = {};
    for (var lote in lotes) {
      if (lote.fechaCaducidad != null) {
        if (!agrupados.containsKey(lote.fechaCaducidad)) {
          agrupados[lote.fechaCaducidad!] = [];
        }
        agrupados[lote.fechaCaducidad!]!.add(lote);
      }
    }
    setState(() {
      _lotesPorFecha = agrupados;
      _cargando = false;
    });
  }

  List<LoteDAO> _getEventsForDay(DateTime day) {
    String clave = DateFormat('yyyy-MM-dd').format(day);
    return _lotesPorFecha[clave] ?? [];
  }

  Color _obtenerColorLote(LoteDAO lote) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lote.fechaCaducidad == null) return Colors.teal;
    try {
      final fechaLote = DateTime.parse(lote.fechaCaducidad!);
      final diff = fechaLote.difference(today).inDays;
      if (diff < 0) return Colors.red.shade700;
      if (diff == 0) return Colors.deepOrange;
      if (diff <= 5) return Colors.amber.shade800;
      return Colors.green.shade600;
    } catch (_) {
      return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: () {
              setState(() => _cargando = true);
              _cargarLotesCalendario();
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLeyendaDot(Colors.red.shade700, 'Caducado'),
                      _buildLeyendaDot(Colors.deepOrange, 'Vence Hoy'),
                      _buildLeyendaDot(Colors.amber.shade800, '≤ 5 Días'),
                      _buildLeyendaDot(Colors.green.shade600, 'Óptimo'),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TableCalendar<LoteDAO>(
                            firstDay: DateTime.now().subtract(const Duration(days: 365)),
                            lastDay: DateTime.now().add(const Duration(days: 365)),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            eventLoader: _getEventsForDay,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              todayTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              selectedTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              outsideDaysVisible: false,
                            ),
                            calendarBuilders: CalendarBuilders(
                              // Marcador con la cantidad exacta de puntos correspondientes a los lotes
                              markerBuilder: (context, date, events) {
                                if (events.isEmpty) return null;
                                return Positioned(
                                  bottom: 2,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: events.map((lote) {
                                      Color color = _obtenerColorLote(lote);
                                      return Container(
                                        width: 6,
                                        height: 6,
                                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                              _abrirModalPantallaCompleta(selectedDay);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLeyendaDot(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // MODAL A PANTALLA COMPLETA AL DAR CLICK EN UN DÍA (Requerimiento de Práctica)
  void _abrirModalPantallaCompleta(DateTime fechaSeleccionada) {
    final String fechaStr = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
    final String fechaLegible = DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(fechaSeleccionada);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double modalHeight = MediaQuery.of(context).size.height;

            return SizedBox(
              height: modalHeight,
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Artículos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        fechaLegible,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                body: FutureBuilder<List<LoteDAO>>(
                  future: alacenaDB!.SELECT_LOTES_FECHA(fechaStr),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final lotes = snapshot.data ?? [];
                    if (lotes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 70,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sin alertas para este día',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ningún artículo de la alacena vence en esta fecha.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lotes.length,
                      itemBuilder: (context, index) {
                        final lote = lotes[index];
                        final colorEstado = _obtenerColorLote(lote);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 14),
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: BorderSide(color: colorEstado.withOpacity(0.35), width: 1.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildFotoOIcono(lote.imagen, lote.categoriaNombre),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lote.productoNombre ?? 'Artículo',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            lote.categoriaNombre ?? 'General',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorEstado.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${lote.cantidad} ${lote.unidad ?? "pza"}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorEstado,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.storefront,
                                      size: 16,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Última tienda: ${lote.ultimaTiendaNombre ?? "Sin registro"}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.restaurant, size: 16),
                                      label: const Text('Consumir'),
                                      onPressed: () {
                                        alacenaDB!
                                            .CONSUMIR_PRODUCTO_FEFO(lote.idProducto!, 1)
                                            .then((res) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(res['mensaje'] ?? ''),
                                              duration: const Duration(seconds: 3),
                                            ),
                                          );
                                          setModalState(() {});
                                          _cargarLotesCalendario();
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.icon(
                                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                                      label: const Text('Al carrito'),
                                      onPressed: () {
                                        alacenaDB!
                                            .INSERT_CARRITO(lote.idProducto!, 1)
                                            .then((val) {
                                          if (val > 0) {
                                            alacenaDB!.COUNT_CARRITO().then((c) {
                                              GlobalValues.actualizarCarrito(c);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Se agregó "${lote.productoNombre}" al carrito.',
                                                ),
                                                duration: const Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _cargarLotesCalendario();
    });
  }

  Widget _buildFotoOIcono(String? ruta, String? categoria) {
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
      child: const Icon(Icons.inventory, color: Colors.teal, size: 24),
    );
  }
}
