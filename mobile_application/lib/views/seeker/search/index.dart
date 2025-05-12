import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../components/search_form.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    String selectedGender = 'all';
    final Map<String, String> genderOptions = {
      'all': 'Semua',
      'male': 'Pria',
      'female': 'Wanita',
      'mixed': 'Campuran',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SearchForm(
          searchController: searchController,
          selectedGender: selectedGender,
          genderOptions: genderOptions,
          onGenderChanged: (value) {
            if (value != null) {
              selectedGender = value;
            }
          },
          onApply: () {
            final keyword = searchController.text;
            if (kDebugMode) {
              print('Search: $keyword, Gender: $selectedGender');
            }
          },
        ),
      ),
    );
  }
}
