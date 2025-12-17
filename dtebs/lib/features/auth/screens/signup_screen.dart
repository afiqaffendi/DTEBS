import 'package:flutter/material.dart';
import 'package:dtebs/core/theme/app_theme.dart';
import 'package:dtebs/features/auth/widgets/auth_text_field.dart';
import 'package:dtebs/features/auth/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Customer'; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final _authService = AuthService();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.signUp(
          email:
              '${_nameController.text.replaceAll(' ', '').toLowerCase()}@example.com', // Mock email generation for simplicity as per UI
          password: _passwordController.text,
          name: _nameController.text,
          role: _selectedRole,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
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
                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join the exclusive experience',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 40),
                    AuthTextField(
                      label: 'Full Name',
                      prefixIcon: Icons.person,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
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
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'I am a:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Customer'),
                            subtitle: const Text('Book and enjoy dining'),
                            value: 'Customer',
                            groupValue: _selectedRole,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          const Divider(height: 1),
                          RadioListTile<String>(
                            title: const Text('Restaurant Owner'),
                            subtitle: const Text('Manage your restaurant'),
                            value: 'Restaurant Owner',
                            groupValue: _selectedRole,
                            activeColor: AppTheme.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _handleRegister,
                      child: const Text('REGISTER'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _navigateToLogin,
                      child: const Text('Already have an account? Login'),
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
