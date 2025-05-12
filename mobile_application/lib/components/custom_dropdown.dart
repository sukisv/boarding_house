import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    required Text Function(dynamic context, dynamic key) itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
        icon: Padding(
          padding: const EdgeInsets.only(top: 4), // Adjust icon position
          child: Icon(Icons.arrow_drop_down, size: 16),
        ),
      ),
    );
  }
}
