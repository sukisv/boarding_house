import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login View')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Login Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/auth/register');
              },
              child: Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}
