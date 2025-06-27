import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_moviles_2/screens/mercado_pago_webview.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
import 'package:url_launcher/url_launcher.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLogged = AuthService.isUserLoggedIn();
    final uid = AuthService.currentUser?.uid;

    if (!isLogged || uid == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '🔒 Inicia sesión para ver tu carrito de compras',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('🛒 Carrito de Compras')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('carrito')
                  .doc(uid)
                  .collection('items')
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('🛒 Tu carrito está vacío.'));
            }

            final items = snapshot.data!.docs;

            final total = items.fold<double>(0, (sum, item) {
              final precio = (item['precio'] ?? 0) as num;
              final cantidad = (item['cantidad'] ?? 1) as num;
              return sum + (precio * cantidad);
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final producto = items[index];
                      final data = producto.data() as Map<String, dynamic>;

                      final precio = (data['precio'] ?? 0) as num;
                      final cantidad = (data['cantidad'] ?? 1) as num;
                      final subtotal = precio * cantidad;

                      return ListTile(
                        leading:
                            (data['imagen'] != null && data['imagen'] != '')
                                ? Image.network(
                                  data['imagen'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                : const Icon(Icons.image_not_supported),
                        title: Text(data['nombre'] ?? 'Producto'),
                        subtitle: Text('Cantidad: $cantidad'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'S/ ${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Quitar del carrito',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text(
                                          '¿Eliminar producto?',
                                        ),
                                        content: Text(
                                          '¿Deseas quitar "${data['nombre']}" del carrito?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('carrito')
                                      .doc(uid)
                                      .collection('items')
                                      .doc(producto.id)
                                      .delete();
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: S/ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final itemsByVendedor =
                        <String, List<Map<String, dynamic>>>{};

                    for (var doc in items) {
                      final data = doc.data() as Map<String, dynamic>;
                      final vendedorId = data['id_vendedor'];
                      if (vendedorId == null) continue;

                      itemsByVendedor.putIfAbsent(vendedorId, () => []);
                      itemsByVendedor[vendedorId]!.add({
                        "title": data['nombre'],
                        "quantity": data['cantidad'],
                        "unit_price": (data['precio'] as num).toDouble(),
                      });
                    }

                    for (var entry in itemsByVendedor.entries) {
                      final vendedorId = entry.key;
                      final productos = entry.value;

                      final uri = Uri.parse(
                        'https://mercadopago-nx0i.onrender.com/create_preference',
                      );

                      try {
                        final response = await http.post(
                          uri,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode({
                            "vendedorId": vendedorId,
                            "items": productos,
                          }),
                        );

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          final initPoint = data['init_point'];

                          print('✅ init_point recibido: $initPoint');

                          if (initPoint == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ init_point vacío'),
                              ),
                            );
                            continue;
                          }

                          final url = Uri.parse(initPoint);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      MercadoPagoWebView(url: initPoint),
                            ),
                          );
                        } else {
                          print('❌ Error del servidor: ${response.body}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al crear preferencia'),
                            ),
                          );
                        }
                      } catch (e) {
                        print('❌ Error: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error de conexión al servidor'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('Finalizar compra'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
