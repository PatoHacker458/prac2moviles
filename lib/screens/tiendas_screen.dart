import 'package:flutter/material.dart';

import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/tienda_dao.dart';

class TiendasScreen extends StatefulWidget {
  const TiendasScreen({super.key});

  @override
  State<TiendasScreen> createState() => _TiendasScreenState();
}

class _TiendasScreenState extends State<TiendasScreen> {
  AlacenaDB? alacenaDB;

  // Controladores según ADN de la clase
  final conNombre = TextEditingController();
  final conDireccion = TextEditingController();
  final conTelefono = TextEditingController();

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
  }

  @override
  void dispose() {
    conNombre.dispose();
    conDireccion.dispose();
    conTelefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiendas'),
      ),
      body: FutureBuilder<List<TiendaDAO>>(
        future: alacenaDB!.SELECT_TIENDAS(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tiendas = snapshot.data ?? [];
          if (tiendas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 70,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay tiendas.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: tiendas.length,
            itemBuilder: (context, index) {
              return ItemTienda(tiendas[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _mostrarDialogoGuardar(null);
        },
      ),
    );
  }

  Widget ItemTienda(TiendaDAO t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: const Icon(Icons.storefront),
        ),
        title: Text(
          t.nombre ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.direccion != null && t.direccion!.isNotEmpty)
              Text('Dirección: ${t.direccion}'),
            if (t.telefono != null && t.telefono!.isNotEmpty)
              Text('Teléfono: ${t.telefono}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => _mostrarDialogoGuardar(t),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'Eliminar',
              onPressed: () => _eliminarTienda(t),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoGuardar(TiendaDAO? tiendaEdicion) {
    if (tiendaEdicion != null) {
      conNombre.text = tiendaEdicion.nombre ?? '';
      conDireccion.text = tiendaEdicion.direccion ?? '';
      conTelefono.text = tiendaEdicion.telefono ?? '';
    } else {
      conNombre.clear();
      conDireccion.clear();
      conTelefono.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        final txtNombre = TextFormField(
          controller: conNombre,
          decoration: const InputDecoration(
            labelText: 'Nombre *',
            prefixIcon: Icon(Icons.storefront_outlined),
          ),
        );

        final txtDireccion = TextFormField(
          controller: conDireccion,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        );

        final txtTelefono = TextFormField(
          controller: conTelefono,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
        );

        final space = const SizedBox(height: 12);

        final btnGuardar = FilledButton(
          child: const Text('Guardar'),
          onPressed: () {
            if (conNombre.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El nombre de la tienda es obligatorio.'),
                ),
              );
              return;
            }

            if (tiendaEdicion == null) {
              // INSERT
              alacenaDB!.INSERT_TIENDA({
                'nombre': conNombre.text.trim(),
                'direccion': conDireccion.text.trim(),
                'telefono': conTelefono.text.trim(),
              }).then((val) {
                if (val > 0) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tienda registrada exitosamente.')),
                  );
                  setState(() {});
                }
              });
            } else {
              // UPDATE
              alacenaDB!.UPDATE_TIENDA({
                'idTienda': tiendaEdicion.idTienda,
                'nombre': conNombre.text.trim(),
                'direccion': conDireccion.text.trim(),
                'telefono': conTelefono.text.trim(),
              }).then((val) {
                if (val > 0) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tienda actualizada exitosamente.')),
                  );
                  setState(() {});
                }
              });
            }
          },
        );

        return AlertDialog(
          title: Text(tiendaEdicion == null ? 'Nueva tienda' : 'Editar tienda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                txtNombre,
                space,
                txtDireccion,
                space,
                txtTelefono,
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            btnGuardar,
          ],
        );
      },
    );
  }

  void _eliminarTienda(TiendaDAO t) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: Text('¿Deseas eliminar "${t.nombre}"?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
              child: const Text('Eliminar'),
              onPressed: () {
                Navigator.pop(context);
                // Prueba de integridad referencial
                alacenaDB!.DELETE_TIENDA(t.idTienda!).then((res) {
                  if (res == -1) {
                    _mostrarAlertaIntegridadReferencial(
                      'No se puede eliminar la tienda "${t.nombre}" porque tiene compras registradas en el historial o está asociada a productos del inventario.',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tienda eliminada exitosamente.'),
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

  void _mostrarAlertaIntegridadReferencial(String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.red),
              SizedBox(width: 8),
              Text('Integridad Referencial'),
            ],
          ),
          content: Text(mensaje),
          actions: [
            TextButton(
              child: const Text('Entendido'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }
}
