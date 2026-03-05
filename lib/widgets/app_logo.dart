import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 96.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Lignes de connexion (SVG translation)
          Positioned.fill(child: CustomPaint(painter: _LogoLinesPainter())),

          // Cercle supérieur (violet/bleu)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFF8B9DC3),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.2,
                ),
              ),
            ),
          ),

          // Cercle inférieur gauche
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFFB8D8E0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

          // Cercle inférieur droit
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: const Color(0xFFA8CDD8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94B8C8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Ligne gauche: (50%, 25%) to (20%, 75%)
    path.moveTo(size.width * 0.5, size.height * 0.25);
    path.lineTo(size.width * 0.2, size.height * 0.75);

    // Ligne droite: (50%, 25%) to (80%, 75%)
    path.moveTo(size.width * 0.5, size.height * 0.25);
    path.lineTo(size.width * 0.8, size.height * 0.75);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
