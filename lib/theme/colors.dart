import 'package:flutter/material.dart';

import 'dart:ui';

class BanualectoColors {
  // Primary - Warm terracotta inspired by Bagobo woven textiles
  static const Color primary = Color(0xFFB85C38);
  static const Color primaryLight = Color(0xFFD4845A);
  static const Color primaryDark = Color(0xFF8A3A1A);
  static const Color primaryDeep = Color(0xFF5E2510);

  // Secondary - Deep forest green from Mindanao highlands
  static const Color secondary = Color(0xFF2D6A4F);
  static const Color secondaryLight = Color(0xFF52B788);
  static const Color secondaryDark = Color(0xFF1B4332);

  // Accent - Warm gold from traditional Bagobo beadwork
  static const Color accent = Color(0xFFE9A319);
  static const Color accentLight = Color(0xFFF4C95D);
  static const Color accentDark = Color(0xFFC4850C);

  // Tertiary - Indigo from traditional dyes
  static const Color tertiary = Color(0xFF5C4B99);
  static const Color tertiaryLight = Color(0xFF8B7EC8);

  // Glassmorphism colors
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassWhiteLight = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x4DFFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Glassmorphism dark mode
  static const Color glassWhiteDark = Color(0x1AFFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);

  // Backgrounds - Warm parchment tones
  static const Color background = Color(0xFFFAF6F0);
  static const Color backgroundAlt = Color(0xFFF3EDE4);
  static const Color surface = Color(0xFFFFFBF7);
  static const Color surfaceDark = Color(0xFFEDE3D6);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF1A1108);
  static const Color textSecondary = Color(0xFF5C4F3D);
  static const Color textTertiary = Color(0xFF8A7B68);
  static const Color textLight = Color(0xFFB0A290);

  // Cultural accent colors
  static const Color weaveGold = Color(0xFFD4A843);
  static const Color earthRed = Color(0xFFC0392B);
  static const Color mountainMist = Color(0xFF7D8B91);
  static const Color riverBlue = Color(0xFF3A7CA5);
  static const Color bamboo = Color(0xFFB8C99E);
  static const Color soil = Color(0xFF6B4423);

  // Surface & card
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardHighlight = Color(0xFFFFF5EB);
  static const Color divider = Color(0xFFE8DDD0);
  static const Color border = Color(0xFFD9CEC1);

  // Semantic colors
  static const Color success = Color(0xFF2D6A4F);
  static const Color successLight = Color(0xFFD8F3DC);
  static const Color warning = Color(0xFFE9A319);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color error = Color(0xFFC0392B);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color info = Color(0xFF3A7CA5);
  static const Color infoLight = Color(0xFFD1ECF1);

  // Category colors
  static const Color catGreetings = Color(0xFFE9A319);
  static const Color catFamily = Color(0xFFC0392B);
  static const Color catNumbers = Color(0xFF3A7CA5);
  static const Color catColors = Color(0xFF8B7EC8);
  static const Color catAnimals = Color(0xFF52B788);
  static const Color catFood = Color(0xFFD4845A);
  static const Color catNature = Color(0xFF2D6A4F);
  static const Color catActions = Color(0xFFB85C38);
  static const Color catEmotions = Color(0xFFE07A5F);
  static const Color catTime = Color(0xFF5C4B99);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFB85C38), Color(0xFFE9A319)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF2D6A4F), Color(0xFF52B788)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFB85C38), Color(0xFF8A3A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE9A319), Color(0xFFF4C95D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFF5C4B99), Color(0xFFB85C38), Color(0xFFE9A319)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism background gradients
  static const LinearGradient glassBgGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFB85C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBgGradientAlt = LinearGradient(
    colors: [Color(0xFF11998e), Color(0xFF38ef7d), Color(0xFF52B788)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBgWarm = LinearGradient(
    colors: [Color(0xFFB85C38), Color(0xFFE9A319), Color(0xFFF4C95D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBgPurple = LinearGradient(
    colors: [Color(0xFF5C4B99), Color(0xFF8B7EC8), Color(0xFFB85C38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBgDark = LinearGradient(
    colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassBgDarkAlt = LinearGradient(
    colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: primary.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppColors {
  static const Color primary = BanualectoColors.primary;
  static const Color primaryLight = BanualectoColors.primaryLight;
  static const Color primaryDark = BanualectoColors.primaryDark;
  static const Color secondary = BanualectoColors.secondary;
  static const Color accent = BanualectoColors.accent;
  static const Color tertiary = BanualectoColors.tertiary;

  static const Color background = BanualectoColors.background;
  static const Color surface = BanualectoColors.surface;
  static const Color textPrimary = BanualectoColors.textPrimary;
  static const Color textSecondary = BanualectoColors.textSecondary;

  static const Color success = BanualectoColors.success;
  static const Color warning = BanualectoColors.warning;
  static const Color error = BanualectoColors.error;
  static const Color info = BanualectoColors.info;

  static const Color cardBackground = BanualectoColors.cardBackground;
  static const Color divider = BanualectoColors.divider;

  static const Color earthRed = BanualectoColors.earthRed;
  static const Color textLight = BanualectoColors.textLight;
  static const Color mountainMist = BanualectoColors.mountainMist;
  static const Color weaveGold = BanualectoColors.weaveGold;
  static const Color riverBlue = BanualectoColors.riverBlue;
  static const Color bamboo = BanualectoColors.bamboo;

  static const LinearGradient primaryGradient = BanualectoColors.primaryGradient;
  static const LinearGradient cardGradient = BanualectoColors.cardGradient;
  static const LinearGradient accentGradient = BanualectoColors.accentGradient;
  static const LinearGradient warmGradient = BanualectoColors.warmGradient;
  static const LinearGradient sunsetGradient = BanualectoColors.sunsetGradient;
}