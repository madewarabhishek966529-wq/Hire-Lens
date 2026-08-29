import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Account & Security',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit Account Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Password & Auth'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Privacy & Data Retention',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: true,
                  onChanged: (val) {},
                  title: const Text('Explicit AI Processing Consent'),
                  subtitle: const Text('Use AI services strictly for job matching and interview evaluation.'),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: false,
                  onChanged: (val) {},
                  title: const Text('Allow AI Model Training'),
                  subtitle: const Text('Your resumes and job data are NEVER used for model training when disabled.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.matchMissing),
                  title: const Text('Delete Resume & Data', style: TextStyle(color: AppColors.matchMissing)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All resume data cleared successfully.')),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Developer & Telemetry',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics_outlined, color: AppColors.primaryBlueLight),
              title: const Text('Developer Telemetry View'),
              subtitle: const Text('AI request volume, latency & cost metrics'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => context.push('/admin/observability'),
            ),
          ),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.matchMissing),
          ),
        ],
      ),
    );
  }
}
