import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroPagoScreen extends StatefulWidget {
  const RegistroPagoScreen({super.key});

  @override
  State<RegistroPagoScreen> createState() => _RegistroPagoScreenState();
}

class _RegistroPagoScreenState extends State<RegistroPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mercadoPagoEmailController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _mercadoPagoEmailController.dispose();
    super.dispose();
  }

  Future<void> _registrarMetodoPago() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("Usuario no autenticado.");
      }

      // Guardar los datos reales en Firestore
      await FirebaseFirestore.instance.collection('usuario').doc(user.uid).set({
        'metodoPagoRegistrado': true,
        'correoMercadoPago': _mercadoPagoEmailController.text.trim(),
      }, SetOptions(merge: true)); // merge para no sobrescribir todo

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Método de pago registrado con éxito')),
      );

      Navigator.pop(context, true); // Devuelve true si lo necesitas
    } catch (e) {
      print("❌ Error al registrar método de pago: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Método de Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Ingresa tu correo vinculado a Mercado Pago',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mercadoPagoEmailController,
                decoration: const InputDecoration(
                  labelText: 'Correo de Mercado Pago',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (!RegExp(
                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                    onPressed: _registrarMetodoPago,
                    icon: const Icon(Icons.save),
                    label: const Text('Registrar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
