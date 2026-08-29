import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/job_provider.dart';
import '../../providers/analysis_provider.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _jdController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAnalyzing = true);

    try {
      final job = await ref.read(jobProvider.notifier).createJobFromDescription(
            title: _titleController.text.trim(),
            company: _companyController.text.trim(),
            jdText: _jdController.text.trim(),
          );

      await ref.read(analysisProvider.notifier).runFullAnalysisForJob(job);

      if (mounted) {
        setState(() => _isAnalyzing = false);
        context.pushReplacement('/jobs/${job.id}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing job: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Target Job Description'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste Target Job Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'HireLens AI will analyze requirements into Must Have, Preferred, and Nice to Have categories.',
                style: TextStyle(color: AppColors.textMutedDark),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  hintText: 'e.g. Senior Flutter Developer',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter job title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'e.g. TechCorp',
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter company name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jdController,
                maxLines: 10,
                decoration: const InputDecoration(
                  labelText: 'Job Description Text',
                  hintText:
                      'Paste full job posting here (responsibilities, required skills, preferred qualifications)...',
                ),
                validator: (val) => val == null || val.length < 20
                    ? 'Please paste a detailed job description'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _submitJob,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isAnalyzing
                      ? 'AI Analyzing Requirements...'
                      : 'Analyze & Save Job Workspace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
