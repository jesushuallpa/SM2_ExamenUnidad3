import 'package:flutter/material.dart';

class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          // Permite hacer zoom y desplazar la imagen
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain, // Ajusta la imagen para que se vea completa
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Text(
                  'No se pudo cargar la imagen',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
