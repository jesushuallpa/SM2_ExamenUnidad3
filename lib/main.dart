import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyecto_moviles_2/models/product.dart';
import 'package:proyecto_moviles_2/screens/AdminDashboardScreen.dart';
import 'package:proyecto_moviles_2/screens/LoginScreen.dart';
import 'package:proyecto_moviles_2/screens/RecoverPasswordScreen.dart';
import 'package:proyecto_moviles_2/screens/RegisterScreen.dart';
import 'package:proyecto_moviles_2/screens/product_detail_screen.dart';
import 'package:proyecto_moviles_2/screens/registro_pago_screen.dart';

import 'firebase_options.dart';

// Pantallas de tu app
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(); // Solo si usas .env
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp con Chatbot',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const LoginScreen(),
        '/login': (ctx) => const LoginScreen(),
        '/register': (ctx) => const RegisterScreen(),
        '/recover': (ctx) => const RecoverPasswordScreen(),
        '/home': (ctx) => const MainScreen(),
        '/catalog': (ctx) => CatalogScreen(),
        '/chat': (ctx) => const ChatScreen(),
        '/admin': (ctx) => const AdminDashboardScreen(),
        '/registro-pago': (context) => const RegistroPagoScreen(),
        '/detalle_producto': (context) {
          final Product producto =
              ModalRoute.of(context)!.settings.arguments as Product;
          return ProductDetailScreen(product: producto);
        },
      },
    );
  }
}
