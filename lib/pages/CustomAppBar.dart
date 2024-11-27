import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.centerTitle = false, // Valor predeterminado
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF20344C),
        ),
      ),
      centerTitle: centerTitle, 
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await FirebaseAuth.instance.signOut(); 
              Navigator.pushReplacementNamed(context, '/welcome'); 
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: Color(0xFF20344C)), 
                    SizedBox(width: 8), 
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ];
          },
          icon: const Icon(Icons.more_vert, color: Color(0xFF20344C)),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
