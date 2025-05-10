import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/account_viewmodel.dart';

class AccountView extends StatefulWidget {
  const AccountView({super.key});

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Gunakan Future.microtask untuk menghindari perubahan state selama build
      Future.microtask(() {
        final accountViewModel = Provider.of<AccountViewModel>(
          context,
          listen: false,
        );
        accountViewModel.fetchUserProfile();
        if (kDebugMode) {
          print('fetchUserProfile called');
        } // Log untuk debugging
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountViewModel = Provider.of<AccountViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accountViewModel.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (accountViewModel.errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    accountViewModel.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (accountViewModel.userData != null)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildUserProfile(accountViewModel.userData!),
                ),
              )
            else
              const Expanded(
                child: Center(child: Text('No user data available')),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name: ${userData['name'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Email: ${userData['email'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Role: ${userData['role'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Phone: ${userData['phone_number'] ?? 'N/A'}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
