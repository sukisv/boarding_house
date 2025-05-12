import 'package:flutter/material.dart';
import 'package:mobile_application/models/user.dart';

class UserInfoCard extends StatelessWidget {
  final User user;

  const UserInfoCard({required this.user, super.key});

  String getRoleLabel(String role) {
    const roleMapping = {'seeker': 'Pencari', 'owner': 'Pemilik'};
    return roleMapping[role] ?? 'Tidak Diketahui';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${user.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${user.email}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Role: ${getRoleLabel(user.role)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone: ${user.phoneNumber}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
