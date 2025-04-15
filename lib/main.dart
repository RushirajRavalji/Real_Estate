import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('Starting app initialization...');

  try {
    debugPrint('Initializing Firebase...');
    // Use the updated Firebase options from firebase_options.dart
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    debugPrint('App initialization completed successfully');
  } catch (e) {
    debugPrint('Error during initialization: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DreamHome',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF6A38F2), // DreamHome purple
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF6A38F2)),
          titleTextStyle: TextStyle(
            color: Color(0xFF6A38F2),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A38F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6A38F2),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.white, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF6A38F2), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      // Use a responsive builder to adapt UI based on screen size
      builder: (context, child) {
        // Get the screen size
        final mediaQueryData = MediaQuery.of(context);
        final screenWidth = mediaQueryData.size.width;

        // Apply text scaling factor based on screen width
        double textScaleFactor = 1.0;
        if (screenWidth < 360) {
          textScaleFactor = 0.8; // Small phones
        } else if (screenWidth >= 600) {
          textScaleFactor = 1.1; // Tablets and larger devices
        }

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaleFactor: textScaleFactor,
            // Prevent keyboard from resizing the screen
            viewInsets: mediaQueryData.viewInsets,
          ),
          child: child!,
        );
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();

    // Add a timeout to prevent indefinite loading
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Loading timed out. Please restart the app.";
        });
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      debugPrint('Checking login status...');

      // Handle any initialization issues with Firebase
      try {
        // Wait for Firebase Auth to be initialized
        final currentUser = FirebaseAuth.instance.currentUser;

        // Check SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        debugPrint('SharedPreferences isLoggedIn: $isLoggedIn');
        debugPrint('Current user: ${currentUser?.uid ?? "null"}');

        if (mounted) {
          setState(() {
            // Consider logged in if BOTH SharedPreferences flag is true AND Firebase user exists
            _isLoggedIn = isLoggedIn && currentUser != null;
            _isLoading = false;

            // If SharedPreferences says logged in but Firebase says no, reset SharedPreferences
            if (isLoggedIn && currentUser == null) {
              prefs.setBool('isLoggedIn', false);
              debugPrint('Reset login state because Firebase user is null');
            }
          });
        }
      } catch (firebaseError) {
        debugPrint('Error with Firebase authentication: $firebaseError');
        // Reset Firebase connection and try again
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoggedIn = false;
            _errorMessage = null; // No need to show error to user in this case
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error connecting to the service. Please try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _checkLoginStatus();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
