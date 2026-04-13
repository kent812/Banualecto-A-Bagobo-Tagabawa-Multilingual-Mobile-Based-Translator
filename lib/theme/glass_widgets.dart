import 'dart:ui';
import 'package:flutter/material.dart';
import 'colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool isDark;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.15,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.border,
    this.boxShadow,
    this.gradient,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.white.withValues(alpha: opacity),
                            Colors.white.withValues(alpha: opacity * 0.5),
                          ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: isDark
                        ? BanualectoColors.glassBorderDark
                        : BanualectoColors.glassBorder,
                    width: 1.5,
                  ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double blur;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.blur = 5.0,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.25),
                          Colors.white.withValues(alpha: 0.15),
                        ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: isDark
                      ? BanualectoColors.glassBorderDark
                      : BanualectoColors.glassBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final bool isDark;

  const GlassButton({
    super.key,
    this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.borderRadius = 16,
    this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: color != null
                      ? [
                          color!.withValues(alpha: 0.9),
                          color!.withValues(alpha: 0.7),
                        ]
                      : isDark
                          ? [
                              BanualectoColors.primaryLight.withValues(alpha: 0.9),
                              BanualectoColors.primaryDark.withValues(alpha: 0.9),
                            ]
                          : [
                              BanualectoColors.primary.withValues(alpha: 0.9),
                              BanualectoColors.primaryDark.withValues(alpha: 0.9),
                            ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (color ?? BanualectoColors.primary).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final bool isDark;

  const GlassInputField({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.style,
    this.hintStyle,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? BanualectoColors.glassBorderDark
                  : BanualectoColors.glassBorder,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: style ??
                TextStyle(
                  color: isDark ? Colors.white : BanualectoColors.textPrimary,
                ),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: hintStyle ??
                  TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : BanualectoColors.textSecondary,
                  ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      _getIcon(prefixIcon!),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : BanualectoColors.primary,
                    )
                  : null,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'search':
        return Icons.search_rounded;
      case 'mic':
        return Icons.mic_rounded;
      default:
        return Icons.search_rounded;
    }
  }
}

class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.3),
                Colors.white.withValues(alpha: 0.2),
              ],
            ),
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(borderRadius)),
            border: Border.all(
              color: BanualectoColors.glassBorder,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final int gradientIndex;

  const GradientBackground({
    super.key,
    required this.child,
    this.isDark = false,
    this.gradientIndex = 0,
  });

  static const List<LinearGradient> backgrounds = [
    LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFB85C38)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF11998e), Color(0xFF38ef7d), Color(0xFF52B788)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFB85C38), Color(0xFFE9A319), Color(0xFFF4C95D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF5C4B99), Color(0xFF8B7EC8), Color(0xFFB85C38)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  static const List<LinearGradient> darkBackgrounds = [
    LinearGradient(
      colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final gradients = isDark ? darkBackgrounds : backgrounds;
    final index = gradientIndex.clamp(0, gradients.length - 1);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? BanualectoColors.glassBgDark
            : BanualectoColors.glassBgGradient,
      ),
      child: child,
    );
  }
}