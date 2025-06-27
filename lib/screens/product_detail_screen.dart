import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_moviles_2/models/product.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
import 'package:proyecto_moviles_2/services/FavoriteService.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  bool _isLoading = true;
  bool isFavorite = false;
  String? _selectedSize;
  String? _selectedColor;
  int _quantity = 1;

  // Controladores de comentarios
  final TextEditingController _comentarioCtrl = TextEditingController();
  int _valoracionNueva = 0;

  final FavoriteService _favoriteService = FavoriteService();

  // Variables de usuario
  String? _nombreUsuario;
  bool _usuarioCargado = false;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadProductData();
    _checkFavoriteStatus();
    _loadUserData();
    if (_product.tallas.length == 1) _selectedSize = _product.tallas.first;
    if (_product.colores.length == 1) _selectedColor = _product.colores.first;
  }

  Future<void> _loadUserData() async {
    try {
      final data = await AuthService.getUserData();
      setState(() {
        _nombreUsuario = data?['nombre'];
        _usuarioCargado = true;
      });
    } catch (_) {
      setState(() {
        _usuarioCargado = true;
      });
    }
  }

  void _checkFavoriteStatus() async {
    if (AuthService.isUserLoggedIn()) {
      final status = await _favoriteService.isFavorite(_product.id);
      setState(() {
        isFavorite = status;
      });
    }
  }

  Future<void> _loadProductData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('producto')
          .doc(_product.id)
          .get();
      if (snapshot.exists) {
        setState(() {
          _product = Product.fromFirestore(snapshot);
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _comprarAhora() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para comprar.')),
      );
      return;
    }
    if (_product.tallas.isNotEmpty && _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una talla.')),
      );
      return;
    }
    if (_product.colores.isNotEmpty && _selectedColor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un color.')),
      );
      return;
    }
    if (_quantity > _product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock insuficiente. Disponible: ${_product.stock}'),
        ),
      );
      return;
    }

    String itemId = _product.id;
    if (_selectedSize != null) itemId += '-$_selectedSize';
    if (_selectedColor != null) itemId += '-$_selectedColor';

    final cartItemRef = FirebaseFirestore.instance
        .collection('carrito')
        .doc(user.uid)
        .collection('items')
        .doc(itemId);

    try {
      final snapshot = await cartItemRef.get();

      if (snapshot.exists) {
        await cartItemRef.update({
          'cantidad': FieldValue.increment(_quantity),
        });
      } else {
        await cartItemRef.set({
          'nombre': _product.nombre,
          'precio': _product.precio,
          'descuento': _product.descuento,
          'cantidad': _quantity,
          'imagen': _product.imagenes.isNotEmpty ? _product.imagenes.first : '',
          'id_producto': _product.id,
          'id_vendedor': _product.idVendedor,
          'talla': _selectedSize,
          'color': _selectedColor,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Producto agregado al carrito correctamente.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agregar al carrito: $e'),
        ),
      );
    }
  }

  Future<void> _agregarComentario() async {
    if (_comentarioCtrl.text.trim().isEmpty || _valoracionNueva == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un comentario y da una valoración.')),
      );
      return;
    }
    final comentario = {
      'usuario': _nombreUsuario ?? 'Usuario',
      'comentario': _comentarioCtrl.text.trim(),
      'valoracion': _valoracionNueva,
      'fecha': Timestamp.now(),
      'userId': FirebaseAuth.instance.currentUser?.uid,
    };
    final productRef = FirebaseFirestore.instance
        .collection('producto')
        .doc(_product.id);

    await productRef.collection('comentarios').add(comentario);

    // Actualizar valoración promedio
    final comentariosSnapshot = await productRef.collection('comentarios').get();
    double sumaValoraciones = 0;
    int totalComentarios = comentariosSnapshot.docs.length;
    for (var doc in comentariosSnapshot.docs) {
      sumaValoraciones += (doc.data()['valoracion'] as num).toDouble();
    }
    double nuevaValoracionPromedio = totalComentarios > 0
        ? sumaValoraciones / totalComentarios
        : 0.0;
    await productRef.update({
      'valoracion': nuevaValoracionPromedio,
      'valoracionesTotal': totalComentarios,
    });

    _comentarioCtrl.clear();
    setState(() {
      _valoracionNueva = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comentario agregado correctamente.')),
    );
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = _product.precio * (1 - _product.descuento / 100);

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Image.network(
                  _product.imagenes.first,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 12,
                  child: const BackButton(color: Colors.black),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 12,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      if (!AuthService.isUserLoggedIn()) return;
                      if (isFavorite) {
                        await _favoriteService.removeFavorite(_product.id);
                      } else {
                        await _favoriteService.addFavorite(_product.id);
                      }
                      setState(() => isFavorite = !isFavorite);
                    },
                  ),
                ),
                DraggableScrollableSheet(
                  initialChildSize: 0.55,
                  maxChildSize: 0.95,
                  minChildSize: 0.55,
                  builder: (_, controller) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                    ),
                    child: ListView(
                      controller: controller,
                      children: [
                        Text(
                          _product.categoria,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _product.nombre,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'S/ ${price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Antes: S/ ${_product.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < _product.valoracion.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('(${_product.valoracionesTotal})'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _product.descripcion,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        if (_product.tallas.isNotEmpty) ...[
                          const Text('Talla', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: _product.tallas.map((size) {
                              return ChoiceChip(
                                label: Text(size),
                                selected: _selectedSize == size,
                                onSelected: (_) => setState(() => _selectedSize = size),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        if (_product.colores.isNotEmpty) ...[
                          const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            children: _product.colores.map((color) {
                              return ChoiceChip(
                                label: Text(color),
                                selected: _selectedColor == color,
                                onSelected: (_) => setState(() => _selectedColor = color),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Row(
                          children: [
                            const Text('Cantidad:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                            ),
                            Text('$_quantity', style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _comprarAhora,
                            child: const Text(
                              'Comprar ahora',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // ----------- SECCIÓN DE COMENTARIOS -----------------
                        const Text(
                          'Comentarios',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        if (!_usuarioCargado)
                          const Center(child: CircularProgressIndicator())
                        else if (_nombreUsuario == null)
                          const Text(
                            'Debes iniciar sesión para comentar.',
                            style: TextStyle(color: Colors.grey),
                          )
                        else ...[
                          const Text('Tu valoración:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: List.generate(
                              5,
                              (i) => IconButton(
                                icon: Icon(
                                  i < _valoracionNueva ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _valoracionNueva = i + 1;
                                  });
                                },
                              ),
                            ),
                          ),
                          TextField(
                            controller: _comentarioCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Escribe tu comentario...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                              onPressed: _agregarComentario,
                              child: const Text('Enviar comentario', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // ----------- LISTA DE COMENTARIOS -------------
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('producto')
                              .doc(_product.id)
                              .collection('comentarios')
                              .orderBy('fecha', descending: true)
                              .get()
                              .then((snapshot) => snapshot.docs.map((doc) => doc.data()).toList()),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final comentarios = snapshot.data ?? [];
                            if (comentarios.isEmpty) {
                              return const Text(
                                'Aún no hay comentarios. ¡Sé el primero!',
                                style: TextStyle(color: Colors.grey),
                              );
                            }
                            return Column(
                              children: comentarios.map((comentario) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            i < (comentario['valoracion'] ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comentario['usuario'] ?? 'Anónimo',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(comentario['comentario'] ?? ''),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
