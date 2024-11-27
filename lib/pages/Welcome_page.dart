import 'package:flutter/material.dart';
import 'package:trading_app/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  static const String routename = '/welcome'; 

  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20344c), // Color de fondo
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'BIENVENIDO A TRADEGENIUS',
              style: TextStyle(
                fontSize: 30, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10), 
            const Text(
              'Optimiza tus inversiones con analisis de datos en tiempo real',
              style: TextStyle(
                fontSize: 16, 
                color: Colors.white, 
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, LoginPage.routename);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color(0xFF20344c),
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Iniciar Ahora'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
