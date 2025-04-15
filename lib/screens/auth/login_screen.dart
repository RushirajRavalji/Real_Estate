import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen.dart';
import 'signup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Close keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        debugPrint(
          'Attempting to sign in with email: ${_emailController.text.trim()}',
        );

        // Use a try-catch block specifically for the Firebase authentication
        try {
          // Sign in with email and password
          final userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              );

          debugPrint(
            'Sign in successful. User ID: ${userCredential.user?.uid}',
          );

          // Save login state only if we have a valid user
          if (userCredential.user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            debugPrint('Login state saved to SharedPreferences');

            // Navigate to home screen
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            }
          }
        } catch (firebaseError) {
          debugPrint(
            'Caught Firebase error during authentication: $firebaseError',
          );
          rethrow; // Re-throw to be caught by the outer try-catch
        }
      } on FirebaseAuthException catch (e) {
        debugPrint(
          'FirebaseAuthException during login: ${e.code} - ${e.message}',
        );
        setState(() {
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = 'No user found with this email';
              break;
            case 'wrong-password':
              _errorMessage = 'Invalid password';
              break;
            case 'invalid-email':
              _errorMessage = 'Invalid email format';
              break;
            case 'user-disabled':
              _errorMessage = 'This account has been disabled';
              break;
            case 'network-request-failed':
              _errorMessage = 'Network error. Check your connection';
              break;
            default:
              _errorMessage = e.message ?? 'Authentication failed';
          }
        });
      } catch (e) {
        debugPrint('Unexpected error during login: $e');
        setState(() {
          _errorMessage = 'An error occurred. Please try again later.';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isSmallScreen ? null : 400,
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    const Text(
                      'DreamHome',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF6A38F2),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    const SizedBox(height: 36),

                    // Error message if any
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A38F2),
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF6A38F2),
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A38F2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: Color(0xFF6A38F2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Test account button (for debugging)
                    if (true) // Change to false in production
                      Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            'For Testing Only',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () {
                              _emailController.text = 'test@example.com';
                              _passwordController.text = 'password123';
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Use Test Account'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _createTestAccount,
                            child: const Text(
                              'Create Test Account',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Method to create a test account
  Future<void> _createTestAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('Creating test account...');

      // Check if test account already exists
      bool testAccountExists = false;
      try {
        final testUserCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: 'test@example.com',
              password: 'password123',
            );

        if (testUserCredential.user != null) {
          testAccountExists = true;
          debugPrint('Test account already exists, signing out...');
          await FirebaseAuth.instance.signOut();
        }
      } catch (e) {
        // Expected error if user doesn't exist
        debugPrint('Test account does not exist, will create one');
      }

      if (testAccountExists) {
        setState(() {
          _errorMessage =
              'Test account already exists. You can use it to log in.';
          _emailController.text = 'test@example.com';
          _passwordController.text = 'password123';
        });
        return;
      }

      // Create test user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          );

      debugPrint('Test user created: ${userCredential.user?.uid}');

      if (userCredential.user != null) {
        try {
          // Add user details to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'name': 'Test User',
                'email': 'test@example.com',
                'phone': '9876543210',
                'createdAt': FieldValue.serverTimestamp(),
              });

          debugPrint('Test user details added to Firestore');
        } catch (firestoreError) {
          debugPrint('Error saving test user to Firestore: $firestoreError');
        }
      }

      await FirebaseAuth.instance.signOut();

      setState(() {
        _errorMessage = 'Test account created successfully!';
        _emailController.text = 'test@example.com';
        _passwordController.text = 'password123';
      });
    } on FirebaseAuthException catch (e) {
      debugPrint('Error creating test account: ${e.code} - ${e.message}');
      setState(() {
        _errorMessage = 'Error creating test account: ${e.message}';
      });
    } catch (e) {
      debugPrint('Unexpected error creating test account: $e');
      setState(() {
        _errorMessage = 'Error creating test account. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
