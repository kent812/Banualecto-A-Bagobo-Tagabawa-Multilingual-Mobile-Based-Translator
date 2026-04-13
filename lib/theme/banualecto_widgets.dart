import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'colors.dart';

class PaperTexture extends StatelessWidget {
  final Widget child;

  const PaperTexture({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.black.withOpacity(0.02),
          ],
        ).createShader(rect);
      },
      blendMode: BlendMode.overlay,
      child: child,
    );
  }
}

class HandDrawnBorder extends StatelessWidget {
  final Widget child;
  final double strokeWidth;
  final Color color;
  final double blur;

  const HandDrawnBorder({
    super.key,
    required this.child,
    this.strokeWidth = 2,
    this.color = BanualectoColors.primary,
    this.blur = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HandDrawnBorderPainter(
        strokeWidth: strokeWidth,
        color: color,
        blur: blur,
      ),
      child: child,
    );
  }
}

class _HandDrawnBorderPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double blur;

  _HandDrawnBorderPainter({
    required this.strokeWidth,
    required this.color,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final path = Path()
      ..moveTo(5, 5)
      ..quadraticBezierTo(size.width * 0.3, 0, size.width - 5, 5)
      ..quadraticBezierTo(size.width, size.height * 0.3, size.width - 5, size.height - 5)
      ..quadraticBezierTo(size.width * 0.7, size.height, 5, size.height - 5)
      ..quadraticBezierTo(0, size.height * 0.7, 5, 5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WeavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BanualectoColors.primary.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    const spacing = 40.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        path.addOval(Rect.fromCircle(
          center: Offset(i + math.sin(j) * 5, j + math.cos(i) * 5),
          radius: 2,
        ));
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WeaveBackground extends StatelessWidget {
  final Widget child;

  const WeaveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: WeavePatternPainter(),
          size: Size.infinite,
        ),
        child,
      ],
    );
  }
}

class CulturalRipple extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CulturalRipple({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: BanualectoColors.weaveGold.withOpacity(0.2),
                highlightColor: Colors.transparent,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeavePageRoute extends PageRouteBuilder {
  final Widget page;

  WeavePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutQuint;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = BorderRadius.circular(20);
    final defaultBoxShadow = [
      BoxShadow(
        color: BanualectoColors.primary.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ];

    return CulturalRipple(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? BanualectoColors.surface,
          borderRadius: borderRadius ?? defaultRadius,
          boxShadow: boxShadow ?? defaultBoxShadow,
        ),
        child: child,
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = BorderRadius.circular(30);
    final colors = gradientColors ?? [BanualectoColors.primary, BanualectoColors.primaryDark];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: borderRadius ?? defaultRadius,
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blur;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 10,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = BorderRadius.circular(30);

    return ClipRRect(
      borderRadius: borderRadius ?? defaultRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: borderRadius ?? defaultRadius,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AnimatedCategoryCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final int index;

  const AnimatedCategoryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    required this.index,
  });

  @override
  State<AnimatedCategoryCard> createState() => _AnimatedCategoryCardState();
}

class _AnimatedCategoryCardState extends State<AnimatedCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 35,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

class FadeSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset beginOffset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.delay = Duration.zero,
    this.beginOffset = const Offset(0, 0.3),
  });

  @override
  State<FadeSlideTransition> createState() => _FadeSlideTransitionState();
}

class _FadeSlideTransitionState extends State<FadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}