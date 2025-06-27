// models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nombre;
  final double precio;
  final int descuento;
  final String descripcion;
  final double valoracion;
  final int valoracionesTotal;
  final int vendidos;
  final List<String> imagenes; // máx. 7 imágenes locales
  final List<String> colores;
  final Map<String, String> colorImagenes; // ← nuevo campo
  final List<String> tallas;
  final String descripcionTallas;
  final List<Map<String, dynamic>> comentarios;
  final String estado;
  final int stock;
  final String categoria;
  final String? idVendedor; // <--- ¡NUEVO CAMPO AQUÍ!

  Product({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.descuento,
    required this.descripcion,
    required this.valoracion,
    required this.valoracionesTotal,
    required this.vendidos,
    required this.imagenes,
    required this.colores,
    required this.colorImagenes,
    required this.tallas,
    required this.descripcionTallas,
    required this.comentarios,
    required this.categoria,
    required this.estado,
    required this.stock,
    this.idVendedor, // <--- ¡Añadido al constructor! Lo hacemos opcional para flexibilidad.
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      nombre: data['nombre'] ?? '',
      precio: (data['precio'] ?? 0).toDouble(),
      descuento: data['descuento'] ?? 0,
      descripcion: data['descripcion'] ?? '',
      valoracion: (data['valoracion'] ?? 0).toDouble(),
      valoracionesTotal: data['valoraciones_total'] ?? 0,
      vendidos: data['vendidos'] ?? 0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      colores: List<String>.from(data['colores'] ?? []),
      colorImagenes: Map<String, String>.from(data['colorImagenes'] ?? {}),
      tallas: List<String>.from(data['tallas'] ?? []),
      descripcionTallas: data['descripcion_tallas'] ?? '',
      comentarios: List<Map<String, dynamic>>.from(data['comentarios'] ?? []),
      categoria: data['categoria'] ?? 'Sin categoría',
      estado: data['estado'] ?? 'disponible',
      stock: data['stock'] ?? 0,
      idVendedor: data['idVendedor'], // <--- ¡Mapea desde Firestore!
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'nombre': nombre,
      'precio': precio,
      'descuento': descuento,
      'descripcion': descripcion,
      'valoracion': valoracion,
      'valoraciones_total': valoracionesTotal,
      'vendidos': vendidos,
      'imagenes': imagenes,
      'colores': colores,
      'colorImagenes': colorImagenes,
      'tallas': tallas,
      'descripcion_tallas': descripcionTallas,
      'comentarios': comentarios,
      'categoria': categoria,
      'estado': estado,
      'stock': stock,
      // Se añade 'idVendedor' al mapa solo si no es nulo
      // Esto es útil si tienes datos antiguos que no tienen este campo
      // y no quieres que se guarde un "null" explícito si no es necesario.
      // Sin embargo, para este caso, siempre lo querrás guardar.
      // Así que lo simplificamos a que siempre se incluya.
      'idVendedor': idVendedor, // <--- ¡Exporta a Firestore!
    };
    return map;
  }
  Product copyWith({
    String? id,
    String? nombre,
    double? precio,
    int? descuento,
    String? descripcion,
    double? valoracion,
    int? valoracionesTotal,
    int? vendidos,
    List<String>? imagenes,
    List<String>? colores,
    Map<String, String>? colorImagenes,
    List<String>? tallas,
    String? descripcionTallas,
    List<Map<String, dynamic>>? comentarios,
    String? estado,
    int? stock,
    String? categoria,
    String? idVendedor,
  }) {
    return Product(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      descuento: descuento ?? this.descuento,
      descripcion: descripcion ?? this.descripcion,
      valoracion: valoracion ?? this.valoracion,
      valoracionesTotal: valoracionesTotal ?? this.valoracionesTotal,
      vendidos: vendidos ?? this.vendidos,
      imagenes: imagenes ?? this.imagenes,
      colores: colores ?? this.colores,
      colorImagenes: colorImagenes ?? this.colorImagenes,
      tallas: tallas ?? this.tallas,
      descripcionTallas: descripcionTallas ?? this.descripcionTallas,
      comentarios: comentarios ?? this.comentarios,
      estado: estado ?? this.estado,
      stock: stock ?? this.stock,
      categoria: categoria ?? this.categoria,
      idVendedor: idVendedor ?? this.idVendedor,
    );
  }
   // **** MÉTODO fromFirestore: AGREGADO ****
  factory Product.fromFirestore(DocumentSnapshot doc) {
    // Convierte el DocumentSnapshot a un Map y luego usa tu fromMap existente.
    // Esto asegura que la lógica de mapeo se mantiene en un solo lugar.
    return Product.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }


}
