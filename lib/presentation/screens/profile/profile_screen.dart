import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = authState.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                      child: Text(
                        (profile?.fullName ?? 'Alex Morgan')[0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlueLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.fullName ?? 'Alex Morgan',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${profile?.currentRole ?? "Flutter Developer"} • ${profile?.yearsExperience ?? 2} yrs exp',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target: ${profile?.targetRole ?? "Mobile Application Developer"}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlueLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profile Sections
            _buildProfileSection(
              context,
              title: 'Professional Summary',
              content: profile?.summary ??
                  'Mobile Engineer with 2+ years of experience building cross-platform applications using Flutter, Dart, Firebase, and REST APIs.',
            ),
            const SizedBox(height: 12),
            _buildProfileSection(
              context,
              title: 'Target Industry & Preference',
              content:
                  '${profile?.targetIndustry ?? "Software / FinTech"} • ${profile?.workPreference ?? "Hybrid / Remote"} • ${profile?.location ?? "San Francisco, CA"}',
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Core Skills & Technologies',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (profile?.skills ??
                              ['Flutter', 'Dart', 'Riverpod', 'REST APIs', 'SQLite', 'Firebase', 'AWS'])
                          .map((skill) => Chip(
                                label: Text(skill, style: const TextStyle(fontSize: 12)),
                                backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/resume/upload'),
                icon: const Icon(Icons.upload_file),
                label: const Text('Update Resume & Parsing'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context,
      {required String title, required String content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
