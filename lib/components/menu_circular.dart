import 'package:flutter/material.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:prac2/components/global_values.dart';

class MenuCircular extends StatelessWidget {
  const MenuCircular({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      toggleButtonColor: const Color(0xFF00897B),
      toggleButtonIconColor: Colors.white,
      items: [
        CircularMenuItem(
          icon: Icons.light_mode,
          color: Colors.amber.shade700,
          iconColor: Colors.white,
          onTap: () {
            GlobalValues.banTheme.value = 1; // Día / Light
          },
        ),
        CircularMenuItem(
          icon: Icons.dark_mode,
          color: Colors.indigo.shade700,
          iconColor: Colors.white,
          onTap: () {
            GlobalValues.banTheme.value = 0; // Noche / Dark
          },
        ),
        CircularMenuItem(
          icon: Icons.coffee,
          color: Colors.brown.shade600,
          iconColor: Colors.white,
          onTap: () {
            GlobalValues.banTheme.value = 2; // Cálido / Warm
          },
        ),
      ],
    );
  }
}
