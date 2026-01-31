import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/theme_controller.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'screens/service_suspended_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PKSonsApp());
}

class PKSonsApp extends StatefulWidget {
  const PKSonsApp({super.key});

  @override
  State<PKSonsApp> createState() => _PKSonsAppState();
}

class _PKSonsAppState extends State<PKSonsApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  // App Access Control
  static const String _appId = "yash_traders"; 
  bool _isSuspended = false;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _setupAccessControl();
  }

  void _setupAccessControl() {
    try {
      final ref = FirebaseDatabase.instance.ref("apps/$_appId");
      _statusSubscription = ref.onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final bool isActive = data['active'] == true;
          final String reason = data['reason']?.toString() ?? "Service Temporarily Suspended";
          
          if (!isActive && !_isSuspended) {
            setState(() => _isSuspended = true);
            _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => ServiceSuspendedScreen(reason: reason)),
              (route) => false,
            );
          } else if (isActive && _isSuspended) {
             setState(() => _isSuspended = false);
             _navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SplashScreen()),
              (route) => false,
            );
          }
        }
      });
    } catch (e) {
      debugPrint("Error in access control: $e");
    }
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController(),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Yash Traders',
          themeMode: ThemeController().themeMode,
          
          // LIGHT THEME - Emerald & Champagne
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF0F3D2E), // Emerald Green
            scaffoldBackgroundColor: const Color(0xFFF2E6CF), // Champagne Beige
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F3D2E), // Emerald Green
              secondary: Color(0xFFC9B37E), // Soft Gold (Accent)
              surface: Color(0xFFFFF9E6), // Lighter Champagne for cards
              background: Color(0xFFF2E6CF), // Champagne Beige
              onBackground: Color(0xFF1C1C1C), // Dark Text
              onSurface: Color(0xFF1C1C1C), // Dark Text
              onPrimary: Colors.white, // Text on Emerald buttons
              onSecondary: Colors.black, // Text on Gold accents
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFFFFF9E6), // Lighter Champagne
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF2E6CF), // Match background
              foregroundColor: Color(0xFFC9B37E), // Emerald Text/Icons -> Gold for visibility on Green Header
              elevation: 0,
              centerTitle: true,
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(color: Color(0xFF0F3D2E), fontSize: 32, fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(color: Color(0xFF0F3D2E), fontSize: 24, fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(color: Color(0xFF1C1C1C), fontSize: 16),
              bodyMedium: TextStyle(color: Color(0xFF1C1C1C), fontSize: 14), // Using slightly muted black if needed, but 1C1C1C is fine
            ),
            dividerColor: const Color(0xFFC9B37E).withOpacity(0.3), // Soft Gold divider
            useMaterial3: true,
          ),

          // DARK THEME - Emerald & Champagne
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: const Color(0xFF0F3D2E), // Emerald Green
            scaffoldBackgroundColor: const Color(0xFF081F17), // Deep Emerald Dark
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0F3D2E), // Emerald Green
              secondary: Color(0xFFC9B37E), // Soft Gold (Accent)
              surface: Color(0xFF0C2B20), // Slightly lighter dark emerald for cards
              background: Color(0xFF081F17), // Deep Emerald Dark
              onBackground: Color(0xFFF2E6CF), // Champagne Text
              onSurface: Color(0xFFF2E6CF), // Champagne Text
              onPrimary: Color(0xFFF2E6CF), // Champagne text on buttons
              onSecondary: Colors.black,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF0C2B20), // Lighter Emerald Dark
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF081F17),
              foregroundColor: Color(0xFFC9B37E), // Gold text/icons in dark mode
              elevation: 0,
              centerTitle: true,
            ),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(color: Color(0xFFC9B37E), fontSize: 32, fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(color: Color(0xFFC9B37E), fontSize: 24, fontWeight: FontWeight.w600),
              bodyLarge: TextStyle(color: Color(0xFFF2E6CF), fontSize: 16),
              bodyMedium: TextStyle(color: Color(0xFFF2E6CF), fontSize: 14), // Muted champagne
            ),
            dividerColor: const Color(0xFFC9B37E).withOpacity(0.2),
            useMaterial3: true,
          ),
          
          home: SplashScreen(),
        );
      },
    );
  }
}