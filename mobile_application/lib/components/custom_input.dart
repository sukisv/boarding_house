import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;

  const CustomInput({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        height: 32.0,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 12.0),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
          ),
        ),
      ),
    );
  }
}
