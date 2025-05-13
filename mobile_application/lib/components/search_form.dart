import 'package:flutter/material.dart';
import 'custom_dropdown.dart';
import 'custom_search_field.dart';
import 'custom_button.dart';
import 'package:mobile_application/models/boarding_house.dart';

class SearchForm extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedGender;
  final Map<String, String> genderOptions;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onApply;

  const SearchForm({
    required this.searchController,
    required this.selectedGender,
    required this.genderOptions,
    required this.onGenderChanged,
    required this.onApply,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Keyword',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CustomSearchField(
          controller: searchController,
          hintText: 'Enter keyword',
        ),
        const SizedBox(height: 16),
        const Text(
          'Gender',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CustomDropdown(
          value: selectedGender,
          items:
              genderOptions.keys
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(
                        BoardingHouse.getGenderLabelStatic(key),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onGenderChanged,
        ),
        const SizedBox(height: 16),
        CustomButton(label: 'Apply', onPressed: onApply),
      ],
    );
  }
}
