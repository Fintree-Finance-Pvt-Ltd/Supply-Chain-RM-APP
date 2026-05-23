import 'dart:math';
import 'package:flutter/material.dart';
 
class AppLoader extends StatefulWidget {
  final double size;
  final Color color;
 
  const AppLoader({
    super.key,
    this.size = 60,
    this.color = const Color(0xFF0052FF), // Coinbase/Institutional Blue
  });
 
  @override
  State<AppLoader> createState() => _AppLoaderState();
}
 
class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
 
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _FinancePainter(
                progress: _controller.value,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}
 
class _FinancePainter extends CustomPainter {
  final double progress;
  final Color color;
 
  _FinancePainter({required this.progress, required this.color});
 
  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = size.width * 0.08;
    final center = size.center(Offset.zero);
    final radius = (size.width - strokeWidth) / 2;
 
    // 1. Draw the "Background Track" (Subtle Gray)
    final Paint trackPaint = Paint()
      ..color = const Color(0xFFE0E0E0).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);
 
    // 2. The Animated "Active Segment"
    // Using a Curved sweep for a more premium "acceleration" feel
    final Paint activePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
 
    double startAngle = -pi / 2;
    // This creates the "expanding and shrinking" arc effect
    double sweepAngle = 0.5 * pi + (sin(progress * 2 * pi).abs() * pi);
 
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
 
    // 3. The "Processing Dot"
    // A small dot that moves independently to show "active thinking"
    final Paint dotPaint = Paint()..color = color;
    double dotAngle = (progress * 2 * pi * 2); // Moves twice as fast
    Offset dotOffset = Offset(
      center.dx + cos(dotAngle) * (radius * 0.6), // Closer to center
      center.dy + sin(dotAngle) * (radius * 0.6),
    );
   
    canvas.drawCircle(dotOffset, strokeWidth * 0.6, dotPaint);
  }
 
  @override
  bool shouldRepaint(covariant _FinancePainter oldDelegate) => true;
}
 