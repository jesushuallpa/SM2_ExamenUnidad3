class PreferenceQuestion {
  final String
  key; // La clave que se guardará en Firestore (ej: 'estilo', 'colores_preferidos')
  final String question; // La pregunta a mostrar al usuario
  final List<String>
  options; // Las opciones que el usuario puede elegir (strings simples)
  final bool
  allowMultipleSelection; // true si puede elegir varias opciones, false si es una sola

  PreferenceQuestion({
    required this.key,
    required this.question,
    required this.options,
    this.allowMultipleSelection = false, // Por defecto, selección única
  });
}

// Define tus preguntas aquí
final List<PreferenceQuestion> preferenceQuestions = [
  PreferenceQuestion(
    key: 'estilo_preferido',
    question: '¿Cuál es tu estilo de ropa preferido?',
    options: [
      'Casual',
      'Elegante',
      'Deportivo',
      'Vintage',
      'Boho',
      'Minimalista',
    ],
    allowMultipleSelection: true, // Puede tener varios estilos
  ),
  PreferenceQuestion(
    key: 'colores_preferidos',
    question: '¿Qué colores te gustan más para tu ropa?',
    options: [
      'Negro',
      'Blanco',
      'Gris',
      'Azul',
      'Rojo',
      'Verde',
      'Amarillo',
      'Rosa',
      'Morado',
      'Neutros (beige, crema)',
    ],
    allowMultipleSelection: true, // Puede elegir varios colores
  ),
  PreferenceQuestion(
    key: 'tipo_prenda_favorita',
    question: '¿Qué tipo de prenda sueles buscar más?',
    options: [
      'Camisetas y Tops',
      'Pantalones y Jeans',
      'Vestidos y Faldas',
      'Abrigos y Chaquetas',
      'Calzado',
      'Accesorios',
    ],
    allowMultipleSelection: true,
  ),
  PreferenceQuestion(
    key: 'ocasion_uso',
    question: '¿Para qué ocasión sueles comprar ropa?',
    options: [
      'Uso Diario',
      'Eventos Especiales',
      'Trabajo/Oficina',
      'Deporte',
      'Fiestas',
    ],
    allowMultipleSelection: true,
  ),
  PreferenceQuestion(
    key: 'rango_edad',
    question: '¿En qué rango de edad te encuentras?',
    options: ['Menos de 18', '18-24', '25-34', '35-44', '45-54', '55 o más'],
    allowMultipleSelection: false, // Solo un rango de edad
  ),
  PreferenceQuestion(
    key: 'genero',
    question: '¿Cuál es tu género?',
    options: ['Masculino', 'Femenino', 'Otro', 'Prefiero no decirlo'],
    allowMultipleSelection: false,
  ),
  // Puedes añadir más preguntas aquí
];
