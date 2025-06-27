// services/PreferenceService.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart'; // Asegúrate que esta ruta sea correcta

class PreferenceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // NO necesitas instanciar AuthService() aquí.
  // final AuthService _authService = AuthService(); // <-- ELIMINA ESTA LÍNEA

  // Obtiene la referencia al documento del usuario actual
  DocumentReference? _getUserDocumentRef() {
    final userId =
        AuthService.currentUser?.uid; // Usa el método estático directamente
    if (userId != null) {
      return _firestore.collection('usuario').doc(userId);
    }
    return null;
  }

  // Leer las preferencias del usuario
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final userDocRef = _getUserDocumentRef();
    if (userDocRef != null) {
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        return userData['preferencias'] as Map<String, dynamic>?;
      }
    }
    return null;
  }

  // Actualizar las preferencias del usuario
  Future<void> updatePreferences(Map<String, dynamic> newPreferences) async {
    final userDocRef = _getUserDocumentRef();
    if (userDocRef != null) {
      await userDocRef.set({
        'preferencias': newPreferences,
      }, SetOptions(merge: true));
      print('Preferencias actualizadas con éxito.');
    } else {
      print('Error: Usuario no logueado para actualizar preferencias.');
    }
  }
}
