import 'package:flutter/material.dart';

// Théme généré par IA
/// Thème personnalisé de l'application Violette
/// Basé sur la maquette avec dégradé violet-rose
class VioletteTheme {
  // Couleurs principales
  static const Color primaryPurple = Color(0xFF6B5DD3);
  static const Color secondaryPurple = Color(0xFF8B7BE8);
  static const Color darkPurple = Color(0xFF4A3BA8);
  static const Color lightPurple = Color(0xFFB8A9F5);
  static const Color pinkAccent = Color(0xFFE89FD9);
  static const Color lightPink = Color(0xFFF5C4E8);

  // Couleurs de fond
  static const Color backgroundColor = Color(0xFF7B6FD8);

  // Couleurs de texte
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFE8E0FF);
  static const Color textHint = Color(0xFFD0C8F0);

  // Couleurs pour les champs de saisie
  static const Color inputBackground =
      Color(0x33FFFFFF); // Blanc à 20% d'opacité
  static const Color inputBorder = Color(0x66FFFFFF); // Blanc à 40% d'opacité
  static const Color inputFocusedBorder = Color(0xFFFFFFFF);

  // Couleurs pour les boutons
  static const Color buttonPrimary = Color(0xFF5B4BC4);
  static const Color buttonHover = Color(0xFF4A3BA8);

  /// Dégradé principal de l'application (violet vers rose)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF6B7FD7), // Bleu-violet en haut
      Color(0xFF8B6FD8), // Violet au milieu
      Color(0xFFB87FD8), // Violet-rose
      Color(0xFFE89FD9), // Rose en bas
    ],
    stops: [0.0, 0.3, 0.6, 1.0],
  );

  /// Dégradé alternatif (plus subtil)
  static const LinearGradient subtleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7B6FD8),
      Color(0xFFA88FD8),
    ],
  );

  /// Thème principal de l'application
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Schéma de couleurs
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: secondaryPurple,
        surface: backgroundColor,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),

      // Couleur de fond par défaut
      scaffoldBackgroundColor: backgroundColor,

      // Typographie
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
        ),
      ),

      // Style des champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackground,

        // Bordures arrondies
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: inputBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: inputBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: inputFocusedBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),

        // Padding interne
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),

        // Style du texte
        hintStyle: const TextStyle(
          color: textHint,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: textPrimary,
          fontSize: 14,
        ),
      ),

      // Style des boutons élevés (bouton principal)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPrimary,
          foregroundColor: textPrimary,
          elevation: 8,
          shadowColor: Colors.black26,

          // Forme arrondie
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          // Padding
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),

          // Taille minimale
          minimumSize: const Size(double.infinity, 56),

          // Style du texte
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Style des boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),

      // Style des boutons outline
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(
            color: inputBorder,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Style des AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: textPrimary,
          size: 24,
        ),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Style des cartes
      cardTheme: CardThemeData(
        color: inputBackground,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Style des icônes
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Style des dividers
      dividerTheme: const DividerThemeData(
        color: inputBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Décoration pour un conteneur avec le dégradé principal
  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: primaryGradient,
    );
  }

  /// Décoration pour un conteneur avec le dégradé et des coins arrondis
  static BoxDecoration gradientBackgroundRounded({double radius = 20}) {
    return BoxDecoration(
      gradient: primaryGradient,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Style pour les conteneurs de logo/icône
  static BoxDecoration get logoContainer {
    return BoxDecoration(
      color: const Color(0x33FFFFFF),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
