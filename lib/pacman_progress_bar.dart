import 'package:flutter/material.dart';

class PacmanProgressBar extends StatefulWidget {
  final double progress;
  final String label;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

  const PacmanProgressBar({
    Key? key,
    required this.progress,
    this.label = '',
    this.height = 12.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  }) : super(key: key);

  @override
  _PacmanProgressBarState createState() => _PacmanProgressBarState();
}

class _PacmanProgressBarState extends State<PacmanProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _mouthAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _mouthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
        ],
        CustomPaint(
          painter: _PacmanProgressPainter(
            progress: widget.progress,
            animationValue: _mouthAnimation.value,
            activeColor: widget.activeColor,
            inactiveColor: widget.inactiveColor,
          ),
          size: Size(double.infinity, widget.height),
        ),
        const SizedBox(height: 8),
        Text(
          '${(widget.progress * 100).round()}%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PacmanProgressPainter extends CustomPainter {
  final double progress;
  final double animationValue;
  final Color activeColor;
  final Color inactiveColor;

  _PacmanProgressPainter({
    required this.progress,
    required this.animationValue,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    // Calcular larguras
    final double activeWidth = size.width * progress;
    final double inactiveWidth = size.width * (1 - progress);

    // Desenhar parte inativa
    if (inactiveWidth > 0) {
      paint.color = inactiveColor;
      canvas.drawLine(
        Offset(activeWidth, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    }

    // Desenhar Pacman na borda entre ativo e inativo
    if (progress > 0 && progress < 1) {
      final double pacmanX = activeWidth;
      final double radius = size.height;
      final double mouthAngle = 0.5 * animationValue; // Oscila entre 0 e 0.5 radianos
      
      paint.color = activeColor;
      canvas.save();
      canvas.translate(pacmanX, size.height / 2);
      
      // Desenhar Pacman
      final Path pacmanPath = Path();
      pacmanPath.moveTo(0, 0);
      pacmanPath.arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        -mouthAngle, 
        2 * mouthAngle, 
        false
      );
      pacmanPath.close();
      
      canvas.drawPath(pacmanPath, paint);
      canvas.restore();
    }

    // Desenhar parte ativa
    if (activeWidth > 0) {
      paint.color = activeColor;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(activeWidth, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}