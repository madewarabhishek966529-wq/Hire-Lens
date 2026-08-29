import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class ResumeUploadScreen extends ConsumerStatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  ConsumerState<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends ConsumerState<ResumeUploadScreen> {
  String? _fileName;
  bool _isUploading = false;
  bool _isParsed = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileName = result.files.first.name;
        _isUploading = true;
      });

      // Simulate parsing progress
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isUploading = false;
        _isParsed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider).profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Intelligence Engine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Resume (PDF / DOCX)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'HireLens parses your experience into structured data (Skills, Roles, Achievements, Technologies).',
              style: TextStyle(color: AppColors.textMutedDark),
            ),
            const SizedBox(height: 24),

            // Drop zone container
            InkWell(
              onTap: _isUploading ? null : _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.4),
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    if (_isUploading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Parsing Resume & Extracting Structured Data...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.cloud_upload_outlined,
                        size: 56,
                        color: AppColors.primaryBlueLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _fileName != null ? 'Uploaded: $_fileName' : 'Tap to select PDF or DOCX file',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Supported formats: .pdf, .docx (Max 10MB)',
                        style: TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_isParsed) ...[
              const SizedBox(height: 30),
              const Text(
                'Extracted Candidate Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.fullName ?? 'Alex Morgan',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${profile?.currentRole ?? "Flutter Developer"} • ${profile?.yearsExperience ?? 2} Years Experience',
                        style: const TextStyle(color: AppColors.primaryBlueLight, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Extracted Skills:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (profile?.skills ?? ['Flutter', 'Dart', 'Riverpod', 'REST APIs', 'SQLite', 'Firebase', 'AWS'])
                            .map(
                              (skill) => Chip(
                                label: Text(skill, style: const TextStyle(fontSize: 11)),
                                backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
