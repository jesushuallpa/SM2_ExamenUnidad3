import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';
import 'chat_screen.dart';
import 'favorites_screen.dart';
import '../services/FavoriteService.dart';

class CatalogScreen extends StatefulWidget {
  final String? categoriaPreseleccionada;
  const CatalogScreen({super.key, this.categoriaPreseleccionada});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> _productosFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchText = '';
  String _selectedCategory = 'Todos';
  String? _nombreUsuario;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoriaPreseleccionada ?? 'Todos';
    _productosFuture = _loadProducts();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('usuario').doc(uid).get();
      setState(() {
        _nombreUsuario = doc.data()?['nombre'] ?? 'Usuario';
      });
    }
  }

  Future<List<Product>> _loadProducts() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('producto')
        .where('estado', isEqualTo: 'disponible')
        .get();
    final productos = snapshot.docs.map((doc) => Product.fromMap(doc.id, doc.data())).toList();
    setState(() => _allProducts = productos);
    _filterProducts();
    return productos;
  }

  void _filterProducts() {
    final texto = _searchText.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        final coincideNombre = p.nombre.toLowerCase().contains(texto);
        final coincideCategoria = _selectedCategory == 'Todos' || p.categoria == _selectedCategory;
        return coincideNombre && coincideCategoria;
      }).toList();
    });
  }

  String _obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nombreUsuario ?? 'Cargando...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(_obtenerSaludo(), style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      );
                    },
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) {
                  _searchText = v;
                  _filterProducts();
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: _productosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_filteredProducts.isEmpty) {
                    return const Center(child: Text('No hay productos disponibles'));
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, i) {
                        final product = _filteredProducts[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              _buildProductCard(product),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: StatefulBuilder(
                                  builder: (context, setStateIcon) {
                                    return FutureBuilder<bool>(
                                      future: _favoriteService.isFavorite(product.id),
                                      builder: (context, snapshot) {
                                        bool isFav = snapshot.data ?? false;
                                        return GestureDetector(
                                          onTap: () async {
                                            setStateIcon(() {
                                              isFav = !isFav;
                                            });
                                            if (isFav) {
                                              await _favoriteService.addFavorite(product.id);
                                            } else {
                                              await _favoriteService.removeFavorite(product.id);
                                            }
                                          },
                                          child: AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 300),
                                            transitionBuilder: (child, animation) =>
                                                ScaleTransition(scale: animation, child: child),
                                            child: Icon(
                                              isFav ? Icons.favorite : Icons.favorite_border,
                                              key: ValueKey(isFav),
                                              color: isFav ? Colors.red : Colors.grey,
                                              size: 26,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final precioConDescuento = product.precio * (1 - product.descuento / 100);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: product.imagenes.isNotEmpty
                  ? Image.network(product.imagenes[0], fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 10),
          Text(product.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('S/ ${precioConDescuento.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
          Text('Antes: S/ ${product.precio.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}