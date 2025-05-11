import 'package:flutter/material.dart';
import 'package:mobile_application/viewmodels/auth/login_viewmodel.dart';
import 'package:mobile_application/viewmodels/auth/register_viewmodel.dart';
import 'package:mobile_application/viewmodels/favorite/favorite_viewmodel.dart';
import 'package:mobile_application/viewmodels/home/home_viewmodel.dart';
import 'package:mobile_application/viewmodels/search/search_viewmodel.dart';
import 'package:mobile_application/views/home/home_view.dart';
import 'package:provider/provider.dart';
import 'viewmodels/account/account_viewmodel.dart';
import 'package:mobile_application/views/favorite/favorite_view.dart';
import 'package:mobile_application/views/account/account_view.dart';
import 'package:mobile_application/views/search/search_view.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:mobile_application/views/auth/login_view.dart';
import 'package:mobile_application/views/auth/register_view.dart';
import 'package:mobile_application/viewmodels/auth/loading_viewmodel.dart';
import 'package:mobile_application/views/auth/loading_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (_) => AccountViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => LoadingViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boarding House',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingView(),
        Routes.login: (context) => LoginView(),
        Routes.register: (context) => RegisterView(),
        Routes.home: (context) => const BottomNavigation(),
        Routes.favorite: (context) => const BottomNavigation(),
        Routes.account: (context) => const BottomNavigation(),
        Routes.search: (context) => const BottomNavigation(),
      },
    );
  }
}

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    FavoriteView(),
    AccountView(),
    SearchView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: ''),
        ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
