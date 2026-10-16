import 'package:flutter/material.dart';

import 'package:prac2/database/alacena_db.dart';

class EstadisticasScreen extends StatefulWidget {
  const EstadisticasScreen({super.key});

  @override
  State<EstadisticasScreen> createState() => _EstadisticasScreenState();
}

class _EstadisticasScreenState extends State<EstadisticasScreen> {
  AlacenaDB? alacenaDB;

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: alacenaDB!.SELECT_ESTADISTICAS(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ?? {};
          final List gastoTiendas = data['gastoPorTienda'] as List? ?? [];
          final Map conteo = data['conteoEstados'] as Map? ?? {};
          final double valorRiesgo = (data['valorEnRiesgo'] as num?)?.toDouble() ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de Valor en Riesgo (Prevención de Desperdicio de Alimentos)
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Valor en riesgo',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '\$${valorRiesgo.toStringAsFixed(2)} MXN',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Moneda en riesgo por caducidad',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Distribución de Artículos por Estatus
                const Text(
                  'Salud del inventario',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Column(
                      children: [
                        _buildStatusRow('Óptimos', conteo['optimo'] ?? 0, Colors.green),
                        const Divider(height: 16),
                        _buildStatusRow('Por caducar (≤ 5d)', conteo['porCaducar'] ?? 0, Colors.orange),
                        const Divider(height: 16),
                        _buildStatusRow('Por agotarse', conteo['porAgotarse'] ?? 0, Colors.amber.shade800),
                        const Divider(height: 16),
                        _buildStatusRow('Caducados', conteo['caducado'] ?? 0, Colors.red),
                        const Divider(height: 16),
                        _buildStatusRow('Agotados', conteo['agotado'] ?? 0, Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Gasto Acumulado por Tienda
                const Text(
                  'Gasto por tienda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (gastoTiendas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Sin compras registradas.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gastoTiendas.length,
                    itemBuilder: (context, index) {
                      final item = gastoTiendas[index];
                      final double total = (item['totalGastado'] as num?)?.toDouble() ?? 0.0;
                      final int compras = (item['totalCompras'] as num?)?.toInt() ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            item['tiendaNombre'] ?? 'Tienda',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '$compras compras',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          trailing: Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, int cantidad, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        Text(
          '$cantidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
