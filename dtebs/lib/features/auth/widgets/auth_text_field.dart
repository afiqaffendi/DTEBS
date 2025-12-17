import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final bool isObscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const AuthTextField({
    super.key,
    required this.label,
    required this.prefixIcon,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
