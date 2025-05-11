import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import '../../components/custom_button.dart';
import '../../components/custom_input.dart';
import '../../viewmodels/auth/login_viewmodel.dart';

class LoginView extends StatelessWidget {
  final LoginViewModel viewModel = LoginViewModel();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailOrPhoneController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomInput(
              controller: emailOrPhoneController,
              hintText: 'Email or Phone Number',
            ),
            CustomInput(controller: passwordController, hintText: 'Password'),
            CustomButton(
              label: 'Login',
              onPressed: () async {
                final success = await viewModel.login(
                  emailOrPhoneController.text,
                  passwordController.text,
                );
                if (success) {
                  Navigator.pushReplacementNamed(context, Routes.home);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
