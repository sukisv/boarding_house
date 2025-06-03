import 'package:flutter/material.dart';
import '../../components/custom_button.dart';
import '../../components/custom_input.dart';
import '../../components/custom_dropdown.dart';
import '../../viewmodels/auth/register_viewmodel.dart';

class RegisterView extends StatelessWidget {
  final RegisterViewModel viewModel = RegisterViewModel();

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'seeker';
    final List<DropdownMenuItem<String>> roleItems = [
      DropdownMenuItem(
        value: 'seeker',
        child: Text('Pencari Kos', style: TextStyle(fontSize: 12)),
      ),
      DropdownMenuItem(
        value: 'owner',
        child: Text('Pemilik Kos', style: TextStyle(fontSize: 12)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Daftar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomInput(controller: nameController, hintText: 'Nama'),
                CustomInput(controller: emailController, hintText: 'Email'),
                CustomInput(
                  controller: phoneController,
                  hintText: 'Nomor Telepon',
                ),
                CustomInput(
                  controller: passwordController,
                  hintText: 'Kata Sandi',
                  obscureText: true,
                ),
                CustomDropdown(
                  value: selectedRole,
                  items: roleItems,
                  onChanged: (val) {
                    setState(() {
                      selectedRole = val!;
                    });
                  },
                ),
                SizedBox(height: 16),
                CustomButton(
                  label: 'Daftar',
                  onPressed: () async {
                    final success = await viewModel.register(
                      email: emailController.text,
                      password: passwordController.text,
                      name: nameController.text,
                      role: selectedRole,
                      phone: phoneController.text,
                    );
                    if (success) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/login',
                        arguments: emailController.text,
                      );
                    }
                  },
                ),
                SizedBox(height: 12),
                CustomButton(
                  label: 'Masuk',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
