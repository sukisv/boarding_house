import 'package:flutter/material.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const CustomSearchField({
    required this.controller,
    required this.hintText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: controller,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
      ),
    );
  }
}
