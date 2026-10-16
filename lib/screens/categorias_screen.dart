import 'package:flutter/material.dart';

import 'package:prac2/database/alacena_db.dart';
import 'package:prac2/database/categoria_dao.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  AlacenaDB? alacenaDB;

  // Controladores según ADN de la clase
  final conNombre = TextEditingController();
  String _colorHexSeleccionado = '#3498DB';

  final List<String> _coloresDisponibles = [
    '#3498DB', // Azul
    '#E67E22', // Naranja
    '#E74C3C', // Rojo
    '#2ECC71', // Verde
    '#9B59B6', // Morado
    '#1ABC9C', // Turquesa
    '#F39C12', // Amarillo / Ámbar
    '#34495E', // Gris azulado
  ];

  @override
  void initState() {
    super.initState();
    alacenaDB = AlacenaDB();
  }

  @override
  void dispose() {
    conNombre.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.tryParse('0x$hex') ?? 0xFF00796B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
      ),
      body: FutureBuilder<List<CategoriaDAO>>(
        future: alacenaDB!.SELECT_CATEGORIAS(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categorias = snapshot.data ?? [];
          if (categorias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 70,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No hay categorías.',
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
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              return ItemCategoria(categorias[index]);
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

  Widget ItemCategoria(CategoriaDAO cat) {
    final Color colorCat = _hexToColor(cat.colorHex ?? '#3498DB');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorCat.withOpacity(0.35),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        leading: CircleAvatar(
          backgroundColor: colorCat.withOpacity(0.18),
          foregroundColor: colorCat,
          child: const Icon(Icons.folder_outlined),
        ),
        title: Text(
          cat.nombre ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('Color: ${cat.colorHex}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => _mostrarDialogoGuardar(cat),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'Eliminar',
              onPressed: () => _eliminarCategoria(cat),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoGuardar(CategoriaDAO? categoriaEdicion) {
    if (categoriaEdicion != null) {
      conNombre.text = categoriaEdicion.nombre ?? '';
      _colorHexSeleccionado = categoriaEdicion.colorHex ?? '#3498DB';
    } else {
      conNombre.clear();
      _colorHexSeleccionado = '#3498DB';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final txtNombre = TextFormField(
              controller: conNombre,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: Icon(Icons.label_outline),
              ),
            );

            final space = const SizedBox(height: 12);

            final btnGuardar = FilledButton(
              child: const Text('Guardar'),
              onPressed: () {
                if (conNombre.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('El nombre de la categoría es obligatorio.'),
                    ),
                  );
                  return;
                }

                if (categoriaEdicion == null) {
                  // INSERT
                  alacenaDB!.INSERT_CATEGORIA({
                    'nombre': conNombre.text.trim(),
                    'colorHex': _colorHexSeleccionado,
                  }).then((val) {
                    if (val > 0) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Categoría creada correctamente.')),
                      );
                      setState(() {});
                    }
                  });
                } else {
                  // UPDATE
                  alacenaDB!.UPDATE_CATEGORIA({
                    'idCategoria': categoriaEdicion.idCategoria,
                    'nombre': conNombre.text.trim(),
                    'colorHex': _colorHexSeleccionado,
                  }).then((val) {
                    if (val > 0) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Categoría actualizada.')),
                      );
                      setState(() {});
                    }
                  });
                }
              },
            );

            return AlertDialog(
              title: Text(categoriaEdicion == null ? 'Nueva categoría' : 'Editar categoría'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    txtNombre,
                    space,
                    const Text('Color:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _coloresDisponibles.map((hex) {
                        final bool seleccionado = _colorHexSeleccionado == hex;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              _colorHexSeleccionado = hex;
                            });
                          },
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _hexToColor(hex),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: seleccionado ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: seleccionado
                                  ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
                                  : null,
                            ),
                            child: seleccionado
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
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
      },
    );
  }

  void _eliminarCategoria(CategoriaDAO cat) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar'),
          content: Text('¿Deseas eliminar la categoría "${cat.nombre}"?'),
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
                alacenaDB!.DELETE_CATEGORIA(cat.idCategoria!).then((res) {
                  if (res == -1) {
                    // Restricción de llave foránea fallida
                    _mostrarAlertaIntegridadReferencial(
                      'No se puede eliminar la categoría "${cat.nombre}" porque tiene artículos asociados en el inventario. Elimina o reclasifica primero los productos vinculados.',
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Categoría eliminada exitosamente.'),
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
