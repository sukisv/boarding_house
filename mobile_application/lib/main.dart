import 'package:flutter/material.dart';
import 'package:mobile_application/viewmodels/auth/login_viewmodel.dart';
import 'package:mobile_application/viewmodels/auth/register_viewmodel.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_details/index.dart';
import 'package:mobile_application/viewmodels/owner/boarding_house_update_image/index.dart';
import 'package:mobile_application/viewmodels/owner/manage_property/index.dart';
import 'package:mobile_application/viewmodels/seeker/favorite/index.dart';
import 'package:mobile_application/viewmodels/seeker/home/index.dart';
import 'package:mobile_application/viewmodels/seeker/search/index.dart';
import 'package:mobile_application/views/owner/boarding_house_details/index.dart';
import 'package:provider/provider.dart';
import 'viewmodels/seeker/account/index.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:mobile_application/views/auth/login_view.dart';
import 'package:mobile_application/views/auth/register_view.dart';
import 'package:mobile_application/viewmodels/auth/loading_viewmodel.dart';
import 'package:mobile_application/views/auth/loading_view.dart';
import 'package:mobile_application/viewmodels/auth/user_provider.dart';
import 'package:mobile_application/views/owner/home/index.dart' as owner;
import 'package:mobile_application/views/owner/account/index.dart' as owner;
import 'package:mobile_application/views/seeker/home/index.dart' as seeker;
import 'package:mobile_application/views/seeker/favorite/index.dart' as seeker;
import 'package:mobile_application/views/seeker/account/index.dart' as seeker;
import 'package:mobile_application/views/seeker/search/index.dart' as seeker;
import 'package:mobile_application/views/owner/notifications/index.dart'
    as owner;
import 'package:mobile_application/views/owner/manage_properties/index.dart'
    as owner;

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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ManagePropertyViewModel()),
        ChangeNotifierProvider(create: (_) => BoardingHouseDetailsViewModel()),
        ChangeNotifierProvider(
          create: (_) => BoardingHouseUpdateImageViewModel(),
        ),
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
        Routes.boardingHouseDetails: (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return BoardingHouseDetailsView(boardingHouseId: args);
        },
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

  final List<Widget> _seekerPages = [
    seeker.HomeView(),
    seeker.SearchView(),
    seeker.FavoriteView(),
    seeker.AccountView(),
  ];

  final List<Widget> _ownerPages = [
    owner.HomeView(),
    owner.NotificationsView(),
    owner.ManagePropertiesView(),
    owner.AccountView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userRole = userProvider.user?.role;

    final pages = userRole == 'owner' ? _ownerPages : _seekerPages;

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items:
            userRole == 'owner'
                ? const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.notifications),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    label: '',
                  ),
                ]
                : const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    label: '',
                  ),
                ],
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
