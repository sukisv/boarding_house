import 'package:flutter/material.dart';
import 'package:mobile_application/viewmodels/owner/home/index.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double boxWidth =
        (screenWidth - 48) / 2; // 16 padding kiri, 16 kanan, 16 gap
    final double boxHeight = 110;
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda Pemilik')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: HomeViewmodel().fetchDashboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('No data'));
          }
          if (data['error'] != null) {
            return Center(child: Text('Error: \\${data['error']}'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _DashboardBox(
                      icon: Icons.check_circle,
                      label: 'Dikonfirmasi',
                      value: data['confirmed'].toString(),
                      color: Colors.green.shade100,
                      iconColor: Colors.green,
                      width: boxWidth,
                      height: boxHeight,
                    ),
                    const SizedBox(width: 16),
                    _DashboardBox(
                      icon: Icons.hourglass_top,
                      label: 'Pending',
                      value: data['pending'].toString(),
                      color: Colors.orange.shade100,
                      iconColor: Colors.orange,
                      width: boxWidth,
                      height: boxHeight,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _DashboardBox(
                  icon: Icons.cancel,
                  label: 'Dibatalkan',
                  value: data['cancelled'].toString(),
                  color: Colors.red.shade100,
                  iconColor: Colors.red,
                  width: boxWidth, // full width minus padding
                  height: boxHeight,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;
  final double width;
  final double height;

  const _DashboardBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
    required this.width,
    required this.height,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
