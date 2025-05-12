import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:provider/provider.dart';
import '../../components/custom_button.dart';
import '../../components/custom_input.dart';
import '../../viewmodels/auth/login_viewmodel.dart';
import '../../viewmodels/auth/user_provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailOrPhoneController = TextEditingController();
    final passwordController = TextEditingController();
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

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
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                final success = await loginViewModel.login(
                  emailOrPhoneController.text,
                  passwordController.text,
                  userProvider,
                );
                if (success) {
                  Navigator.pushReplacementNamed(context, Routes.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed. Please try again.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
