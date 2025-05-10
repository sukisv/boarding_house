import 'package:flutter/material.dart';
import '../views/main_view.dart';
import '../views/account/account_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';

class AppRoutes {
  static const String main = '/';
  static const String account = '/account';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  static final Map<String, WidgetBuilder> routes = {
    main: (context) => MainView(),
    account: (context) => AccountView(),
    login: (context) => LoginView(),
    register: (context) => RegisterView(),
  };
}
