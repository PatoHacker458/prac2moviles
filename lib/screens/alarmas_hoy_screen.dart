import 'dart:io';
import 'package:flutter/material.dart';

import 'package:prac2/components/global_values.dart';
import 'package:prac2/config/notification_service.dart';
import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/lote_dao.dart';

class AlarmasHoyScreen extends StatefulWidget {
  const AlarmasHoyScreen({super.key});

  @override
  State<AlarmasHoyScreen> createState() => _AlarmasHoyScreenState();
}

class _AlarmasHoyScreenState extends State<AlarmasHoyScreen> {
  AlacenaDB? alacenaDB;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
  }

  void _dispararAlarmaDemostracion(List<LoteDAO> lotes) async {
    String cuerpo = '¡Tienes productos de tu alacena que vencen hoy o ya caducaron!';
    if (lotes.isNotEmpty) {
      cuerpo = 'Atención: ${lotes.first.productoNombre} y ${lotes.length - 1} producto(s) más requieren tu atención hoy.';
    }

    await _notificationService.m_mostrarNotificacionInmediata(
      id: 999,
      titulo: '⚠️ Alerta de Caducidad de Alacena',
      cuerpo: cuerpo,
      payload: '/alarmasHoy',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔔 Notificación push local enviada. ¡Revisa tu barra de notificaciones!'),
        backgroundColor: Colors.deepOrange,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de hoy'),
      ),
      body: FutureBuilder<List<LoteDAO>>(
        future: alacenaDB!.SELECT_LOTES_HOY_Y_VENCIDOS(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final lotes = snapshot.data ?? [];

          // Botón Probar Alarma Local (M3 Expressive)
          final btnDispararAlarma = FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepOrange.shade800,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
            icon: const Icon(Icons.notifications_active_outlined),
            label: const Text(
              'Probar alarma',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onPressed: () {
              _dispararAlarmaDemostracion(lotes);
            },
          );

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.deepOrange.withOpacity(0.35)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange, size: 26),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Productos que vencen hoy o con fecha caducada.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepOrange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: btnDispararAlarma,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: lotes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 60,
                              color: Colors.green.shade500,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Sin alertas para hoy',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: lotes.length,
                        itemBuilder: (context, index) {
                          return ItemAlarma(lotes[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget ItemAlarma(LoteDAO lote) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime fechaLote = today;
    try {
      fechaLote = DateTime.parse(lote.fechaCaducidad!);
    } catch (_) {}

    final bool yaVencio = fechaLote.isBefore(today);

    final Color colorBadge = yaVencio ? Colors.red.shade700 : Colors.deepOrange;
    final String etiqueta = yaVencio ? 'CADUCADO' : 'VENCE HOY';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: colorBadge.withOpacity(0.35), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              children: [
                _buildFoto(lote.imagen),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lote.productoNombre ?? 'Artículo',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${lote.categoriaNombre ?? "General"} • Lote: ${lote.cantidad} ${lote.unidad}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vencimiento: ${lote.fechaCaducidad}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorBadge,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorBadge.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                      color: colorBadge,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
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
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['mensaje'] ?? '')),
                      );
                      setState(() {});
                    });
                  },
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Al carrito'),
                  onPressed: () {
                    alacenaDB!.INSERT_CARRITO(lote.idProducto!, 1).then((val) {
                      if (val > 0) {
                        alacenaDB!.COUNT_CARRITO().then((c) {
                          GlobalValues.actualizarCarrito(c);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Se agregó "${lote.productoNombre}" al carrito.'),
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
  }

  Widget _buildFoto(String? ruta) {
    if (ruta != null && ruta.isNotEmpty) {
      final f = File(ruta);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(f, width: 46, height: 46, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.alarm, color: Colors.deepOrange, size: 24),
    );
  }
}
