// Mantiene la lógica original, pero con mejoras visuales y validaciones simples

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('usuario').get();

    setState(() {
      usuarios =
          snapshot.docs
              .where((doc) => doc.data()['activo'] != false)
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
    });
  }

  void _mostrarFormulario({Map<String, dynamic>? usuario}) async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _FormularioUsuarioDialog(usuario: usuario),
    );

    if (resultado != null) {
      final ref = FirebaseFirestore.instance.collection('usuario');

      if (resultado['id'] == null) {
        await ref.add({...resultado, 'activo': true});
      } else {
        final id = resultado['id'];
        resultado.remove('id');
        await ref.doc(id).update(resultado);
      }

      await _cargarUsuarios();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuario == null
                ? 'Usuario agregado correctamente'
                : 'Usuario actualizado',
          ),
        ),
      );
    }
  }

  void _marcarComoInactivo(String id) async {
    await FirebaseFirestore.instance.collection('usuario').doc(id).update({
      'activo': false,
    });
    await _cargarUsuarios();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario marcado como inactivo')),
    );
  }

  void _confirmarInactivar(String id) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Inactivar Usuario'),
            content: const Text(
              '¿Estás seguro de marcar este usuario como inactivo?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _marcarComoInactivo(id);
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => _mostrarFormulario(),
            icon: const Icon(Icons.person_add),
            label: const Text('Agregar'),
          ),
        ],
      ),
      body:
          usuarios.isEmpty
              ? const Center(child: Text('No hay usuarios activos.'))
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: usuarios.length,
                itemBuilder: (_, i) {
                  final u = usuarios[i];
                  final nombre = u['nombre'] ?? 'Sin nombre';
                  final correo = u['usuario'] ?? '';
                  final telefono = u['telefono'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(nombre[0].toUpperCase()),
                      ),
                      title: Text(nombre, style: const TextStyle(fontSize: 18)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Email: $correo'),
                          Text('Teléfono: $telefono'),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _mostrarFormulario(usuario: u),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmarInactivar(u['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class _FormularioUsuarioDialog extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  const _FormularioUsuarioDialog({this.usuario});

  @override
  State<_FormularioUsuarioDialog> createState() =>
      _FormularioUsuarioDialogState();
}

class _FormularioUsuarioDialogState extends State<_FormularioUsuarioDialog> {
  late TextEditingController nombreController;
  late TextEditingController emailController;
  late TextEditingController telefonoController;
  late TextEditingController contrasenaController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.usuario?['nombre']);
    emailController = TextEditingController(text: widget.usuario?['usuario']);
    telefonoController = TextEditingController(
      text: widget.usuario?['telefono']?.toString() ?? '',
    );
    contrasenaController = TextEditingController(
      text: widget.usuario?['contrasena'] ?? '',
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (nombreController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        contrasenaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre, email y contraseña son obligatorios'),
        ),
      );
      return;
    }

    final data = {
      'id': widget.usuario?['id'],
      'nombre': nombreController.text.trim(),
      'usuario': emailController.text.trim(),
      'telefono': int.tryParse(telefonoController.text.trim()) ?? 0,
      'contrasena': contrasenaController.text.trim(),
    };
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.usuario == null ? 'Agregar Usuario' : 'Editar Usuario',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInputField('Nombre', nombreController, Icons.person),
            _buildInputField('Email', emailController, Icons.email),
            _buildInputField(
              'Teléfono',
              telefonoController,
              Icons.phone,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              'Contraseña',
              contrasenaController,
              Icons.lock,
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
