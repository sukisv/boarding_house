import 'package:flutter/material.dart';
import 'package:mobile_application/components/custom_button.dart';
import 'package:mobile_application/components/user_info_card.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:mobile_application/viewmodels/auth/user_provider.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/owner/account/index.dart';

class AccountView extends StatelessWidget {
  final AccountViewModel viewModel = AccountViewModel();

  AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user != null) UserInfoCard(user: user),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Keluar',
              onPressed: () {
                viewModel.logout(userProvider); // Pass UserProvider to logout
                Navigator.pushReplacementNamed(context, Routes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
