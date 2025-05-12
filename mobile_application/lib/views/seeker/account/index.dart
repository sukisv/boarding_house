import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/seeker/account/index.dart';
import '../../../components/custom_button.dart';
import '../../../viewmodels/auth/user_provider.dart';
import '../../../components/user_info_card.dart';

class AccountView extends StatelessWidget {
  final AccountViewModel viewModel = AccountViewModel();

  AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) UserInfoCard(user: user),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Logout',
              onPressed: () {
                viewModel.logout();
                Navigator.pushReplacementNamed(context, Routes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
