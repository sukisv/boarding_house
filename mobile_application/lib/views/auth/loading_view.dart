import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:mobile_application/viewmodels/auth/loading_viewmodel.dart';
import 'package:mobile_application/viewmodels/auth/user_provider.dart';
import 'package:provider/provider.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingViewModel = Provider.of<LoadingViewModel>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final isLoggedIn = await loadingViewModel.checkLoginStatus(userProvider);
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
