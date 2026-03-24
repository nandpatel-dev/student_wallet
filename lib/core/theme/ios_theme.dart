import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class IOSTheme {
  // ── Glassmorphism Config ────────────────────────
  static const double glassBlur = 20.0;
  static const double glassOpacityLight = 0.7;
  static const double glassOpacityDark = 0.4;
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // ── Brand Colors (iOS style) ────────────────────
  static const CupertinoDynamicColor primaryBlue = CupertinoColors.systemBlue;
  static const CupertinoDynamicColor primaryLabel = CupertinoColors.label;
  static const CupertinoDynamicColor secondaryLabel = CupertinoColors.secondaryLabel;
  static const CupertinoDynamicColor systemBackground = CupertinoColors.systemBackground;
  static const CupertinoDynamicColor secondarySystemBackground = CupertinoColors.secondarySystemBackground;

  // ── Spacing & Radius ────────────────────────────
  static const double radiusM = 12.0;
  static const double radiusL = 20.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;

  // ── Cupertino Theme ─────────────────────────────
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: Color(0xFFF2F2F7), // iOS Grouped Background
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryBlue,
      ),
    );
  }

  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: CupertinoColors.black,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryBlue,
      ),
    );
  }

  // ── Glass Container Builder ─────────────────────
  static Widget glassContainer({
    required Widget child,
    double borderRadius = radiusM,
    bool showBorder = true,
    BuildContext? context,
    EdgeInsets? padding,
    double? width,
    double? height,
  }) {
    final isDark = context != null && CupertinoTheme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(paddingM),
          decoration: BoxDecoration(
            color: isDark 
                ? CupertinoColors.systemGrey6.darkColor.withOpacity(glassOpacityDark)
                : CupertinoColors.white.withOpacity(glassOpacityLight),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder ? Border.all(
              color: isDark ? glassBorderDark : glassBorderLight,
              width: 0.5, // Thin hairline
            ) : null,
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
