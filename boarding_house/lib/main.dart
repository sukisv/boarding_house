import 'package:boarding_house/viewmodels/account_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth/login_viewmodel.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => AccountViewModel()),
      ],
      child: MaterialApp(
        initialRoute: AppRoutes.main,
        routes: AppRoutes.routes,
      ),
    );
  }
}
