import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/entities/candidate_profile.dart';
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Alex Morgan');
  final _roleController = TextEditingController(text: 'Flutter Developer');
  final _expController = TextEditingController(text: '2');
  final _targetRoleController = TextEditingController(text: 'Mobile Application Developer');

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _expController.dispose();
    _targetRoleController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = CandidateProfile(
      id: 'profile-new',
      userId: 'user-new',
      fullName: _nameController.text.trim(),
      currentRole: _roleController.text.trim(),
      yearsExperience: int.tryParse(_expController.text.trim()) ?? 2,
      targetRole: _targetRoleController.text.trim(),
      targetIndustry: 'Technology',
      location: 'San Francisco, CA',
      workPreference: 'Hybrid',
      summary: 'Mobile developer passionate about building performant apps.',
      skills: const ['Flutter', 'Dart', 'Riverpod', 'REST APIs', 'SQLite'],
      experience: const [],
      projects: const [],
      education: const [],
      certifications: const [],
      technologies: const ['Flutter', 'Dart', 'SQLite'],
    );

    await ref.read(authProvider.notifier).saveOnboardingProfile(profile);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Onboarding'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Let\'s build your AI career strategy profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Provide your current role and target job goals to calibrate your Hireability Score.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Current Role'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Years of Experience'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetRoleController,
                decoration: const InputDecoration(labelText: 'Target Role'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completeOnboarding,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Save Profile & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
