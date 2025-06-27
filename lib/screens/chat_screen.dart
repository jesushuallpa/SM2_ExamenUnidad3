import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart'; // Asegúrate que esté bien referenciado
import 'package:proyecto_moviles_2/screens/product_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  Future<List<Product>> _obtenerProductos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('producto').get();
    return snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList();
  }

  String _generarResumenProductos(List<Product> productos) {
    return productos
        .take(5)
        .map((p) {
          return "producto: ${p.nombre}, categoria: ${p.categoria}, precio: ${p.precio} soles, descuento: ${p.descuento}%, tallas: ${p.tallas.join(', ')}, colores: ${p.colores.join(', ')}";
        })
        .join("\n");
  }

  Future<String> _getGeminiResponse(String prompt) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      try {
        return data['candidates'][0]['content']['parts'][0]['text'];
      } catch (_) {
        return "❌ No se pudo obtener respuesta.";
      }
    } else {
      print("Error Gemini: ${response.statusCode} → ${response.body}");
      return "❌ Error al contactar a Gemini.";
    }
  }

  Future<String> _obtenerRecomendacion(String userPrompt) async {
    final productos = await _obtenerProductos();
    final resumen = _generarResumenProductos(productos);

    final mensajeCompleto = """
    Usuario: $userPrompt

    Aquí tienes los productos disponibles:
    $resumen

    Con base en estos productos, ¿cuál recomendarías?
    """;

    return await _getGeminiResponse(mensajeCompleto);
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, {'sender': 'user', 'text': text});
      _controller.clear();
    });

    final productos = await _obtenerProductos();
    final resumen = _generarResumenProductos(productos);

    final mensajeCompleto = """
  Usuario: $text

  Aquí tienes los productos disponibles:
  $resumen

  Con base en estos productos, ¿cuál recomendarías? Solo menciona el nombre del producto.
  """;

    final respuesta = await _getGeminiResponse(mensajeCompleto);

    // Buscar productos mencionados en la respuesta
    final recomendados =
        productos
            .where(
              (p) => respuesta.toLowerCase().contains(p.nombre.toLowerCase()),
            )
            .toList();

    setState(() {
      _messages.insert(0, {
        'sender': 'gemini',
        'text': respuesta,
        'productos': recomendados,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Ropa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final productos =
                  await _obtenerProductos(); // Usas el método correcto
              final resumen = _generarResumenProductos(productos);
              print("📦 Producto:\n$resumen");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final sender = message['sender'];
                final text = message['text'] ?? '';
                final productos = message['productos'] as List<Product>?;

                return Column(
                  crossAxisAlignment:
                      sender == 'user'
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              sender == 'user'
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(text),
                      ),
                    ),
                    if (productos != null)
                      ...productos.map(
                        (product) => ListTile(
                          title: Text(product.nombre),
                          subtitle: Text('Precio: S/ ${product.precio}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/detalle_producto',
                              arguments: product,
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
