import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PalashVaaniApp());
}

class PalashVaaniApp extends StatelessWidget {
  const PalashVaaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'PALASH-Vaani (पलाश-वाणी)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E4D2B), // Forest Green
            primary: const Color(0xFF1E4D2B),
            secondary: const Color(0xFFD96B27), // Terracotta
            tertiary: const Color(0xFF2A9D8F), // Teal
            surface: const Color(0xFFF8FAFC),
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
