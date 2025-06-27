import 'package:flutter/material.dart';

class DudasProductos extends StatefulWidget {
  const DudasProductos({super.key});

  @override
  State<DudasProductos> createState() => _DudasProductosState();
}

class _DudasProductosState extends State<DudasProductos> {
  final TextEditingController _controller = TextEditingController();
  final List<_MensajeChat> _mensajes = [];

  void _enviarMensaje() {
    final textoUsuario = _controller.text.trim();
    if (textoUsuario.isEmpty) return;

    setState(() {
      _mensajes.add(_MensajeChat(textoUsuario, true));
      _mensajes.add(
        _MensajeChat(
          "Gracias por tu mensaje. Un asesor se comunicará pronto contigo 😊",
          false,
        ),
      );
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Centro de Ayuda')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = _mensajes[index];
                return Align(
                  alignment:
                      mensaje.esUsuario
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          mensaje.esUsuario
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(mensaje.texto),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu duda...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MensajeChat {
  final String texto;
  final bool esUsuario;

  _MensajeChat(this.texto, this.esUsuario);
}
