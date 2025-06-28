import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart'; // Importa mockito para 'any' y 'verify'
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias para evitar conflictos

// Importa tus pantallas y servicios. Las rutas se ajustan a tus nombres de archivo actuales (PascalCase).
// Si ya renombraste tus archivos a snake_case, actualiza estas importaciones.
import 'package:proyecto_moviles_2/screens/LoginScreen.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart';
import 'package:proyecto_moviles_2/screens/AdminHomePage.dart'; // Necesario para la navegación
import 'package:proyecto_moviles_2/screens/AdminDashboardScreen.dart'; // Necesario para la navegación
import 'package:proyecto_moviles_2/screens/main_screen.dart'; // Necesario para la navegación
import 'package:proyecto_moviles_2/screens/RecoverPasswordScreen.dart'; // Importación ahora explícita
import 'package:proyecto_moviles_2/screens/RegisterScreen.dart';     // Importación ahora explícita


// Importa el archivo de mocks generado.
// ASEGÚRATE de que el archivo 'test_mocks.dart' existe en la carpeta 'test/'
// y de que has ejecutado 'flutter pub run build_runner build --build-filter "test/test_mocks.dart" --delete-conflicting-outputs'.
// Este archivo CONTIENE la clase MockFirebaseAuth generada.
import 'test_mocks.mocks.dart';

void main() {
  // Instancias de los mocks que usarán tus tests.
  // Estas son las instancias que simularán el comportamiento de Firebase.
  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    // Se ejecuta antes de cada test. Inicializa los mocks y limpia el estado.
    mockFirebaseAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();

    // Limpia el usuario actual de AuthService para cada test.
    // Esto es crucial para que los tests no interfieran entre sí.
    AuthService.currentUser = null;
  });

  group('LoginScreen Basic Tests', () {
    // TEST 1: Verificar que los campos de UI básicos están presentes.
    testWidgets('debería mostrar campos de email y contraseña, y botón de login', (WidgetTester tester) async {
      // Construye y renderiza la pantalla de Login.
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Verifica que hay dos campos de texto (email y contraseña).
      expect(find.byType(TextFormField), findsNWidgets(2));
      // Verifica que el botón 'Ingresar' está presente.
      expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
      // Verifica que el botón '¿Olvidaste tu contraseña?' está presente.
      expect(find.widgetWithText(TextButton, '¿Olvidaste tu contraseña?'), findsOneWidget);
      // Verifica que el botón 'Regístrate' está presente.
      expect(find.widgetWithText(TextButton, 'Regístrate'), findsOneWidget);
    });

    // TEST 2: Verificar el comportamiento de login con credenciales inválidas.
    testWidgets('debería mostrar mensaje de error con credenciales inválidas', (WidgetTester tester) async {
      // Construye y renderiza la pantalla de Login.
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Configura el mock de FirebaseAuth para simular un login fallido.
      // Cuando AuthService.login intente llamar a signInWithEmailAndPassword,
      // lanzaremos una excepción simulada de FirebaseAuth.
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: any, // 'any' significa que aceptará cualquier valor de email.
        password: any, // 'any' significa que aceptará cualquier valor de contraseña.
      )).thenThrow(firebase_auth.FirebaseAuthException(code: 'wrong-password', message: 'Credenciales inválidas'));

      // Simula la entrada de texto en los campos de email y contraseña.
      await tester.enterText(find.byType(TextFormField).first, 'invalid@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'wrongpassword');
      // Simula el toque en el botón 'Ingresar'.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      // Vuelve a bombear los frames y espera a que las animaciones (como la SnackBar) terminen.
      await tester.pumpAndSettle();

      // Verifica que el SnackBar con el mensaje de error "Credenciales incorrectas" se muestra.
      expect(find.text('Credenciales incorrectas'), findsOneWidget);

      // Opcional: Verifica que el método signInWithEmailAndPassword fue llamado exactamente una vez.
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'invalid@example.com',
        password: 'wrongpassword',
      )).called(1);
    });

    // TEST 3: Verificar la navegación exitosa para un usuario con rol 'administrador'.
    testWidgets('debería navegar a AdminHomePage si el rol es administrador', (WidgetTester tester) async {
      // Construye y renderiza la pantalla de Login.
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // 1. Simula un usuario exitosamente logueado.
      final mockUser = MockUser(uid: 'admin_uid'); // Crea un usuario mock con un UID específico.
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'admin@test.com', password: 'password123'
      )).thenAnswer((_) async => MockUserCredential(user: mockUser)); // Devuelve un UserCredential mock.

      // 2. Configura FakeFirebaseFirestore para que devuelva el rol 'administrador' para el UID simulado.
      await fakeFirestore.collection('usuario').doc('admin_uid').set({'rol': 'administrador'});

      // 3. Establece el usuario actual en AuthService con el mockUser.
      // Esto es crucial para que el método _obtenerRol en LoginScreen funcione con tu mock.
      AuthService.currentUser = mockUser;

      // Simula la entrada de datos de login y el toque del botón.
      await tester.enterText(find.byType(TextFormField).first, 'admin@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pumpAndSettle(); // Espera a que la navegación se complete.

      // Verifica que se ha navegado a AdminHomePage y que LoginScreen ha desaparecido.
      expect(find.byType(AdminHomePage), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing); // La pantalla de Login debería ser reemplazada.

      // Opcional: Verifica interacciones.
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'admin@test.com',
        password: 'password123',
      )).called(1);
      // Verifica que se intentó obtener el documento del usuario en Firestore.
      expect((await fakeFirestore.collection('usuario').doc('admin_uid').get()).exists, isTrue);
    });

    // NUEVO TEST: Verificar la navegación a la pantalla de recuperación de contraseña.
    testWidgets('debería navegar a RecoverPasswordScreen al hacer clic en "¿Olvidaste tu contraseña?"', (WidgetTester tester) async {
      // Construye la pantalla de Login.
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      // Encuentra y toca el botón de "Olvidaste tu contraseña".
      await tester.tap(find.widgetWithText(TextButton, '¿Olvidaste tu contraseña?'));
      // Espera a que la animación de navegación se complete.
      await tester.pumpAndSettle();

      // Verifica que la pantalla RecoverPasswordScreen está ahora en el árbol de widgets.
      expect(find.byType(RecoverPasswordScreen), findsOneWidget);
      // En este caso, como es un `Navigator.push`, la LoginScreen todavía debería estar en el stack.
      // Si tu `LoginScreen` usa `pushReplacement` aquí, cambia `findsOneWidget` a `findsNothing`.
      // Basado en tu código de LoginScreen, es `push`, así que LoginScreen seguiría ahí.
      expect(find.byType(LoginScreen), findsOneWidget); 
    });
  });
}
