import 'dart:ui';
import 'package:flutter/material.dart';

class WavyBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const WavyBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<WavyBottomNavBar> createState() => _WavyBottomNavBarState();
}

class _WavyBottomNavBarState extends State<WavyBottomNavBar> {
  // Bar colors - warm earth tone
  static const Color _barColor = Color(0xFF8B4513);
  static const Color _inactiveColor = Color(0xFFD4C4B5);
  static const double fabSize = 60.0;
  static const double barHeight = 64.0;
  static const double notchRadius = 38.0;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: barHeight + fabSize / 2 + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: _CurvedBarPainter(
                color: _barColor,
                notchRadius: notchRadius,
                barHeight: barHeight + bottomPadding,
              ),
              child: SizedBox(height: barHeight + bottomPadding),
            ),
          ),
          Positioned(
            bottom: bottomPadding,
            left: 0,
            width: MediaQuery.of(context).size.width / 2 - notchRadius - 8,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton(
                  icon: Icons.calendar_today_rounded,
                  label: 'Calendar',
                  index: 1,
                  selectedIndex: widget.selectedIndex,
                  onTap: widget.onTap,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: bottomPadding,
            right: 0,
            width: MediaQuery.of(context).size.width / 2 - notchRadius - 8,
            height: barHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabButton(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  index: 2,
                  selectedIndex: widget.selectedIndex,
                  onTap: widget.onTap,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: barHeight / 2 - fabSize / 2 + bottomPadding / 2 + 20,
            left: MediaQuery.of(context).size.width / 2 - fabSize / 2,
            child: GestureDetector(
              onTap: () => widget.onTap(0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(fabSize / 2),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.selectedIndex == 0
                            ? [
                                Colors.white.withValues(alpha: 0.4),
                                Colors.white.withValues(alpha: 0.25),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.25),
                                Colors.white.withValues(alpha: 0.15),
                              ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.home_rounded,
                      color: widget.selectedIndex == 0 ? Colors.white : _inactiveColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurvedBarPainter extends CustomPainter {
  final Color color;
  final double notchRadius;
  final double barHeight;

  const _CurvedBarPainter({
    required this.color,
    required this.notchRadius,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const double margin = 8.0;
    final double r = notchRadius + margin;
    const double spread = 20.0;

    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, barHeight + notchRadius));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(centerX - r - spread, 0)
      ..cubicTo(
        centerX - r - spread / 2, 0,
        centerX - r, -4,
        centerX - r + 4, notchRadius * 0.6,
      )
      ..arcToPoint(
        Offset(centerX + r - 4, notchRadius * 0.6),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..cubicTo(
        centerX + r, -4,
        centerX + r + spread / 2, 0,
        centerX + r + spread, 0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, barHeight)
      ..lineTo(0, barHeight)
      ..close();

    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);
    canvas.drawPath(path, glassPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_CurvedBarPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.notchRadius != notchRadius ||
      oldDelegate.barHeight != barHeight;
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const Color _activeColor = Color(0xFFFFFFFF);
  static const Color _inactiveColor = Color(0xFFD4C4B5);

  const _TabButton({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? Colors.white.withValues(alpha: 0.15) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? _activeColor : _inactiveColor,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? _activeColor : _inactiveColor,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
