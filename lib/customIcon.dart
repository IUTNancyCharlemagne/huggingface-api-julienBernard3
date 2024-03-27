import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final double size;
  final VoidCallback onPressed;

  const CustomIcon({
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.withOpacity(0.5), // Couleur du cercle
        ),
        child: Center(
          child: Icon(
            Icons.close,
            size: size * 0.6, // Taille de l'icône relative à la taille du cercle
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
