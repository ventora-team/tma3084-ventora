import 'package:material_ui/material_ui.dart';

// Colours estimated from the phone designs. Adjust the hex values if needed.
const kBackground = Color(0xFF1C1412);
const kSurface = Color(0xFF2E2420);
const kField = Color(0xFF3A2F2A);
const kPink = Color(0xFFD27A8E);
const kCream = Color(0xFFFBF7F2);
const kOnPink = Color(0xFF2A1A1F);

ThemeData mawarTheme() {
  final scheme = ColorScheme.dark(
    primary: kPink,
    onPrimary: kOnPink,
    secondary: kPink,
    onSecondary: kOnPink,
    surface: kSurface,
    onSurface: kCream,
    error: const Color(0xFFFF8A80),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: kSurface,
      foregroundColor: kCream,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: kSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0x80D27A8E)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPink,
        foregroundColor: kOnPink,
        minimumSize: const Size.fromHeight(48),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kCream,
        side: const BorderSide(color: kPink),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kField,
      labelStyle: const TextStyle(color: kCream),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: kSurface,
      selectedColor: kPink,
      labelStyle: TextStyle(color: kCream),
      secondaryLabelStyle: TextStyle(color: kOnPink),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: kSurface,
      indicatorColor: Color(0x66D27A8E),
    ),
  );
}
