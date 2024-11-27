import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:trading_app/pages/login_page.dart';
import 'package:trading_app/pages/welcome_page.dart';
import 'package:trading_app/pages/MainScreen.dart';
import 'package:trading_app/pages/register_page.dart'; 
import 'package:trading_app/pages/home_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trading App',
      initialRoute: LoginPage.routename,
      routes: {
        WelcomePage.routename: (context) => const WelcomePage(),
        LoginPage.routename: (context) => const LoginPage(),
        RegisterPage.routename: (context) => const RegisterPage(), 
        '/main': (context) => const MainScreen(),
        '/home': (context) => const HomePage(), 
      },
    );
  }
}
