// services/FavoriteService.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart'; // Asegúrate que esta ruta sea correcta

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ELIMINA ESTA LÍNEA: final AuthService _authService = AuthService();

  // Obtiene la referencia a la subcolección de favoritos del usuario actual
  CollectionReference? _getFavoritesCollection() {
    // Usa AuthService.currentUser?.uid directamente
    final userId = AuthService.currentUser?.uid;
    if (userId != null) {
      return _firestore
          .collection('usuario')
          .doc(userId)
          .collection('favoritos');
    }
    return null;
  }

  // Añadir un producto a favoritos
  Future<void> addFavorite(String productId) async {
    final favoritesCollection = _getFavoritesCollection();
    if (favoritesCollection != null) {
      await favoritesCollection.doc(productId).set({
        'added_at': FieldValue.serverTimestamp(),
      });
      print('Producto $productId agregado a favoritos.');
    } else {
      print('Error: Usuario no logueado para añadir favorito.');
    }
  }

  // Quitar un producto de favoritos
  Future<void> removeFavorite(String productId) async {
    final favoritesCollection = _getFavoritesCollection();
    if (favoritesCollection != null) {
      await favoritesCollection.doc(productId).delete();
      print('Producto $productId removido de favoritos.');
    } else {
      print('Error: Usuario no logueado para remover favorito.');
    }
  }

  // Verificar si un producto es favorito
  Future<bool> isFavorite(String productId) async {
    final favoritesCollection = _getFavoritesCollection();
    if (favoritesCollection != null) {
      final doc = await favoritesCollection.doc(productId).get();
      return doc.exists;
    }
    return false; // No es favorito si no hay usuario logueado o si la colección es null
  }

  // Obtener la lista de IDs de productos favoritos para el usuario actual
  Future<List<String>> getFavoriteProductIds() async {
    final favoritesCollection = _getFavoritesCollection();
    if (favoritesCollection != null) {
      final querySnapshot = await favoritesCollection.get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    }
    return [];
  }
}
