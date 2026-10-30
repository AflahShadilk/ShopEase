import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shop_colors.dart';

abstract final class ShopTheme {
  static ThemeData get light {
    final body = GoogleFonts.manropeTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ShopColors.cream,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: ShopColors.dragonfruit,
        onPrimary: Colors.white,
        secondary: ShopColors.yuzu,
        onSecondary: ShopColors.fig,
        tertiary: ShopColors.tangerine,
        onTertiary: ShopColors.fig,
        error: ShopColors.danger,
        onError: Colors.white,
        surface: ShopColors.paper,
        onSurface: ShopColors.fig,
      ),
      textTheme: body.copyWith(
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 40,
          height: 1.06,
          fontWeight: FontWeight.w700,
          color: ShopColors.fig,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 30,
          height: 1.12,
          fontWeight: FontWeight.w700,
          color: ShopColors.fig,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ShopColors.fig,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          height: 1.5,
          color: ShopColors.fig,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          height: 1.5,
          color: ShopColors.fig,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ShopColors.cream,
        foregroundColor: ShopColors.fig,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ShopColors.paper,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
        hintStyle: const TextStyle(color: ShopColors.muted),
        labelStyle: const TextStyle(color: ShopColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ShopColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ShopColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ShopColors.dragonfruit, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ShopColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ShopColors.danger, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ShopColors.dragonfruit,
          foregroundColor: Colors.white,
          disabledBackgroundColor: ShopColors.stroke,
          disabledForegroundColor: ShopColors.muted,
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
