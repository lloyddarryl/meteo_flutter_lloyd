import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeApp {
  // Couleurs principales
  static const Color bleuPrimaire = Color(0xFF007AFF);
  static const Color violetPrimaire = Color(0xFF5856D6);
  static const Color vertPrimaire = Color(0xFF34C759);
  static const Color orangePrimaire = Color(0xFFFF9500);
  static const Color rougePrimaire = Color(0xFFFF3B30);

  // Couleurs thème clair
  static const Color fondClair = Color(0xFFF2F2F7);
  static const Color surfaceClair = Color(0xFFFFFFFF);
  static const Color texteClair = Color(0xFF000000);
  static const Color texteSecondaireClair = Color(0xFF8E8E93);

  // Couleurs thème sombre
  static const Color fondSombre = Color(0xFF000000);
  static const Color surfaceSombre = Color(0xFF1C1C1E);
  static const Color texteSombre = Color(0xFFFFFFFF);
  static const Color texteSecondaireSombre = Color(0xFF8E8E93);

  // Dégradés météo
  static const LinearGradient degradeEnsoleille = LinearGradient(
    colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient degradePluvieux = LinearGradient(
    colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient degradeNuageux = LinearGradient(
    colors: [Color(0xFF8E8E93), Color(0xFFC7C7CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient degradeNeigeux = LinearGradient(
    colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Thème clair
  static ThemeData get themeClair {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: bleuPrimaire,
      scaffoldBackgroundColor: fondClair,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: texteClair),
        titleTextStyle: TextStyle(
          color: texteClair,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          // Pas de fontFamily pour utiliser la font système
        ),
      ),

      cardTheme: CardTheme(
        color: surfaceClair,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuPrimaire,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            // Pas de fontFamily pour utiliser la font système
          ),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: texteClair,
          // Fonts système par défaut
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: texteClair,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: texteClair,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: texteClair,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: texteClair,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: texteSecondaireClair,
        ),
      ),

      iconTheme: const IconThemeData(
        color: texteClair,
        size: 24,
      ),
    );
  }

  // Thème sombre
  static ThemeData get themeSombre {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: bleuPrimaire,
      scaffoldBackgroundColor: fondSombre,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: texteSombre),
        titleTextStyle: TextStyle(
          color: texteSombre,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardTheme(
        color: surfaceSombre,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuPrimaire,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: texteSombre,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: texteSombre,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: texteSombre,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: texteSombre,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: texteSombre,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: texteSecondaireSombre,
        ),
      ),

      iconTheme: const IconThemeData(
        color: texteSombre,
        size: 24,
      ),
    );
  }

  // Dégradés selon conditions météo
  static LinearGradient obtenirDegradeMeteo(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return degradeEnsoleille;
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return degradePluvieux;
      case 'clouds':
        return degradeNuageux;
      case 'snow':
        return degradeNeigeux;
      default:
        return degradeEnsoleille;
    }
  }
}