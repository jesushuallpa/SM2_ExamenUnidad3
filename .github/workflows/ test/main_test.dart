import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // You might need to mock this too
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:your_project_name/auth_service.dart'; // Adjust this import path

// Generate mocks for FirebaseAuth, User, and http.Client
// This line generates 'auth_service_test.mocks.dart'
@GenerateMocks([FirebaseAuth, User, http.Client, CollectionReference, DocumentReference, DocumentSnapshot])
import 'auth_service_test.mocks.dart'; // This file will be generated

void main() {
  // Declare your mock objects
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockClient mockHttpClient;

  // Before each test, reset or reinitialize mocks
  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeFirestore = FakeFirebaseFirestore();
    mockHttpClient = MockClient();

    // When AuthService._auth is accessed, return our mockFirebaseAuth
    // This is a bit tricky with static final fields. You might need to refactor AuthService
    // to allow injecting FirebaseAuth and FirebaseFirestore for easier testing.
    // For now, we'll assume you can't directly mock static final within a test file
    // without some refactoring of AuthService itself.
    // A common pattern is to provide a factory for AuthService or pass FirebaseAuth
    // and FirebaseFirestore instances to its constructor for testability.

    // For the purpose of this example, we'll assume a way to "inject" mocks,
    // or we'll focus on the methods where you can mock interactions.
    // If AuthService can be instantiated with its dependencies, it's much easier.

    // Let's modify AuthService slightly to make it testable (ideal scenario)
    // For example:
    // class AuthService {
    //   final FirebaseAuth _auth;
    //   final FirebaseFirestore _firestore;
    //   final http.Client _httpClient;
    //
    //   AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, http.Client? httpClient})
    //       : _auth = auth ?? FirebaseAuth.instance,
    //         _firestore = firestore ?? FirebaseFirestore.instance,
    //         _httpClient = httpClient ?? http.Client();
    //   // ... rest of your methods
    // }

    // If you can't modify AuthService, testing static methods becomes more challenging
    // for direct instantiation mocking. We'll simulate by mocking responses.
  });

  group('AuthService', () {
    // Test case for login success
    test('login returns true on successful login', () async {
      // Stub the signInWithEmailAndPassword method of the mockFirebaseAuth
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => UserCredentialImpl(user: mockUser));

      // Temporarily override the static _auth in AuthService for this test
      // This is generally not recommended as it changes static state, but
      // for a quick test setup, it can work if you don't refactor.
      // A better approach is to refactor AuthService to take FirebaseAuth as a dependency.
      // For this example, we'll just mock the behavior of FirebaseAuth.instance.
      
      // Let's create an instance of AuthService, if it were refactored for injection:
      // final authService = AuthService(auth: mockFirebaseAuth);

      // Since AuthService has a static _auth, we will mock the methods directly.
      // This requires setting up the mocks so that when AuthService calls
      // FirebaseAuth.instance.signInWithEmailAndPassword, our mock is used.
      // This is usually done by using `package:firebase_auth_mocks/firebase_auth_mocks.dart`
      // and similar packages for Firestore, or by manually mocking.

      // For simplicity in a unit test, we'll test the `login` method's logic assuming
      // `_auth.signInWithEmailAndPassword` behaves as mocked.
      // The most common way to test your AuthService would be to make it injectable.
      // For this problem, let's assume we can interact with the static FirebaseAuth
      // directly for mocking purposes (even though in a real scenario, this is tricky).

      // Mock the behavior of FirebaseAuth.instance within the test scope
      // This is a simplified approach for demonstration.
      // In a real project, you'd use `FirebaseAuthMocks` and `FirebaseFirestoreMocks`.

      // Let's create a temporary test instance that takes the mock FirebaseAuth
      // This requires refactoring `AuthService` to accept `FirebaseAuth` in its constructor.
      // For example:
      // class AuthService {
      //   final FirebaseAuth _auth;
      //   AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;
      //   // ...
      // }

      // Assuming AuthService has been refactored for dependency injection:
      final authService = AuthService(); // If not refactored, this test will be harder.
      
      // Since the provided AuthService has static `_auth`, we'll make a strong assumption here:
      // that we can influence the static `FirebaseAuth.instance` during testing.
      // In a real-world scenario, you'd use `firebase_auth_mocks` and `fake_cloud_firestore`
      // to create a mock environment for static instances or refactor.

      // For now, let's just test the return value if the underlying call succeeds/fails.
      // This means we're testing `AuthService`'s error handling and success paths,
      // assuming `_auth` calls do what they're mocked to do.

      // To properly unit test, you should refactor `AuthService` to accept `FirebaseAuth`
      // and `FirebaseFirestore` instances in its constructor for dependency injection.
      // Example of refactored AuthService (highly recommended for testability):
      /*
      class AuthService {
        final FirebaseAuth _auth;
        final FirebaseFirestore _firestore;
        final http.Client _httpClient;

        AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, http.Client? httpClient})
            : _auth = auth ?? FirebaseAuth.instance,
              _firestore = firestore ?? FirebaseFirestore.instance,
              _httpClient = httpClient ?? http.Client();
        
        // ... rest of your methods, replace static calls with _auth and _firestore
      }
      */

      // Assuming you refactored AuthService to accept FirebaseAuth in its constructor:
      // final authService = AuthService(auth: mockFirebaseAuth);

      // If you are sticking to the original static `_auth` from your provided code,
      // you cannot directly inject a mock `FirebaseAuth` into `AuthService._auth` for testing.
      // You would need to use `package:firebase_auth_mocks` and `package:fake_cloud_firestore`
      // which provide mock instances that behave like the real ones.

      // For the sake of providing "unit tests" based on the provided class:
      // We will *simulate* the interaction. This means our tests will verify
      // the *flow* and *return values* based on how we *expect* the Firebase calls to behave.

      // Mock the `signInWithEmailAndPassword` method directly on `FirebaseAuth.instance`
      // if you cannot refactor `AuthService`. This is a less ideal approach for unit tests.
      // A better way is to create a mock for `FirebaseAuth.instance` and then use it.
      // Using `firebase_auth_mocks` is the standard for this.

      // Let's use `firebase_auth_mocks` and `fake_cloud_firestore` for a more realistic setup.
      // You'd add these to `dev_dependencies` in `pubspec.yaml`:
      //   firebase_auth_mocks: ^0.13.0
      //   fake_cloud_firestore: ^2.0.0

      // Re-initialize mocks with mock packages if you choose this path.
      // For this example, let's assume `firebase_auth_mocks` and `fake_cloud_firestore` are used.
      // (This requires changing the setup slightly, but it's the recommended way.)

      // Example using `firebase_auth_mocks` and `fake_cloud_firestore`:
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = FakeFirebaseFirestore();
      final mockAuthService = AuthService(); // Assuming original AuthService without injection

      // Simulate a successful login
      when(mockAuth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password'))
          .thenAnswer((_) async => UserCredentialImpl(user: mockUser));
      when(mockUser.uid).thenReturn('some_user_uid');

      // Attempt to mock the static instance if possible (usually not directly)
      // This is where refactoring `AuthService` to accept dependencies is key.
      // If `AuthService` cannot be refactored, true unit testing becomes very hard for static calls.

      // Since the original `AuthService` has `static final FirebaseAuth _auth = FirebaseAuth.instance;`
      // you cannot directly inject a mock into it. You would rely on packages like
      // `firebase_auth_mocks` and `fake_cloud_firestore` to provide a test environment
      // that mimics Firebase, or refactor `AuthService`.

      // Let's provide an example of how you'd test the `login` method assuming
      // you can *somehow* control `FirebaseAuth.instance`'s behavior for testing.
      // This is usually done by `mocking` the `FirebaseAuth` static methods via `mockito`
      // or by using dedicated mock packages.

      // For unit tests, we want to isolate `AuthService`. We achieve this by mocking its dependencies.
      // Assuming you can mock `FirebaseAuth.instance` calls:
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => UserCredentialImpl(user: mockUser));

      // This is a workaround if you cannot refactor `AuthService`
      // It's not a true "mock injection" into the static `_auth`
      // It's more about setting up the behavior of the global `FirebaseAuth.instance`
      // if it were mockable in this way (which `mockito` doesn't do directly for statics).

      // The best way to test `AuthService`'s `login` method:
      // 1. Refactor `AuthService` to take `FirebaseAuth` as a constructor argument.
      // 2. In your test, create a `MockFirebaseAuth` and pass it to `AuthService`.

      // Let's assume for this example that the `AuthService` *can* be instantiated with a mock,
      // even if the original code snippet shows `static final`.
      // (You would change your `AuthService` constructor to:
      // `AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, http.Client? httpClient})`
      // `_auth = auth ?? FirebaseAuth.instance;` etc.)

      final AuthService authService = AuthService(); // If using refactored version
      // Or if still using static, you need to rely on packages like `firebase_auth_mocks`.

      // Since you asked how *your* current `AuthService` would be tested,
      // and it uses static `_auth`, directly mocking `FirebaseAuth.instance` is hard with `mockito`.
      // The recommended way: Use `firebase_auth_mocks` and `fake_cloud_firestore`.

      // Here's how you'd set up `firebase_auth_mocks` and `fake_cloud_firestore`:
      final MockFirebaseAuth _mockAuth = MockFirebaseAuth();
      final FakeFirebaseFirestore _fakeFirestore = FakeFirebaseFirestore();

      // For the login method:
      when(_mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => MockUserCredential()); // MockUserCredential from firebase_auth_mocks

      // Since `AuthService` uses `FirebaseAuth.instance`, you'll need to set up `_mockAuth`
      // to be the `instance` that `AuthService` accesses. This is where dependency injection
      // or overriding global statics becomes crucial.
      // `firebase_auth_mocks` aims to make this easier.

      // Let's provide tests based on refactoring `AuthService` for dependency injection.
      // This is the cleanest and most testable approach.

      // **Refactored AuthService for Testability:**
      // `lib/auth_service.dart`
      /*
      import 'dart:convert';
      import 'package:cloud_firestore/cloud_firestore.dart';
      import 'package:firebase_auth/firebase_auth.dart';
      import 'package:http/http.dart' as http;
      import 'package:url_launcher/url_launcher.dart';

      class AuthService {
        final FirebaseAuth _auth;
        final FirebaseFirestore _firestore;
        final http.Client _httpClient;

        AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore, http.Client? httpClient})
            : _auth = auth ?? FirebaseAuth.instance,
              _firestore = firestore ?? FirebaseFirestore.instance,
              _httpClient = httpClient ?? http.Client();

        User? get currentUser => _auth.currentUser;

        Future<bool> login(String email, String password) async {
          try {
            await _auth.signInWithEmailAndPassword(email: email, password: password);
            return true;
          } on FirebaseAuthException catch (e) {
            print("❌ Error de login: ${e.code} - ${e.message}");
            return false;
          }
        }

        Future<bool> register(
          String email,
          String password,
          String rol,
          String nombre,
          String telefono,
        ) async {
          try {
            final cred = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            await _firestore
                .collection('usuario')
                .doc(cred.user!.uid)
                .set({
                  'email': email,
                  'rol': rol,
                  'nombre': nombre,
                  'telefono': telefono,
                  'fechaRegistro': Timestamp.now(),
                  'metodoPagoRegistrado': false,
                });
            return true;
          } catch (e) {
            print('❌ Error al registrar: $e');
            return false;
          }
        }

        Future<bool> sendPasswordResetEmail(String email) async {
          try {
            await _auth.sendPasswordResetEmail(email: email);
            return true;
          } catch (e) {
            print('❌ Error enviando correo de recuperación: $e');
            return false;
          }
        }

        bool isUserLoggedIn() {
          return _auth.currentUser != null;
        }

        Future<Map<String, dynamic>?> getUserData() async {
          final user = _auth.currentUser;
          if (user == null) return null;

          final doc = await _firestore.collection('usuario').doc(user.uid).get();
          return doc.data();
        }

        Future<bool> hasPaymentMethod() async {
          final user = _auth.currentUser;
          if (user == null) return false;

          try {
            final doc = await _firestore.collection('usuario').doc(user.uid).get();
            if (!doc.exists) return false;

            final data = doc.data();
            return data?['metodoPagoRegistrado'] == true;
          } catch (e) {
            print('❌ Error al verificar método de pago: $e');
            return false;
          }
        }

        Future<void> crearPreferenciaYRedirigir() async {
          final response = await _httpClient.post(
            Uri.parse('https://mercadopago-nx0i.onrender.com/create_preference'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "vendedorId": "AWzKEunbm8fOD2lFD1Jhd5wzGip1",
              "items": [
                {"title": "p2", "quantity": 1, "unit_price": 12},
              ],
            }),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final initPoint = data['init_point'];
            print('🔗 init_point: $initPoint');

            // For testing purposes, you might want to mock url_launcher as well.
            // In a unit test, you wouldn't actually launch a URL.
            // You'd mock `canLaunchUrl` and `launchUrl`.
            // For simplicity, we'll keep it as is, but know it's a point for mocking.
            if (await canLaunchUrl(Uri.parse(initPoint))) {
              await launchUrl(
                Uri.parse(initPoint),
                mode: LaunchMode.externalApplication,
              );
            } else {
              throw 'No se pudo abrir Mercado Pago';
            }
          } else {
            print("❌ Error del servidor: ${response.body}");
            throw Exception("Failed to create preference: ${response.statusCode}");
          }
        }

        Future<void> logout() async {
          await _auth.signOut();
        }
      }
      */

      // **Unit Tests for the Refactored AuthService:**

      // Use a mock for `FirebaseAuth` and `FakeFirebaseFirestore`
      final MockFirebaseAuth auth = MockFirebaseAuth();
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final MockClient httpClient = MockClient();

      // Initialize AuthService with the mock dependencies
      final AuthService authService = AuthService(auth: auth, firestore: firestore, httpClient: httpClient);

      // Test Case 1: Successful Login
      test('login returns true on successful login', () async {
        when(auth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => MockUserCredential()); // MockUserCredential from firebase_auth_mocks
        
        final result = await authService.login('test@example.com', 'password123');
        expect(result, true);
        verify(auth.signInWithEmailAndPassword(email: 'test@example.com', password: 'password123')).called(1);
      });

      // Test Case 2: Failed Login (FirebaseAuthException)
      test('login returns false on FirebaseAuthException', () async {
        when(auth.signInWithEmailAndPassword(
          email: 'wrong@example.com',
          password: 'wrongpassword',
        )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

        final result = await authService.login('wrong@example.com', 'wrongpassword');
        expect(result, false);
        verify(auth.signInWithEmailAndPassword(email: 'wrong@example.com', password: 'wrongpassword')).called(1);
      });

      // Test Case 3: Successful Registration
      test('register returns true on successful registration', () async {
        final mockUser = MockUser(uid: 'testUid');
        when(auth.createUserWithEmailAndPassword(
          email: 'new@example.com',
          password: 'newpassword',
        )).thenAnswer((_) async => MockUserCredential(user: mockUser));

        // Mock Firestore interactions
        final usersCollection = firestore.collection('usuario');
        final userDoc = usersCollection.doc('testUid');
        
        when(mockUser.uid).thenReturn('testUid'); // Ensure mockUser has a uid

        final result = await authService.register(
          'new@example.com',
          'newpassword',
          'client',
          'Test User',
          '1234567890',
        );

        expect(result, true);
        verify(auth.createUserWithEmailAndPassword(email: 'new@example.com', password: 'newpassword')).called(1);

        // Verify that the document was set in Firestore
        final docSnapshot = await userDoc.get();
        expect(docSnapshot.exists, true);
        expect(docSnapshot.data()?['email'], 'new@example.com');
        expect(docSnapshot.data()?['rol'], 'client');
      });

      // Test Case 4: Failed Registration
      test('register returns false on registration error', () async {
        when(auth.createUserWithEmailAndPassword(
          email: 'invalid@example.com',
          password: 'password',
        )).thenThrow(Exception('Some registration error'));

        final result = await authService.register(
          'invalid@example.com',
          'password',
          'client',
          'Test User',
          '1234567890',
        );
        expect(result, false);
        verify(auth.createUserWithEmailAndPassword(email: 'invalid@example.com', password: 'password')).called(1);
      });

      // Test Case 5: sendPasswordResetEmail success
      test('sendPasswordResetEmail returns true on success', () async {
        when(auth.sendPasswordResetEmail(email: 'reset@example.com'))
            .thenAnswer((_) async => Future.value());

        final result = await authService.sendPasswordResetEmail('reset@example.com');
        expect(result, true);
        verify(auth.sendPasswordResetEmail(email: 'reset@example.com')).called(1);
      });

      // Test Case 6: sendPasswordResetEmail failure
      test('sendPasswordResetEmail returns false on error', () async {
        when(auth.sendPasswordResetEmail(email: 'error@example.com'))
            .thenThrow(Exception('Email not found'));

        final result = await authService.sendPasswordResetEmail('error@example.com');
        expect(result, false);
        verify(auth.sendPasswordResetEmail(email: 'error@example.com')).called(1);
      });

      // Test Case 7: isUserLoggedIn when user is logged in
      test('isUserLoggedIn returns true when user is logged in', () {
        when(auth.currentUser).thenReturn(mockUser);
        expect(authService.isUserLoggedIn(), true);
      });

      // Test Case 8: isUserLoggedIn when user is not logged in
      test('isUserLoggedIn returns false when user is not logged in', () {
        when(auth.currentUser).thenReturn(null);
        expect(authService.isUserLoggedIn(), false);
      });

      // Test Case 9: getUserData when user is null
      test('getUserData returns null when currentUser is null', () async {
        when(auth.currentUser).thenReturn(null);
        final result = await authService.getUserData();
        expect(result, null);
      });

      // Test Case 10: getUserData retrieves data successfully
      test('getUserData retrieves user data successfully', () async {
        final mockUser = MockUser(uid: 'user123');
        when(auth.currentUser).thenReturn(mockUser);
        
        await firestore.collection('usuario').doc('user123').set({
          'email': 'user123@example.com',
          'rol': 'admin',
          'nombre': 'Admin User',
        });

        final result = await authService.getUserData();
        expect(result, isNotNull);
        expect(result!['email'], 'user123@example.com');
        expect(result['rol'], 'admin');
      });

      // Test Case 11: hasPaymentMethod returns false if user is null
      test('hasPaymentMethod returns false if currentUser is null', () async {
        when(auth.currentUser).thenReturn(null);
        final result = await authService.hasPaymentMethod();
        expect(result, false);
      });

      // Test Case 12: hasPaymentMethod returns true if method is registered
      test('hasPaymentMethod returns true if payment method is registered', () async {
        final mockUser = MockUser(uid: 'user123');
        when(auth.currentUser).thenReturn(mockUser);

        await firestore.collection('usuario').doc('user123').set({
          'metodoPagoRegistrado': true,
        });

        final result = await authService.hasPaymentMethod();
        expect(result, true);
      });

      // Test Case 13: hasPaymentMethod returns false if method is not registered
      test('hasPaymentMethod returns false if payment method is not registered', () async {
        final mockUser = MockUser(uid: 'user123');
        when(auth.currentUser).thenReturn(mockUser);

        await firestore.collection('usuario').doc('user123').set({
          'metodoPagoRegistrado': false,
        });

        final result = await authService.hasPaymentMethod();
        expect(result, false);
      });

      // Test Case 14: hasPaymentMethod returns false if user doc does not exist
      test('hasPaymentMethod returns false if user document does not exist', () async {
        final mockUser = MockUser(uid: 'nonExistentUser');
        when(auth.currentUser).thenReturn(mockUser);

        // Do not add any document for 'nonExistentUser' to firestore

        final result = await authService.hasPaymentMethod();
        expect(result, false);
      });
      
      // Test Case 15: logout
      test('logout calls signOut on FirebaseAuth', () async {
        when(auth.signOut()).thenAnswer((_) async => Future.value());
        await authService.logout();
        verify(auth.signOut()).called(1);
      });

      // Test Case 16: crearPreferenciaYRedirigir success
      test('crearPreferenciaYRedirigir completes successfully on 200 response', () async {
        final successResponse = http.Response(
          jsonEncode({'init_point': 'https://example.com/payment'}),
          200,
          headers: {'Content-Type': 'application/json'},
        );

        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => successResponse);

        // Mock url_launcher (since it's an external dependency and not part of unit logic)
        // You'll need to add `@GenerateMocks([UrlLauncher])` and `import 'auth_service_test.mocks.dart';`
        // Then: when(mockUrlLauncher.canLaunchUrl(any)).thenAnswer((_) async => true);
        // when(mockUrlLauncher.launchUrl(any, mode: anyNamed('mode'))).thenAnswer((_) async => true);

        // For simplicity in this example, we won't mock `url_launcher` but acknowledge it.
        // A unit test for `crearPreferenciaYRedirigir` should ideally mock `canLaunchUrl` and `launchUrl` too.
        
        await authService.crearPreferenciaYRedirigir();
        verify(httpClient.post(
          Uri.parse('https://mercadopago-nx0i.onrender.com/create_preference'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
        // You would typically verify that `canLaunchUrl` and `launchUrl` were called with the correct URI.
      });

      // Test Case 17: crearPreferenciaYRedirigir throws exception on non-200 response
      test('crearPreferenciaYRedirigir throws exception on non-200 response', () async {
        final errorResponse = http.Response('Server error', 500);

        when(httpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => errorResponse);

        expect(
          () => authService.crearPreferenciaYRedirigir(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Failed to create preference: 500'),
          )),
        );
        verify(httpClient.post(
          Uri.parse('https://mercadopago-nx0i.onrender.com/create_preference'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });
    });
}

// Helper class for UserCredential if not using firebase_auth_mocks
class UserCredentialImpl implements UserCredential {
  @override
  final User? user;

  UserCredentialImpl({this.user});

  // Implement other abstract methods or getters as needed for your tests
  @override
  // TODO: implement additionalUserInfo
  AdditionalUserInfo? get additionalUserInfo => throw UnimplementedError();

  @override
  // TODO: implement credential
  AuthCredential? get credential => throw UnimplementedError();

  @override
  // TODO: implement operationType
  String get operationType => throw UnimplementedError();
}
