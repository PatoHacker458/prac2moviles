# Mi Alacena - Control FEFO & Gestión de Inventario Doméstico

**Mi Alacena** es una aplicación móvil desarrollada en **Flutter** que resuelve el problema del desperdicio de alimentos y el descontrol del inventario del hogar. Mediante una capa de persistencia local en **SQLite**, la aplicación administra el stock, automatiza el consumo bajo el criterio logístico **FEFO (*First Expired, First Out*)**, mantiene la trazabilidad de compras por tienda y genera alertas locales de caducidad.

---

## Características Principales

* **Control FEFO (*First Expired, First Out*):** Descuento automático de existencias priorizando el lote con la fecha de caducidad más próxima a vencer.
* **Calendario de Vencimientos (`table_calendar`):** Visualización mensual con puntos indicadores por día y modal interactivo a pantalla completa.
* **Carrito de Compras en Tiempo Real (`badges`):** Contador flotante reactivo en el `AppBar` para armar la lista de super.
* **Trazabilidad de Establecimientos:** Registro histórico de compras por tienda y actualización automática de la última tienda visitada.
* **Alarmas Locales de Caducidad:** Sistema de notificación para consultar de manera urgente los productos que vencen el día de hoy.
* **UI/UX Material Design 3:** Implementación de Slivers para desplazamiento de alto rendimiento, tarjetas expansibles (`ExpansionTile`), barras de progreso de stock (`LinearProgressIndicator`) y selectores segmentados (`SegmentedButton`).


## Arquitectura e Integración de Tecnologías

El proyecto sigue una arquitectura limpia orientada a componentes y separación de capas:

```
lib/
├── components/          # Widgets reutilizables, menús circulares, temas y globales
│   ├── global_values.dart
│   ├── menu_circular.dart
│   └── theme_app.dart
├── config/              # Configuración de servicios del sistema
│   └── notification_service.dart
├── database/            # Capa de datos, SQLite Helper y objetos DAO
│   ├── alacena_db.dart
│   ├── producto_dao.dart
│   ├── lote_dao.dart
│   ├── categoria_dao.dart
│   ├── tienda_dao.dart
│   ├── historial_compra_dao.dart
│   └── carrito_dao.dart
├── screens/             # Vistas e interfaces de usuario (UI)
│   ├── dashboard_screen.dart
│   ├── productos_screen.dart
│   ├── add_producto_screen.dart
│   ├── calendar_screen.dart
│   ├── cart_screen.dart
│   ├── alarmas_hoy_screen.dart
│   ├── categorias_screen.dart
│   ├── tiendas_screen.dart
│   ├── historial_screen.dart
│   └── estadisticas_screen.dart
└── main.dart            # Punto de entrada de la aplicación y configuración de rutas
```

## Diseño e Implementación de la Base de Datos (SQLite)

La base de datos fue diseñada cumpliendo estrictamente con la **integridad de dominio** y la **integridad referencial** mediante llaves primarias, llaves foráneas (`FOREIGN KEY`) y restricciones (`NOT NULL`, `CHECK`).

```
 +------------------+        +------------------+        +------------------+
 |    CATEGORIA     |        |     PRODUCTO     |        |      TIENDA      |
 +------------------+        +------------------+        +------------------+
 | idCategoria (PK) |<-------| idProducto (PK)  |------->| idTienda (PK)    |
 | nombre           |        | nombre           |        | nombre           |
 +------------------+        | stockMinimo      |        | direccion        |
                             | unidad           |        +------------------+
                             | idCategoria (FK) |                 ^
                             | ultimaTiendaId(FK)-----------------+
                             | imagen           |
                             +------------------+
                                      |
                 +--------------------+--------------------+
                 |                                         |
                 v                                         v
       +------------------+                      +-------------------+
       |       LOTE       |                      | HISTORIAL_COMPRA  |
       +------------------+                      +-------------------+
       | idLote (PK)      |                      | idHistorial (PK)  |
       | idProducto (FK)  |                      | idProducto (FK)   |
       | cantidad         |                      | idTienda (FK)     |
       | fechaCaducidad   |                      | fechaCompra       |
       | notificarAlarma  |                      | cantidad          |
       | horaAlarma       |                      | precioUnitario    |
       +------------------+                      +-------------------+
```

### **Librerías Clave (`pubspec.yaml`):**

* `sqflite`: Persistencia relacional local en el dispositivo.
* `table_calendar`: Renderizado de calendario interactivo para control temporal.
* `badges`: Indicadores visuales sobre el icono del carrito de compras.
* `flutter_launcher_icons`: Generación automatizada del icono de la aplicación.

---

## Instalación y Configuración

1. **Clonar el repositorio:**
```bash
git clone https://github.com/patohacker458/prac2moviles.git
cd prac2moviles

```


2. **Obtener dependencias:**
```bash
flutter pub get

```


3. **Ejecutar en tu dispositivo móvil o emulador:**
```bash
flutter run

```



---

## Estudiantes

* **Emilio Sebastian Chavez Vega**
* **Juan José Hernández Pérez**

---
