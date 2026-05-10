import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/chat_service.dart';
import 'services/speech_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatService()),
        ChangeNotifierProvider(create: (_) => SpeechService()),
      ],
      child: const VaaniSetuApp(),
    ),
  );
}

class VaaniSetuApp extends StatelessWidget {
  const VaaniSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaaniSetu - வாணி சேது',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    // VaaniSetu brand: Deep saffron + Tamil temple gold + earthy greens
    const primaryColor = Color(0xFFE85D04);   // Saffron orange
    const secondaryColor = Color(0xFF370617); // Deep maroon
    const accentColor = Color(0xFFFAA307);    // Temple gold
    const bgColor = Color(0xFF0D0D0D);        // Deep dark

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: Color(0xFF1A1A1A),
        background: bgColor,
        onPrimary: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.notoSansTamilTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFCCCCCC),
            fontSize: 14,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
