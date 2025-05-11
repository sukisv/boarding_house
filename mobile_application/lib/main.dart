import 'package:flutter/material.dart';
import 'package:mobile_application/navigation/main_navigation.dart';
import 'package:mobile_application/viewmodels/auth/login_viewmodel.dart';
import 'package:mobile_application/viewmodels/auth/register_viewmodel.dart';
import 'package:mobile_application/viewmodels/favorite/favorite_viewmodel.dart';
import 'package:mobile_application/viewmodels/home/home_viewmodel.dart';
import 'package:mobile_application/viewmodels/search/search_viewmodel.dart';
import 'package:provider/provider.dart';
import 'viewmodels/account/account_viewmodel.dart';
import 'package:mobile_application/views/auth/login_view.dart';
import 'package:mobile_application/views/auth/register_view.dart';
import 'package:mobile_application/views/home/home_view.dart';
import 'package:mobile_application/views/search/search_view.dart';
import 'package:mobile_application/views/favorite/favorite_view.dart';
import 'package:mobile_application/views/account/account_view.dart';

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
        '/': (context) => const MainNavigation(),
        '/login': (context) => LoginView(),
        '/register': (context) => RegisterView(),
        '/home': (context) => HomeView(),
        '/search': (context) => SearchView(),
        '/favorite': (context) => FavoriteView(),
        '/account': (context) => AccountView(),
      },
    );
  }
}
