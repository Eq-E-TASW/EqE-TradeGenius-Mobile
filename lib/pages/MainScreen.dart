import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trading_app/pages/DebtPage.dart';
import 'package:trading_app/pages/TradePage.dart';
import 'package:trading_app/pages/WalletPage.dart';
import 'package:trading_app/pages/home_page.dart';
import 'package:trading_app/pages/login_page.dart';
import 'package:trading_app/pages/chatbot_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const WalletPage(),
    const DebtPage(),
    const TradePage(),
    const ChatbotPage(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return _pages[_selectedIndex];
          } else {
            return const LoginPage();
          }
        },
      ),
      bottomNavigationBar: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 1), // Borde gris
                ),
              ),
              child: BottomNavigationBar(
                items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
                    BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Dashboard'), 
                    BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Trading'), 
                    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Predicción'), 
                    BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chatbot'), 
                ],
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: const Color(0xFF20344C), 
                unselectedItemColor: const Color(0xFFB0BEC5),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
