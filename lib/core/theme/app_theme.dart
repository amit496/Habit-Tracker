import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'brand.dart';

class AppTheme {
  static const primary = Brand.accent;
  static const primaryDark = Brand.accentDark;
  static const secondary = Brand.accentDeep;
  static const danger = Color(0xFFEF4444);

  static const lightBg = Color(0xFFFAFAFA);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightMuted = Color(0xFF71717A);
  static const lightBorder = Color(0xFFE4E4E7);
  static const lightText = Color(0xFF18181B);

  static const darkBg = Color(0xFF09090B);
  static const darkCard = Color(0xFF18181B);
  static const darkCardLight = Color(0xFF27272A);
  static const darkBorder = Color(0xFF3F3F46);
  static const darkMuted = Color(0xFFA1A1AA);
  static const darkText = Color(0xFFFAFAFA);

  static Color primaryFor(BuildContext context) => Brand.accentFor(context);

  static Color mutedText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkMuted
        : lightMuted;
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? darkCard : lightCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? darkBorder : lightBorder),
    );
  }

  static ThemeData get lightTheme {
    final scheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: lightBg,
      onSurface: lightText,
      onSurfaceVariant: lightMuted,
      outline: lightBorder,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: lightText,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: lightText,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightText,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: lightMuted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: lightCard,
        indicatorColor: primary.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? primary : lightMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? primary : lightMuted,
            size: 24,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightCard,
        selectedColor: primary.withValues(alpha: 0.12),
        checkmarkColor: primary,
        side: const BorderSide(color: lightBorder),
        labelStyle: const TextStyle(fontSize: 13, color: lightText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder),
        ),
      ),
      dividerColor: lightBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.dark(
      primary: primaryDark,
      onPrimary: darkBg,
      secondary: primaryDark,
      surface: darkBg,
      onSurface: darkText,
      onSurfaceVariant: darkMuted,
      outline: darkBorder,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkText,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkText,
          letterSpacing: -0.5,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: darkMuted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: darkCard,
        indicatorColor: primaryDark.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            color: sel ? primaryDark : darkMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final sel = states.contains(WidgetState.selected);
          return IconThemeData(
            color: sel ? primaryDark : darkMuted,
            size: 24,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryDark,
        foregroundColor: darkBg,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: darkBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCardLight,
        selectedColor: primaryDark.withValues(alpha: 0.22),
        checkmarkColor: primaryDark,
        side: const BorderSide(color: darkBorder),
        labelStyle: const TextStyle(fontSize: 13, color: darkText),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      dividerColor: darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardLight,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
      ),
    );
  }

  static SystemUiOverlayStyle overlayFor(bool isDark) => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      );
}
