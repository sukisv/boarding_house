import 'package:flutter/material.dart';
import '../../components/custom_button.dart';
import '../../components/custom_input.dart';
import '../../viewmodels/auth/register_viewmodel.dart';

class RegisterView extends StatelessWidget {
  final RegisterViewModel viewModel = RegisterViewModel();

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomInput(controller: emailController, hintText: 'Email'),
            CustomInput(controller: phoneController, hintText: 'Phone Number'),
            CustomInput(controller: passwordController, hintText: 'Password'),
            CustomButton(
              label: 'Register',
              onPressed: () {
                viewModel.register(
                  email: emailController.text,
                  phone: phoneController.text,
                  password: passwordController.text,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
