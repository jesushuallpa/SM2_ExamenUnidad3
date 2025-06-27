// lib/services/favorites_service.dart
import 'package:flutter/foundation.dart';

class FavoritesService {
  /// Notifica cada vez que cambie el set de favoritos.
  static final ValueNotifier<Set<String>> favorites = ValueNotifier({});

  /// ¿Es favorito el producto [id]?
  static bool isFavorite(String id) => favorites.value.contains(id);

  /// Alterna el estado de favorito para [id].
  static void toggleFavorite(String id) {
    final current = Set<String>.from(favorites.value);
    if (current.contains(id)) current.remove(id);
    else current.add(id);
    favorites.value = current;
  }
}
