// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¡Bienvenido!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí vas al catálogo usando la ruta nombrada
                Navigator.of(context).pushNamed('/catalog');
              },
              child: const Text('Ver Catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
