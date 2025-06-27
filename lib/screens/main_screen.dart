import 'package:flutter/material.dart';
import 'catalog_screen.dart'; // ya lo tienes
import 'profile_screen.dart'; // crearás este
import 'favorites_screen.dart'; // crearás este
import 'cart_screen.dart'; // crearás este
import 'category_screen.dart'; // 👈 Asegúrate de importar esta

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _paginaSeleccionada = 0;

  // Estas son las pantallas que se mostrarán
  final List<Widget> _pantallas = [
    const CatalogScreen(),
    const CategoryScreen(), // 👈 Tu nueva pantalla de categorías
    const ProfileScreen(),
    const FavoritesScreen(),
    const CartScreen(),
  ];

  void _cambiarPantalla(int index) {
    setState(() {
      _paginaSeleccionada = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_paginaSeleccionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaSeleccionada,
        onTap: _cambiarPantalla,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
        ],
      ),
    );
  }
}
