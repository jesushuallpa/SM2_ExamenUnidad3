import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_moviles_2/screens/AdminDashboardScreen.dart';
import 'package:proyecto_moviles_2/screens/RecoverPasswordScreen.dart';
import 'package:proyecto_moviles_2/screens/RegisterScreen.dart';
import '../services/AuthService.dart';
import 'main_screen.dart';
import 'package:proyecto_moviles_2/screens/AdminHomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _showPassword = false;

  final Color primaryColor = const Color(0xFF4E2500);
  final Color textColor = const Color(0xFF3E1F00);

  Future<String?> _obtenerRol(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('usuario').doc(uid).get();
      return doc.data()?['rol'];
    } catch (e) {
      print('❌ Error al obtener rol: $e');
      return null;
    }
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = AuthService();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text.trim());

    if (ok) {
      final uid = AuthService.currentUser?.uid;
      final rol = await _obtenerRol(uid!);
      if (rol == 'administrador') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminHomePage()));
      } else if (rol == 'vendedor') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales incorrectas')),
      );
    }

    setState(() => _loading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor, fontFamily: 'Georgia'),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 260,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/modelo.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Georgia',
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: _inputDecoration('Correo electrónico'),
                        validator: (v) => v == null || !v.contains('@') ? 'Correo inválido' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: !_showPassword,
                        decoration: _inputDecoration('Contraseña').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility : Icons.visibility_off,
                              color: textColor,
                            ),
                            onPressed: () {
                              setState(() => _showPassword = !_showPassword);
                            },
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 26),
                      _loading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: _onLogin,
                                child: const Text(
                                  'Ingresar',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Georgia'),
                                ),
                              ),
                            ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecoverPasswordScreen()));
                        },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(color: textColor, fontFamily: 'Georgia', fontSize: 15),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿No tienes cuenta? ',
                            style: TextStyle(color: textColor, fontFamily: 'Georgia', fontSize: 15),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                            child: Text(
                              'Regístrate',
                              style: TextStyle(color: primaryColor, fontFamily: 'Georgia', fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                        },
                        child: Text(
                          '¿Continuar como invitado?',
                          style: TextStyle(color: primaryColor, fontFamily: 'Georgia', fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}