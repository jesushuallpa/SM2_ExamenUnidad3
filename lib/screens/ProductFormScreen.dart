// product_form_screen.dart (Solo la parte relevante de _guardarProducto)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/product.dart';
import '../services/AuthService.dart'; // <-- IMPORTA TU AUTHSERVICE

class ProductFormScreen extends StatefulWidget {
  final Product? productoExistente;

  const ProductFormScreen({super.key, this.productoExistente});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _descuentoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _descripcionTallasController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _stockController = TextEditingController();

  late String estadoSeleccionado;
  final List<String> estados = ['disponible', 'no disponible', 'inactivo'];

  List<String> colores = [];
  List<String> tallas = [];
  List<String> imagenes = [];

  final _nuevoColorController = TextEditingController();
  final _nuevaTallaController = TextEditingController();
  final _nuevaImagenController = TextEditingController();

  Map<String, String> colorImagenes = {}; // Color → URL de imagen

  @override
  void initState() {
    super.initState();
    cargarCategoriasDesdeFirebase();
    final p = widget.productoExistente;
    if (p != null) {
      _nombreController.text = p.nombre;
      _precioController.text = p.precio.toString();
      _descuentoController.text = p.descuento.toString();
      _descripcionController.text = p.descripcion;
      _descripcionTallasController.text = p.descripcionTallas;
      _categoriaController.text = p.categoria;
      _stockController.text = p.stock.toString();
      estadoSeleccionado = p.estado;
      colores = List.from(p.colores);
      tallas = List.from(p.tallas);
      imagenes = List.from(p.imagenes);
      colorImagenes = Map.from(
        p.colorImagenes,
      ); // Carga también las imágenes por color
    } else {
      estadoSeleccionado = 'disponible';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descuentoController.dispose();
    _descripcionController.dispose();
    _descripcionTallasController.dispose();
    _categoriaController.dispose();
    _stockController.dispose();
    _nuevoColorController.dispose();
    _nuevaTallaController.dispose();
    _nuevaImagenController.dispose();
    super.dispose();
  }

  List<String> coloresDisponibles = [];

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Colores personalizados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              colores.map((color) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(color),
                          onDeleted: () {
                            setState(() {
                              colores.remove(color);
                              colorImagenes.remove(
                                color,
                              ); // quita imagen también
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.image, size: 20),
                          tooltip: 'Subir imagen para $color',
                          onPressed: () => _subirImagenPorColor(color),
                        ),
                      ],
                    ),
                    if (colorImagenes[color] != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            colorImagenes[color]!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Image.asset(
                                  'assets/images/placeholder.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nuevoColorController,
          decoration: const InputDecoration(
            labelText: 'Agregar color',
            border: OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) async {
            final nuevo = value.trim();
            if (nuevo.isNotEmpty && !colores.contains(nuevo)) {
              setState(() {
                colores.add(nuevo);
                _nuevoColorController.clear();
              });

              await FirebaseFirestore.instance
                  .collection('color')
                  .doc('nombre')
                  .set({
                    'nombre': FieldValue.arrayUnion([nuevo]),
                  }, SetOptions(merge: true));
            }
          },
        ),
      ],
    );
  }

  Future<void> _subirImagenPorColor(String color) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final url = await subirImagenACloudinary(File(pickedFile.path));
      if (url != null) {
        setState(() {
          colorImagenes[color] = url;
        });
      }
    }
  }

  Map<String, List<String>> categorias = {};
  List<String> opcionesCategoria = [];
  Future<void> cargarCategoriasDesdeFirebase() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('categoria').get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();

      final List<String> todas = [];
      data.forEach((key, value) {
        if (value is List) {
          categorias[key] = List<String>.from(value);
          todas.addAll(List<String>.from(value));
        }
      });

      setState(() {
        opcionesCategoria = todas.toSet().toList(); // Elimina duplicados
      });
    }
  }

  Future<String?> subirImagenACloudinary(File imageFile) async {
    const cloudName = 'dsi6s05zf';
    const uploadPreset = 'productos_preset';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['secure_url'];
    } else {
      print('Error al subir: ${response.statusCode}');
      print('Error al subir la imagen');
      return null;
    }
  }

  Future<void> _subirImagenDesdeGaleria() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (final pickedFile in pickedFiles) {
        final File file = File(pickedFile.path);
        final url = await subirImagenACloudinary(file);
        if (url != null) {
          setState(() => imagenes.add(url));
        }
      }
    }
  }

  void _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.productoExistente?.id ?? const Uuid().v4();
    final currentUserId =
        AuthService.currentUser?.uid; // <-- OBTIENE EL ID DEL VENDEDOR LOGUEADO

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: No hay vendedor logueado para guardar el producto.',
          ),
        ),
      );
      return;
    }

    final nuevo = Product(
      id: id,
      nombre: _nombreController.text.trim(),
      precio: double.parse(_precioController.text),
      descuento: int.parse(_descuentoController.text),
      descripcion: _descripcionController.text.trim(),
      valoracion: widget.productoExistente?.valoracion ?? 0,
      valoracionesTotal: widget.productoExistente?.valoracionesTotal ?? 0,
      vendidos: widget.productoExistente?.vendidos ?? 0,
      imagenes: imagenes,
      colores: colores,
      colorImagenes: colorImagenes,
      tallas: tallas,
      descripcionTallas: _descripcionTallasController.text.trim(),
      comentarios: widget.productoExistente?.comentarios ?? [],
      categoria: _categoriaController.text.trim(),
      estado: estadoSeleccionado,
      stock: int.parse(_stockController.text),
      idVendedor: currentUserId, // <-- ASIGNA EL ID DEL VENDEDOR
    );

    try {
      await FirebaseFirestore.instance
          .collection('producto')
          .doc(id)
          .set(nuevo.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productoExistente == null
                ? 'Producto agregado correctamente'
                : 'Producto actualizado',
          ),
        ),
      );

      Navigator.pop(context, nuevo);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productoExistente == null
              ? 'Nuevo Producto'
              : 'Editar Producto',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Nombre', _nombreController),
                _buildTextField('Precio', _precioController, isNumeric: true),
                _buildTextField(
                  'Descuento (%)',
                  _descuentoController,
                  isNumeric: true,
                ),
                _buildTextField(
                  'Descripción',
                  _descripcionController,
                  maxLines: 3,
                ),
                _buildTextField(
                  'Descripción Tallas',
                  _descripcionTallasController,
                ),
                DropdownButtonFormField<String>(
                  value:
                      _categoriaController.text.isNotEmpty
                          ? _categoriaController.text
                          : null,
                  items:
                      opcionesCategoria
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      _categoriaController.text = val ?? '';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (val) =>
                          val == null || val.isEmpty
                              ? 'Seleccione una categoría'
                              : null,
                ),
                _buildTextField('Stock', _stockController, isNumeric: true),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: estadoSeleccionado,
                  items:
                      estados
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => estadoSeleccionado = val!),
                  decoration: const InputDecoration(
                    labelText: 'Estado del producto',
                  ),
                ),
                const SizedBox(height: 20),
                _buildColorSelector(),
                _buildChipInput('Tallas', tallas, _nuevaTallaController),
                _buildImagePreviewSection(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Subir desde galería'),
                  onPressed: _subirImagenDesdeGaleria,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (imagenes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debe subir al menos una imagen'),
                        ),
                      );
                      return;
                    }
                    _guardarProducto();
                  },
                  child: Text(
                    widget.productoExistente == null
                        ? 'Agregar'
                        : 'Guardar cambios',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imágenes del producto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              imagenes.map((url) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Image.asset(
                              'assets/images/placeholder.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => setState(() => imagenes.remove(url)),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator:
            (value) =>
                value == null || value.trim().isEmpty
                    ? 'Campo obligatorio'
                    : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildChipInput(
    String label,
    List<String> lista,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children:
              lista.map((item) {
                return Chip(
                  label: Text(item),
                  onDeleted: () {
                    setState(() {
                      lista.remove(item);
                    });
                  },
                );
              }).toList(),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Agregar $label',
            border: const OutlineInputBorder(),
          ),
          onFieldSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              setState(() {
                lista.add(value.trim());
                controller.clear();
              });
            }
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
