import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/viewmodels/seeker/account/index.dart';
import '../../../viewmodels/auth/user_provider.dart';
import '../../../components/custom_button.dart';

class AccountView extends StatelessWidget {
  final AccountViewModel viewModel = AccountViewModel();

  AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (user != null) ...[
              Text(
                user.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(user.email, style: TextStyle(fontSize: 16)),
              SizedBox(height: 4),
              Text(user.phoneNumber, style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              Divider(),
            ],
            SizedBox(height: 8),
            SizedBox(height: 20),
            CustomButton(
              label: 'Keluar',
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
