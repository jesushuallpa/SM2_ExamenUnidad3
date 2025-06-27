// category_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'catalog_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Map<String, List<String>> categoriasPorGrupo = {};
  String? tipoSeleccionado;
  bool _loading = true;

  // Datos de ejemplo para las categorías principales con iconos
  final List<Map<String, dynamic>> categoriasMainData = [
    {
      'title': 'Women\'s Fashion',
      'icon': Icons.woman,
      'gradient': [Color(0xFFE91E63), Color(0xFFAD1457)],
      'lightColor': Color(0xFFFCE4EC),
    },
    {
      'title': 'Men\'s Fashion',
      'icon': Icons.man,
      'gradient': [Color(0xFF2196F3), Color(0xFF1565C0)],
      'lightColor': Color(0xFFE3F2FD),
    },
    {
      'title': 'Kids Fashion',
      'icon': Icons.child_friendly,
      'gradient': [Color(0xFF4CAF50), Color(0xFF2E7D32)],
      'lightColor': Color(0xFFE8F5E8),
    },
    {
      'title': 'Accessories',
      'icon': Icons.watch,
      'gradient': [Color(0xFFFF9800), Color(0xFFE65100)],
      'lightColor': Color(0xFFFFF3E0),
    },
  ];

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('categoria').get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final Map<String, List<String>> temp = {};
        data.forEach((key, value) {
          if (value is List) temp[key] = List<String>.from(value);
        });
        setState(() {
          categoriasPorGrupo = temp;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          tipoSeleccionado == null ? 'Categorías' : tipoSeleccionado!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: tipoSeleccionado != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => setState(() => tipoSeleccionado = null),
              )
            : null,
      ),
      body: tipoSeleccionado == null ? _buildMainCategories() : _buildSubCategories(),
    );
  }

  Widget _buildMainCategories() {
    final tipos = categoriasPorGrupo.keys.toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: tipos.asMap().entries.map((entry) {
          int index = entry.key;
          String tipo = entry.value;
          
          // Usar datos de ejemplo si están disponibles, sino usar gradiente por defecto
          final categoryData = index < categoriasMainData.length 
              ? categoriasMainData[index] 
              : {
                  'title': tipo,
                  'icon': Icons.category,
                  'gradient': [Colors.purple[400]!, Colors.purple[600]!],
                  'lightColor': Colors.purple[50]!,
                };

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildCategoryCard(
              title: tipo,
              icon: categoryData['icon'],
              gradient: categoryData['gradient'],
              lightColor: categoryData['lightColor'],
              onTap: () => setState(() => tipoSeleccionado = tipo),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    IconData? icon,
    required List<Color> gradient,
    Color? lightColor,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: Stack(
              children: [
                // Patrón decorativo de fondo
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                
                // Contenido principal
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Icono
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon ?? Icons.category,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Título
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Explorar categoría',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Flecha
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategories() {
    final subcategorias = categoriasPorGrupo[tipoSeleccionado] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selecciona una subcategoría',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: subcategorias.length,
            itemBuilder: (context, index) {
              final subcategoria = subcategorias[index];
              return _buildSubCategoryCard(
                title: subcategoria,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CatalogScreen(
                        categoriaPreseleccionada: subcategoria,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard({
    required String title,
    required VoidCallback onTap,
  }) {
    // Colores aleatorios para subcategorías
    final colors = [
      [Color(0xFF667eea), Color(0xFF764ba2)],
      [Color(0xFFf093fb), Color(0xFFf5576c)],
      [Color(0xFF4facfe), Color(0xFF00f2fe)],
      [Color(0xFF43e97b), Color(0xFF38f9d7)],
      [Color(0xFFfa709a), Color(0xFFfee140)],
      [Color(0xFFa8edea), Color(0xFFfed6e3)],
    ];
    
    final colorIndex = title.hashCode % colors.length;
    final gradient = colors[colorIndex.abs()];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // Patrón decorativo
                Positioned(
                  right: -10,
                  top: -10,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                
                // Contenido
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}