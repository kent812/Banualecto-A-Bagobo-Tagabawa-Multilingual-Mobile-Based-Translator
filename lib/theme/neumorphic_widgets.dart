import 'package:flutter/material.dart';

class NeumorphicTheme {
  static const Color lightBase = Color(0xFFE8E8E8);
  static const Color lightShadowLight = Color(0xFFFFFFFF);
  static const Color lightShadowDark = Color(0xFFBEBEBE);

  static const Color darkBase = Color(0xFF2D2D2D);
  static const Color darkShadowLight = Color(0xFF3D3D3D);
  static const Color darkShadowDark = Color(0xFF1D1D1D);

  static Color base(bool isDark) => isDark ? darkBase : lightBase;
  static Color shadowLight(bool isDark) => isDark ? darkShadowLight : lightShadowLight;
  static Color shadowDark(bool isDark) => isDark ? darkShadowDark : lightShadowDark;
}

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isDark;
  final bool isPressed;
  final Color? color;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.borderRadius = 20.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.isDark = false,
    this.isPressed = false,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width,
        height: height,
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: shadowDark.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 5,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: shadowLight.withValues(alpha: 0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 5,
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(6, 6),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

class NeumorphicButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isDark;
  final bool isPressed;
  final Color? color;

  const NeumorphicButton({
    super.key,
    this.onPressed,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.isDark = false,
    this.isPressed = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: padding,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: shadowDark.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: shadowLight.withValues(alpha: 0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-5, -5),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

class NeumorphicIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final bool isDark;
  final bool isPressed;
  final Color? iconColor;
  final Color? backgroundColor;

  const NeumorphicIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.size = 50.0,
    this.isDark = false,
    this.isPressed = false,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = backgroundColor ?? NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: baseColor,
          shape: BoxShape.circle,
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: shadowDark.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: shadowLight.withValues(alpha: 0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-4, -4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white70 : Colors.black54),
          size: size * 0.5,
        ),
      ),
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final bool isDark;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const NeumorphicTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.maxLines = 1,
    this.style,
    this.hintStyle,
    this.isDark = false,
    this.borderRadius = 16.0,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);

    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: shadowLight,
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: shadowDark,
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: style ?? TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle ?? TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          border: InputBorder.none,
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final bool isDark;
  final bool isPressed;
  final Color? color;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.borderRadius = 20.0,
    this.isDark = false,
    this.isPressed = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: shadowDark.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: shadowLight.withValues(alpha: 0.5),
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                    spreadRadius: -2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: shadowLight,
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: shadowDark,
                    offset: const Offset(6, 6),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

class NeumorphicSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isDark;
  final Color? activeColor;

  const NeumorphicSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.isDark = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);
    final accentColor = activeColor ?? const Color(0xFFB85C38);

    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowLight,
              offset: const Offset(-3, -3),
              blurRadius: 6,
            ),
            BoxShadow(
              color: shadowDark,
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: value ? accentColor : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF0F0F0)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: value 
                      ? accentColor.withValues(alpha: 0.5)
                      : (isDark ? Colors.black26 : Colors.black12),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphicProgressBar extends StatelessWidget {
  final double value;
  final double height;
  final bool isDark;
  final Color? backgroundColor;
  final Color? progressColor;

  const NeumorphicProgressBar({
    super.key,
    required this.value,
    this.height = 10.0,
    this.isDark = false,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = backgroundColor ?? NeumorphicTheme.base(isDark);
    final shadowLight = NeumorphicTheme.shadowLight(isDark);
    final shadowDark = NeumorphicTheme.shadowDark(isDark);
    final accentColor = progressColor ?? const Color(0xFFB85C38);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: shadowLight,
            offset: const Offset(-2, -2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: shadowDark,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}