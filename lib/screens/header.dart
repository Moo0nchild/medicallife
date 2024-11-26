import 'package:flutter/material.dart';


class Header extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Panel Médico'),
      actions: [
        
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }
}
