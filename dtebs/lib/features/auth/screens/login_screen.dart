import 'package:flutter/material.dart';
import 'package:dtebs/core/theme/app_theme.dart';
import 'package:dtebs/features/auth/widgets/auth_text_field.dart';
import 'package:dtebs/features/auth/screens/signup_screen.dart';
import 'package:dtebs/features/auth/services/auth_service.dart';
import 'package:dtebs/features/auth/models/user_model.dart';
import 'package:dtebs/features/restaurant/screens/restaurant_details_screen.dart';
import 'package:dtebs/features/customer/screens/customer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _authService = AuthService();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('DEBUG: Login button pressed');

        // Assume user enters email for now, or use same logic if just name
        String emailInput = _emailController.text.trim();
        if (!emailInput.contains('@')) {
          // If they entered just a name, try to reconstruct mock email
          emailInput =
              '${emailInput.replaceAll(' ', '').toLowerCase()}@example.com';
        }
        print('DEBUG: Using email: $emailInput');

        UserModel? user = await _authService.signIn(
          email: emailInput,
          password: _passwordController.text,
        );

        if (mounted && user != null) {
          print('DEBUG: Login successful, user role: ${user.role}');

          if (user.role == 'Restaurant Owner') {
            print('DEBUG: Navigating to Restaurant Details Screen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RestaurantDetailsScreen(),
              ),
            );
          } else {
            print('DEBUG: Navigating to Customer Home Screen');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const CustomerHomeScreen(),
              ),
            );
          }
        } else {
          print('DEBUG: Login returned null user');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login failed. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        print('DEBUG: Login error caught: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _navigateToSignUp() {
    print('DEBUG: Signup button clicked');
    try {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const SignUpScreen()));
      print('DEBUG: Navigation pushed');
    } catch (e) {
      print('DEBUG: Navigation error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Restaurant Icon with Shadow
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'DTEBS',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reserve your exclusive table',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onBackground.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 60),
                    AuthTextField(
                      label: 'Email or ID',
                      prefixIcon: Icons.person_outline,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email or ID';
                        }
                        return null;
                      },
                    ),
                    AuthTextField(
                      label: 'Password',
                      prefixIcon: Icons.lock_outline,
                      isObscure: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('LOGIN'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _navigateToSignUp,
                      child: const Text('Don\'t have an account? Sign Up'),
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
}
