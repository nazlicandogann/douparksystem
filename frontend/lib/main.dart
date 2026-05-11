import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const DouParkApp());
}

class DouParkApp extends StatelessWidget {
  const DouParkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DouPark',
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.dark,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      home: const MainNavigation(),
    );
  }

  ThemeData _darkTheme() {
    const bg        = Color(0xFF0F0F0F);
    const surface   = Color(0xFF1A1A1A);
    const card      = Color(0xFF222222);
    const primary   = Color(0xFFE53935);
    const onPrimary = Colors.white;
    const onBg      = Color(0xFFF5F5F5);
    const onSurface = Color(0xFFEEEEEE);
    const grey      = Color(0xFF9E9E9E);
    const border    = Color(0xFF2E2E2E);

    final base = ThemeData.dark();

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary:   primary,
        secondary: Color(0xFFEF5350),
        surface:   surface,
        background: bg,
        onPrimary:  onPrimary,
        onBackground: onBg,
        onSurface:  onSurface,
        error:      Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor:      onBg,
        displayColor:   onBg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111111),
        foregroundColor: onBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onBg),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintStyle: const TextStyle(color: grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      iconTheme: const IconThemeData(color: onSurface),
      dividerColor: border,
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF2A2A2A),
        contentTextStyle: TextStyle(color: onBg),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF111111),
        selectedItemColor: primary,
        unselectedItemColor: grey,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? primary : grey),
        trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected)
                ? primary.withOpacity(0.4)
                : border),
      ),
    );
  }

  ThemeData _lightTheme() => ThemeData(
    primarySwatch: Colors.red,
    textTheme: GoogleFonts.poppinsTextTheme(),
  );
}