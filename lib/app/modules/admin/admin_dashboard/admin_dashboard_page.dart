import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, this.initialTab});
  
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Admin Dashboard Page - Coming Soon'),
            if (initialTab != null) ...[
              const SizedBox(height: 16),
              Text('Initial Tab: $initialTab'),
            ],
          ],
        ),
      ),
    );
  }
}