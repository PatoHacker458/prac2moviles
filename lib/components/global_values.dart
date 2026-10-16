import 'package:flutter/material.dart';

class GlobalValues {
  // 0 -> Noche / Dark
  // 1 -> Dia / Light
  // 2 -> Cálido / Warm
  static ValueNotifier<int> banTheme = ValueNotifier(0);

  // Contador reactivo para el badge del carrito de compras
  static ValueNotifier<int> banCartCount = ValueNotifier(0);

  static void actualizarCarrito(int nuevoConteo) {
    banCartCount.value = nuevoConteo;
  }
}
