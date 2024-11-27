import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_app/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  static const String routename = '/register';

  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  static const IconData currency_exchange_outlined = IconData(
    0xf05d6,
    fontFamily: 'MaterialIcons',
  );

  Future<void> _register() async {
  String email = _emailController.text;
  String password = _passwordController.text;

  User? user = await _authService.registerWithEmailPassword(email, password);
  if (user != null) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error en el registro')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Text(
                'TRADEGENIUS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20344C),
                ),
              ),
            ),
            
            const SizedBox(height: 10),

            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF20344C),
                child: Icon(
                  currency_exchange_outlined,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: Column(
                children: [
                  const Text(
                    'Registrar ahora',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  const Text(
                    'Crea tu cuenta y comienza a invertir de manera inteligente',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF20344C),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
