import 'package:flutter/material.dart';

class AppTheme {

  // ── Brand Colors ─────────────────────────────────
  static const Color primaryColor       = Color(0xFF6C63FF);
  static const Color primaryDark        = Color(0xFF4B44CC);
  static const Color primaryLight       = Color(0xFF9D97FF);
  static const Color secondaryColor     = Color(0xFF03DAC6);

  // ── Light Theme Colors ───────────────────────────
  static const Color lightBackground    = Color(0xFFF6F6FB);
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightSurfaceVar    = Color(0xFFEEEEF8);
  static const Color lightCard          = Color(0xFFFFFFFF);
  static const Color lightTextPrimary   = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B6B80);
  static const Color lightOutline       = Color(0xFFE0E0F0);

  // ── Dark Theme Colors ────────────────────────────
  static const Color darkBackground     = Color(0xFF0D0D1A);
  static const Color darkSurface        = Color(0xFF1A1A2E);
  static const Color darkSurfaceVar     = Color(0xFF222238);
  static const Color darkCard           = Color(0xFF1E1E32);
  static const Color darkTextPrimary    = Color(0xFFE8E8FF);
  static const Color darkTextSecondary  = Color(0xFF9090B0);
  static const Color darkOutline        = Color(0xFF2E2E4E);

  // ── Semantic Colors ──────────────────────────────
  static const Color accentGreen        = Color(0xFF00C48C);
  static const Color accentOrange       = Color(0xFFFF8C00);
  static const Color accentRed          = Color(0xFFFF4757);
  static const Color accentBlue         = Color(0xFF1E90FF);
  static const Color accentPurple       = Color(0xFF9C27B0);
  static const Color accentYellow       = Color(0xFFFFD700);

  // ── Font Sizes ───────────────────────────────────
  static const double fontXSmall        = 10.0;
  static const double fontSmall         = 12.0;
  static const double fontMedium        = 14.0;
  static const double fontLarge         = 18.0;
  static const double fontHeading       = 24.0;
  static const double fontDisplay       = 32.0;

  // ── Spacing ──────────────────────────────────────
  static const double spacingXSmall     = 4.0;
  static const double spacingSmall      = 8.0;
  static const double spacingMedium     = 16.0;
  static const double spacingLarge      = 24.0;
  static const double spacingXLarge     = 32.0;
  static const double spacingXXLarge    = 48.0;

  // ── Border Radius ────────────────────────────────
  static const double radiusXSmall      = 4.0;
  static const double radiusSmall       = 8.0;
  static const double radiusMedium      = 12.0;
  static const double radiusLarge       = 16.0;
  static const double radiusXLarge      = 24.0;
  static const double radiusXXLarge     = 32.0;
  static const double radiusCircle      = 100.0;

  // ── Elevation ────────────────────────────────────
  static const double elevationNone     = 0.0;
  static const double elevationLow      = 1.0;
  static const double elevationMedium   = 3.0;
  static const double elevationHigh     = 6.0;

  // ─────────────────────────────────────────────────
  // LIGHT THEME — Material 3
  // ─────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',

      // ── Color Scheme ──────────────────────────────
      colorScheme: const ColorScheme.light(
        primary:          primaryColor,
        onPrimary:        Colors.white,
        primaryContainer: Color(0xFFE8E7FF),
        onPrimaryContainer: Color(0xFF21005D),
        secondary:        secondaryColor,
        onSecondary:      Colors.white,
        secondaryContainer: Color(0xFFCEFAF5),
        onSecondaryContainer: Color(0xFF00201C),
        tertiary:         accentOrange,
        onTertiary:       Colors.white,
        error:            accentRed,
        onError:          Colors.white,
        errorContainer:   Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        background:       lightBackground,
        onBackground:     lightTextPrimary,
        surface:          lightSurface,
        onSurface:        lightTextPrimary,
        surfaceVariant:   lightSurfaceVar,
        onSurfaceVariant: lightTextSecondary,
        outline:          lightOutline,
        shadow:           Colors.black,
        inverseSurface:   darkSurface,
        onInverseSurface: darkTextPrimary,
        inversePrimary:   primaryLight,
      ),

      // ── Scaffold ──────────────────────────────────
      scaffoldBackgroundColor: lightBackground,

      // ── AppBar — M3 ───────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:  lightSurface,
        foregroundColor:  lightTextPrimary,
        elevation:        elevationNone,
        scrolledUnderElevation: elevationLow,
        surfaceTintColor: primaryColor,
        centerTitle:      false,
        titleTextStyle: TextStyle(
          fontFamily:   'Poppins',
          color:        lightTextPrimary,
          fontSize:     fontLarge,
          fontWeight:   FontWeight.w700,
          letterSpacing: 0.0,
        ),
        iconTheme: IconThemeData(
          color: lightTextPrimary,
          size:  24,
        ),
      ),

      // ── Navigation Bar — M3 ───────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:          lightSurface,
        indicatorColor:           primaryColor.withOpacity(0.12),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: primaryColor,
              size: 24,
            );
          }
          return const IconThemeData(
            color: lightTextSecondary,
            size: 24,
          );
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontFamily:  'Poppins',
              fontSize:    fontSmall,
              fontWeight:  FontWeight.w600,
              color:       primaryColor,
            );
          }
          return const TextStyle(
            fontFamily: 'Poppins',
            fontSize:   fontSmall,
            color:      lightTextSecondary,
          );
        }),
        elevation:        elevationMedium,
        height:           64,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Bottom Navigation Bar — M2 fallback ───────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      lightSurface,
        selectedItemColor:    primaryColor,
        unselectedItemColor:  lightTextSecondary,
        selectedLabelStyle: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontSmall,
          fontWeight:  FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontSmall,
        ),
        elevation:  elevationMedium,
        type:       BottomNavigationBarType.fixed,
        showSelectedLabels:   true,
        showUnselectedLabels: true,
      ),

      // ── Card — M3 ─────────────────────────────────
      cardTheme: CardThemeData(
        color:        lightCard,
        surfaceTintColor: primaryColor.withOpacity(0.03),
        elevation:    elevationNone,
        shadowColor:  Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(
            color: lightOutline,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input Decoration — M3 ─────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:           true,
        fillColor:        lightSurfaceVar,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: lightOutline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: lightOutline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: accentRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: accentRed,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical:   spacingMedium,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color:      lightTextSecondary,
          fontSize:   fontMedium,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color:      lightTextSecondary,
          fontSize:   fontMedium,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color:      primaryColor,
          fontSize:   fontSmall,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor:  lightTextSecondary,
        suffixIconColor:  lightTextSecondary,
      ),

      // ── Elevated Button — M3 ──────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:  primaryColor,
          foregroundColor:  Colors.white,
          elevation:        elevationNone,
          shadowColor:      Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical:   spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w600,
            letterSpacing: 0.2,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Filled Button — M3 ────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical:   spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Outlined Button — M3 ──────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical:   spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Text Button — M3 ──────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w500,
          ),
        ),
      ),

      // ── Chip — M3 ─────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:      lightSurfaceVar,
        selectedColor:        primaryColor.withOpacity(0.15),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontSmall,
          fontWeight: FontWeight.w500,
          color:      lightTextPrimary,
        ),
        side: const BorderSide(
          color: lightOutline,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircle),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSmall,
          vertical:   spacingXSmall,
        ),
      ),

      // ── Dialog — M3 ───────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:  lightCard,
        surfaceTintColor: primaryColor.withOpacity(0.05),
        elevation:        elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
        titleTextStyle: const TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontLarge,
          fontWeight:  FontWeight.w700,
          color:       lightTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontMedium,
          color:      lightTextSecondary,
        ),
      ),

      // ── Bottom Sheet — M3 ─────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:  lightCard,
        surfaceTintColor: Colors.transparent,
        elevation:        elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: lightTextSecondary,
        dragHandleSize:  Size(40, 4),
      ),

      // ── Snack Bar — M3 ────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:  darkSurface,
        contentTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontMedium,
          color:      darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior:   SnackBarBehavior.floating,
        elevation:  elevationMedium,
      ),

      // ── Switch — M3 ───────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Colors.white;
          }
          return lightTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return lightOutline;
        }),
      ),

      // ── Divider ───────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     lightOutline,
        thickness: 1,
        space:     1,
      ),

      // ── List Tile ─────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical:   spacingXSmall,
        ),
        titleTextStyle: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w500,
          color:       lightTextPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontSmall,
          color:      lightTextSecondary,
        ),
      ),

      // ── Text Theme ────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontDisplay,
          fontWeight:  FontWeight.w700,
          color:       lightTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontHeading,
          fontWeight:  FontWeight.w700,
          color:       lightTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontLarge,
          fontWeight:  FontWeight.w600,
          color:       lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontLarge,
          fontWeight:  FontWeight.w600,
          color:       lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w500,
          color:       lightTextPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontSmall,
          fontWeight:  FontWeight.w500,
          color:       lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w400,
          color:       lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontSmall,
          fontWeight:  FontWeight.w400,
          color:       lightTextSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontXSmall,
          fontWeight:  FontWeight.w400,
          color:       lightTextSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w600,
          color:       lightTextPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontXSmall,
          fontWeight:  FontWeight.w500,
          color:       lightTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // DARK THEME — Material 3
  // ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',

      // ── Color Scheme ──────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:          primaryLight,
        onPrimary:        Color(0xFF21005D),
        primaryContainer: primaryDark,
        onPrimaryContainer: Color(0xFFE8E7FF),
        secondary:        secondaryColor,
        onSecondary:      Color(0xFF00201C),
        secondaryContainer: Color(0xFF004D47),
        onSecondaryContainer: Color(0xFFCEFAF5),
        tertiary:         accentOrange,
        onTertiary:       Colors.white,
        error:            Color(0xFFFFB4AB),
        onError:          Color(0xFF690005),
        errorContainer:   Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        background:       darkBackground,
        onBackground:     darkTextPrimary,
        surface:          darkSurface,
        onSurface:        darkTextPrimary,
        surfaceVariant:   darkSurfaceVar,
        onSurfaceVariant: darkTextSecondary,
        outline:          darkOutline,
        shadow:           Colors.black,
        inverseSurface:   lightSurface,
        onInverseSurface: lightTextPrimary,
        inversePrimary:   primaryColor,
      ),

      // ── Scaffold ──────────────────────────────────
      scaffoldBackgroundColor: darkBackground,

      // ── AppBar — M3 ───────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:  darkSurface,
        foregroundColor:  darkTextPrimary,
        elevation:        elevationNone,
        scrolledUnderElevation: elevationLow,
        surfaceTintColor: primaryLight,
        centerTitle:      false,
        titleTextStyle: TextStyle(
          fontFamily:   'Poppins',
          color:        darkTextPrimary,
          fontSize:     fontLarge,
          fontWeight:   FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: darkTextPrimary,
          size:  24,
        ),
      ),

      // ── Navigation Bar — M3 ───────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:    darkSurface,
        indicatorColor:     primaryLight.withOpacity(0.15),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(
              color: primaryLight,
              size: 24,
            );
          }
          return const IconThemeData(
            color: darkTextSecondary,
            size: 24,
          );
        }),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              fontFamily:  'Poppins',
              fontSize:    fontSmall,
              fontWeight:  FontWeight.w600,
              color:       primaryLight,
            );
          }
          return const TextStyle(
            fontFamily: 'Poppins',
            fontSize:   fontSmall,
            color:      darkTextSecondary,
          );
        }),
        elevation:     elevationMedium,
        height:        64,
        labelBehavior:
            NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Bottom Navigation Bar — M2 fallback ───────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      darkSurface,
        selectedItemColor:    primaryLight,
        unselectedItemColor:  darkTextSecondary,
        selectedLabelStyle: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontSmall,
          fontWeight:  FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontSmall,
        ),
        elevation:  elevationMedium,
        type:       BottomNavigationBarType.fixed,
      ),

      // ── Card — M3 ─────────────────────────────────
      cardTheme: CardThemeData(
        color:        darkCard,
        surfaceTintColor: primaryLight.withOpacity(0.03),
        elevation:    elevationNone,
        shadowColor:  Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(
            color: darkOutline,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input Decoration — M3 ─────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: darkSurfaceVar,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: darkOutline,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: darkOutline,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: primaryLight,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(
            color: accentRed,
            width: 1,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical:   spacingMedium,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color:      darkTextSecondary,
          fontSize:   fontMedium,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color:      darkTextSecondary,
          fontSize:   fontMedium,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color:      primaryLight,
          fontSize:   fontSmall,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor:  darkTextSecondary,
        suffixIconColor:  darkTextSecondary,
      ),

      // ── Elevated Button — M3 ──────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: darkBackground,
          elevation:       elevationNone,
          shadowColor:     Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical:   spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Filled Button — M3 ────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: darkBackground,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical:   spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Outlined Button — M3 ──────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          side: const BorderSide(
            color: primaryLight,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLarge,
            vertical:   spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w600,
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),

      // ── Text Button — M3 ──────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          textStyle: const TextStyle(
            fontFamily:  'Poppins',
            fontSize:    fontMedium,
            fontWeight:  FontWeight.w500,
          ),
        ),
      ),

      // ── Chip — M3 ─────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:  darkSurfaceVar,
        selectedColor:    primaryLight.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontSmall,
          fontWeight: FontWeight.w500,
          color:      darkTextPrimary,
        ),
        side: const BorderSide(
          color: darkOutline,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircle),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSmall,
          vertical:   spacingXSmall,
        ),
      ),

      // ── Dialog — M3 ───────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor:  darkCard,
        surfaceTintColor: primaryLight.withOpacity(0.05),
        elevation:        elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
        titleTextStyle: const TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontLarge,
          fontWeight:  FontWeight.w700,
          color:       darkTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontMedium,
          color:      darkTextSecondary,
        ),
      ),

      // ── Bottom Sheet — M3 ─────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:  darkCard,
        surfaceTintColor: Colors.transparent,
        elevation:        elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXLarge),
          ),
        ),
        showDragHandle:  true,
        dragHandleColor: darkTextSecondary,
        dragHandleSize:  Size(40, 4),
      ),

      // ── Snack Bar — M3 ────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceVar,
        contentTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontMedium,
          color:      darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        behavior:  SnackBarBehavior.floating,
        elevation: elevationMedium,
      ),

      // ── Switch — M3 ───────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkBackground;
          }
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryLight;
          }
          return darkOutline;
        }),
      ),

      // ── Divider ───────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     darkOutline,
        thickness: 1,
        space:     1,
      ),

      // ── List Tile ─────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical:   spacingXSmall,
        ),
        titleTextStyle: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w500,
          color:       darkTextPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize:   fontSmall,
          color:      darkTextSecondary,
        ),
      ),

      // ── Text Theme ────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontDisplay,
          fontWeight:  FontWeight.w700,
          color:       darkTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontHeading,
          fontWeight:  FontWeight.w700,
          color:       darkTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineMedium: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontLarge,
          fontWeight:  FontWeight.w600,
          color:       darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontLarge,
          fontWeight:  FontWeight.w600,
          color:       darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w500,
          color:       darkTextPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontSmall,
          fontWeight:  FontWeight.w500,
          color:       darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w400,
          color:       darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontSmall,
          fontWeight:  FontWeight.w400,
          color:       darkTextSecondary,
        ),
        bodySmall: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontXSmall,
          fontWeight:  FontWeight.w400,
          color:       darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontMedium,
          fontWeight:  FontWeight.w600,
          color:       darkTextPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily:  'Poppins',
          fontSize:    fontXSmall,
          fontWeight:  FontWeight.w500,
          color:       darkTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // CONTEXT HELPERS
  // ─────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color backgroundColor(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color cardColor(BuildContext context) =>
      isDark(context) ? darkCard : lightCard;

  static Color surfaceColor(BuildContext context) =>
      isDark(context) ? darkSurface : lightSurface;

  static Color surfaceVariant(BuildContext context) =>
      isDark(context) ? darkSurfaceVar : lightSurfaceVar;

  static Color textPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color outlineColor(BuildContext context) =>
      isDark(context) ? darkOutline : lightOutline;

  static Color primaryAccent(BuildContext context) =>
      isDark(context) ? primaryLight : primaryColor;
}
