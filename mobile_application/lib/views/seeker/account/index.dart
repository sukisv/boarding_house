import 'package:flutter/material.dart';
import 'package:mobile_application/constants/routes.dart';
import 'package:provider/provider.dart';
import 'package:mobile_application/viewmodels/seeker/account/index.dart';
import '../../../viewmodels/auth/user_provider.dart';
import '../../../components/custom_button.dart';

class AccountView extends StatelessWidget {
  final AccountViewModel viewModel = AccountViewModel();

  AccountView({super.key});

  void _showUpdateProfileModal(
    BuildContext context,
    UserProvider userProvider,
  ) {
    final user = userProvider.user;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Perbarui Profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Nomor Telepon'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final updatedUser = await viewModel.updateUser(
                          user!.id,
                          nameController.text,
                          emailController.text,
                          phoneController.text,
                        );
                        if (updatedUser != null) {
                          userProvider.setUser(updatedUser);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Profil berhasil diperbarui'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal memperbarui profil')),
                          );
                        }
                      },
                      child: Text('Simpan'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

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
              label: 'Perbarui Profil',
              onPressed: () {
                _showUpdateProfileModal(context, userProvider);
              },
            ),
            SizedBox(height: 12),
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
