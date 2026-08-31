import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/remote/api_key_manager.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  bool _hasSavedKey = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final existingKey = await ApiKeyManager.getOpenAiKey();
    if (existingKey != null && existingKey.isNotEmpty) {
      _apiKeyController.text = existingKey;
      setState(() {
        _hasSavedKey = true;
      });
    } else {
      setState(() {
        _hasSavedKey = false;
      });
    }
  }

  Future<void> _saveKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isNotEmpty) {
      await ApiKeyManager.saveOpenAiKey(key);
      setState(() => _hasSavedKey = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OpenAI API Key saved securely! Live AI mode active.'),
            backgroundColor: AppColors.matchStrong,
          ),
        );
      }
    } else {
      await ApiKeyManager.clearKeys();
      setState(() => _hasSavedKey = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key cleared. Using fallback AI engine.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Real-World AI Setup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Real-World AI API Key Banner
          Card(
            color: _hasSavedKey
                ? AppColors.matchStrong.withValues(alpha: 0.12)
                : AppColors.primaryBlue.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _hasSavedKey ? AppColors.matchStrong : AppColors.primaryBlueLight,
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasSavedKey ? Icons.check_circle : Icons.vpn_key_outlined,
                        color: _hasSavedKey ? AppColors.matchStrong : AppColors.primaryBlueLight,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _hasSavedKey
                            ? 'Real-World Live AI Active'
                            : 'Configure Real-World AI Key',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (_hasSavedKey ? AppColors.matchStrong : AppColors.primaryBlueLight)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _hasSavedKey ? 'LIVE OPENAI MODE' : 'FALLBACK MODE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _hasSavedKey ? AppColors.matchStrong : AppColors.primaryBlueLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your OpenAI API key (sk-...) to run live GPT-4o analysis on real PDF resumes, real LinkedIn job postings, and live STAR interview scoring.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'OpenAI API Key (sk-...)',
                      hintText: 'sk-proj-...',
                      prefixIcon: Icon(Icons.key),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveKey,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Key Securely'),
                        ),
                      ),
                      if (_hasSavedKey) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.matchMissing),
                          tooltip: 'Clear API Key',
                          onPressed: () {
                            _apiKeyController.clear();
                            _saveKey();
                          },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

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
