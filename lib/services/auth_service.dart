import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static String? _userId; // Guardamos el ID

  static Future<bool> signIn(String email, String password) async {
    try {
      final usuarios = FirebaseFirestore.instance.collection('usuario');

      final resultado =
          await usuarios
              .where('usuario', isEqualTo: email)
              .where('contrasena', isEqualTo: password)
              .get();

      if (resultado.docs.isNotEmpty) {
        _userId = resultado.docs.first.id;
        return true;
      }
      return false;
    } catch (e) {
      print('Error al autenticar: $e');
      return false;
    }
  }

  static bool isUserLoggedIn() {
    return _userId != null;
  }

  static String? get userId => _userId;

  static void logout() {
    _userId = null;
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    if (_userId == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('usuario')
            .doc(_userId)
            .get();

    return doc.data();
  }
}
