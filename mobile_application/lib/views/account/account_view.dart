import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import '../../viewmodels/account/account_viewmodel.dart';
import '../../components/custom_button.dart';

class AccountView extends StatelessWidget {
  final AccountViewModel viewModel = AccountViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Account Page'),
            SizedBox(height: 20),
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
