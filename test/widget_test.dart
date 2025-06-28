import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_moviles_2/services/AuthService.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  // --- Configuración de Mocks ---
  // Se crearán instancias simuladas (mocks) de los servicios de Firebase
  // para que podamos controlar su comportamiento durante las pruebas sin
  // necesidad de una conexión real.

  // Mock para Firebase Authentication
  late MockFirebaseAuth mockAuth;
  // Mock para Cloud Firestore
  late FakeFirebaseFirestore fakeFirestore;
  // Instancia de nuestro servicio que usará los mocks
  late AuthService authService;

  // El bloque `setUp` se ejecuta antes de cada prueba individual.
  // Esto asegura que cada prueba comience con un estado limpio.
  setUp(() {
    // Creamos un usuario simulado para nuestras pruebas de inicio de sesión
    mockAuth = MockFirebaseAuth(
      mockUser: MockUser(
        isAnonymous: false,
        uid: 'some_uid',
        email: 'test@test.com',
        displayName: 'Test User',
      ),
      signedIn: true, // El usuario simulado ya está logueado
    );
    
    fakeFirestore = FakeFirebaseFirestore();
    authService = AuthService(
        auth: mockAuth, // Inyectamos el mock de Auth
        firestore: fakeFirestore, // Inyectamos el mock de Firestore
    );
  });


  // --- Grupo de Pruebas para AuthService ---
  group('AuthService Tests', () {

    // --- Prueba 1: Inicio de Sesión Exitoso ---
    test('login - debe devolver verdadero con credenciales correctas', () async {
      // **Arrange** (Preparar): 
      // En este caso, el MockFirebaseAuth ya está configurado para un inicio
      // de sesión exitoso por defecto. No se necesita más preparación.
      
      // **Act** (Actuar):
      // Llamamos al método de login con credenciales de prueba.
      final result = await authService.login('test@test.com', 'password');
      
      // **Assert** (Verificar):
      // Esperamos que el resultado sea `true`.
      expect(result, isTrue);
    });


    // --- Prueba 2: Registro de Usuario Exitoso ---
    test('register - debe devolver verdadero y crear un documento de usuario', () async {
      // **Arrange** (Preparar): 
      // No necesitamos preparación adicional, el mockAuth manejará la creación.

      // **Act** (Actuar):
      // Llamamos al método de registro con datos de prueba.
      final result = await authService.register(
        'newuser@test.com',
        'password123',
        'cliente',
        'Nuevo Usuario',
        '123456789',
      );

      // **Assert** (Verificar):
      // 1. Verificamos que el método `register` haya devuelto `true`.
      expect(result, isTrue);
      
      // 2. Verificamos que los datos del nuevo usuario se hayan escrito
      //    correctamente en nuestra base de datos simulada (FakeFirestore).
      final userDoc = await fakeFirestore
          .collection('usuario')
          .doc(mockAuth.currentUser!.uid) // Usamos el UID del usuario recién creado por el mock
          .get();
          
      expect(userDoc.exists, isTrue); // El documento debe existir.
      expect(userDoc.data()?['email'], 'newuser@test.com'); // El email debe coincidir.
      expect(userDoc.data()?['nombre'], 'Nuevo Usuario'); // El nombre debe coincidir.
    });


    // --- Prueba 3: Obtener Datos del Usuario ---
    test('getUserData - debe devolver los datos del usuario si está logueado', () async {
      // **Arrange** (Preparar):
      // Vamos a añadir manualmente un documento de usuario a nuestra base de datos
      // simulada para que coincida con el usuario que está "logueado" en mockAuth.
      final userUid = mockAuth.currentUser!.uid;
      await fakeFirestore.collection('usuario').doc(userUid).set({
        'email': 'test@test.com',
        'nombre': 'Test User',
        'rol': 'admin',
      });

      // **Act** (Actuar):
      // Llamamos al método para obtener los datos del usuario.
      final userData = await authService.getUserData();

      // **Assert** (Verificar):
      // Verificamos que los datos obtenidos no sean nulos y que contengan
      // la información que esperamos.
      expect(userData, isNotNull);
      expect(userData?['email'], 'test@test.com');
      expect(userData?['rol'], 'admin');
    });

  });
}

// NOTA: Para que este archivo de prueba funcione, he tenido que modificar
// ligeramente tu `AuthService` para permitir la "inyección de dependencias".
// Esto significa que en lugar de que `AuthService` siempre use `FirebaseAuth.instance`,
// le pasamos la instancia que debe usar (en este caso, nuestros mocks).
//
// Tu clase AuthService debería verse así:
//
// class AuthService {
//   final FirebaseAuth _auth;
//   final FirebaseFirestore _firestore;
//
//   AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
//       : _auth = auth ?? FirebaseAuth.instance,
//         _firestore = firestore ?? FirebaseFirestore.instance;
//
//   // ... el resto de tus métodos van aquí, pero usando _auth y _firestore
//   // en lugar de FirebaseAuth.instance y FirebaseFirestore.instance
// }
//
// Este cambio es una práctica recomendada que hace tu código mucho más testeable.
