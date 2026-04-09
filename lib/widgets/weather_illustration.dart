import 'package:flutter/material.dart';

class WeatherIllustration extends StatelessWidget {
  final bool isDay;
  final bool isSunny;

  const WeatherIllustration({
    super.key,
    required this.isDay,
    required this.isSunny,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -70,
            right: -30,
            child: _blob(
              size: 220,
              colors: isDay
                  ? [
                      const Color(0x99FFE9AA),
                      const Color(0x00FFFFFF),
                    ]
                  : [
                      const Color(0xAA9CA9FF),
                      const Color(0x007A8CEB),
                    ],
            ),
          ),
          Positioned(
            top: 110,
            left: -70,
            child: _blob(
              size: 180,
              colors: const [Color(0x45FFFFFF), Color(0x00FFFFFF)],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _MountainPainter(
                front: Colors.white.withValues(alpha: 0.10),
                back: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          if (isSunny && isDay)
            Positioned(
              top: 90,
              right: 45,
              child: Container(
                width: 54,
                height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD36E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                          color: Color(0x66FFD36E),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _blob({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _MountainPainter extends CustomPainter {
  final Color front;
  final Color back;

  const _MountainPainter({required this.front, required this.back});

  @override
  void paint(Canvas canvas, Size size) {
    final backPath = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.35,
        size.width * 0.40,
        size.height * 0.58,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.88,
        size.width,
        size.height * 0.50,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final frontPath = Path()
      ..moveTo(0, size.height * 0.80)
      ..quadraticBezierTo(
        size.width * 0.16,
        size.height * 0.62,
        size.width * 0.34,
        size.height * 0.83,
      )
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height,
        size.width * 0.80,
        size.height * 0.74,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.65,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backPath, Paint()..color = back);
    canvas.drawPath(frontPath, Paint()..color = front);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) {
    return oldDelegate.front != front || oldDelegate.back != back;
  }
}
