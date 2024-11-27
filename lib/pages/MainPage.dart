import 'package:flutter/material.dart';
import 'package:trading_app/pages/DebtPage.dart';
import 'package:trading_app/pages/WalletPage.dart';
import 'home_page.dart';


class MainPage extends StatefulWidget {
  static const String routename = '/main';

  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const WalletPage(),
    const DebtPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Muestra la página actual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Índice de la página actual
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Cambia la página seleccionada
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Billetera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Deudas',
          ),
        ],
      ),
    );
  }
}
