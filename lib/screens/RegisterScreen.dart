import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/screens/AdminDashboardScreen.dart';
import 'package:proyecto_moviles_2/screens/preference_onboarding_screen.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedRol = 'cliente';
  bool _loading = false;

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = AuthService();
    final ok = await auth.register(
      _emailCtrl.text.trim(),
      _passCtrl.text.trim(),
      _selectedRol,
      _nombreCtrl.text.trim(),
      _telefonoCtrl.text.trim(),
    );

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro exitoso')),
      );
      if (_selectedRol == 'vendedor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PreferenceOnboardingScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo registrar el usuario')),
      );
    }

    setState(() => _loading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF4B1E0E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF4B1E0E)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Crear una cuenta',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B1E0E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Completa la información para registrarte',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B1E0E),
                  ),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _nombreCtrl,
                  decoration: _inputDecoration('Nombre completo'),
                  validator: (v) => v == null || v.isEmpty ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoCtrl,
                  decoration: _inputDecoration('Número de teléfono'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.length < 9 ? 'Número inválido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: _inputDecoration('Correo electrónico'),
                  validator: (v) => v == null || !v.contains('@') ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: _inputDecoration('Contraseña'),
                  validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedRol,
                  decoration: _inputDecoration('Tipo de usuario'),
                  borderRadius: BorderRadius.circular(30),
                  items: const [
                    DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                    DropdownMenuItem(value: 'vendedor', child: Text('Vendedor')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRol = value!;
                    });
                  },
                ),
                const SizedBox(height: 30),

                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B1E0E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: _onRegister,
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
