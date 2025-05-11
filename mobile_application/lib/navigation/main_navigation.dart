import 'package:flutter/material.dart';
import 'package:mobile_application/views/account/account_view.dart';
import 'package:mobile_application/views/favorite/favorite_view.dart';
import 'package:mobile_application/views/home/home_view.dart';
import 'package:mobile_application/views/search/search_view.dart';
import 'package:mobile_application/services/api_service.dart';
import 'dart:convert';
import 'package:mobile_application/constants/routes.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    try {
      final response = await _apiService.get('/api/users/me');
      if (response.statusCode == 200) {
        setState(() {
          _user = jsonDecode(response.body)['data'];
        });
      } else if (response.statusCode == 401) {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    } catch (e) {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [HomeView(), SearchView(), FavoriteView(), AccountView()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.deepPurple,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
        ],
      ),
    );
  }
}
