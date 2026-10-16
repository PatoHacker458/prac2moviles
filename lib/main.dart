import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:prac2/components/global_values.dart';
import 'package:prac2/components/theme_app.dart';
import 'package:prac2/config/notification_service.dart';

import 'package:prac2/screens/dashboard_screen.dart';
import 'package:prac2/screens/calendar_screen.dart';
import 'package:prac2/screens/cart_screen.dart';
import 'package:prac2/screens/productos_screen.dart';
import 'package:prac2/screens/add_producto_screen.dart';
import 'package:prac2/screens/categorias_screen.dart';
import 'package:prac2/screens/tiendas_screen.dart';
import 'package:prac2/screens/historial_screen.dart';
import 'package:prac2/screens/alarmas_hoy_screen.dart';
import 'package:prac2/screens/estadisticas_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialización de notificaciones y alarmas locales
  final notificationService = NotificationService();
  await notificationService.m_initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: GlobalValues.banTheme,
      builder: (context, value, _) {
        ThemeData tema = ThemeApp.darkTheme();
        switch (value) {
          case 0:
            tema = ThemeApp.darkTheme();
            break;
          case 1:
            tema = ThemeApp.lightTheme();
            break;
          case 2:
            tema = ThemeApp.warmTheme();
            break;
        }

        return MaterialApp(
          navigatorKey: NotificationService.navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Mi Alacena Inteligente',
          theme: tema,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES'),
          home: const DashboardScreen(),
          routes: {
            "/dash": (context) => const DashboardScreen(),
            "/calendario": (context) => const CalendarScreen(),
            "/carrito": (context) => const CartScreen(),
            "/productos": (context) => const ProductosScreen(),
            "/addProducto": (context) => const AddProductoScreen(),
            "/categorias": (context) => const CategoriasScreen(),
            "/tiendas": (context) => const TiendasScreen(),
            "/historial": (context) => const HistorialScreen(),
            "/alarmasHoy": (context) => const AlarmasHoyScreen(),
            "/estadisticas": (context) => const EstadisticasScreen(),
          },
        );
      },
    );
  }
}
