import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/interview.dart';
import '../../providers/interview_provider.dart';

class MockInterviewScreen extends ConsumerStatefulWidget {
  const MockInterviewScreen({super.key});

  @override
  ConsumerState<MockInterviewScreen> createState() => _MockInterviewScreenState();
}

class _MockInterviewScreenState extends ConsumerState<MockInterviewScreen> {
  final _answerController = TextEditingController();
  bool _isRecording = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _toggleMic() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone listening... Speak your answer now.'),
          duration: Duration(seconds: 2),
        ),
      );
      // Simulate speech-to-text input
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _answerController.text =
                'I used Riverpod for state management. When an API call is made using Dio, the response is saved into local SQLite database. If device goes offline, Riverpod automatically falls back to SQLite reading.';
            _isRecording = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final interviewState = ref.watch(interviewProvider);
    final activeSession = interviewState.activeSession;
    final qIndex = interviewState.currentQuestionIndex;

    if (activeSession == null || activeSession.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Mock Interview Simulator')),
        body: _buildModeSelectionView(context),
      );
    }

    final currentQ = activeSession.questions[qIndex];
    final totalQs = activeSession.questions.length;
    final eval = currentQ.evaluation;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${qIndex + 1} of $totalQs'),
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(interviewProvider.notifier).startNewSession(InterviewMode.quick);
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('New Round'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (qIndex + 1) / totalQs.toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.darkBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentVioletLight),
              ),
            ),
            const SizedBox(height: 16),

            // Question Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentViolet.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentQ.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentVioletLight,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Target: Mobile Dev',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentQ.text,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Answer Input Area
            const Text(
              'Your Response (Text or Voice Input)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _answerController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your answer or tap microphone to speak...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    color: _isRecording ? AppColors.matchMissing : AppColors.primaryBlueLight,
                  ),
                  onPressed: _toggleMic,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: interviewState.isEvaluating
                        ? null
                        : () {
                            if (_answerController.text.trim().isEmpty) return;
                            ref
                                .read(interviewProvider.notifier)
                                .submitAnswer(_answerController.text.trim());
                          },
                    icon: interviewState.isEvaluating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send),
                    label: Text(interviewState.isEvaluating
                        ? 'Evaluating STAR Rubric...'
                        : 'Submit Answer for AI Evaluation'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Evaluation Report Card
            if (eval != null) _buildEvaluationReport(context, eval),

            const SizedBox(height: 20),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: qIndex > 0
                      ? () => ref.read(interviewProvider.notifier).previousQuestion()
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                ElevatedButton.icon(
                  onPressed: qIndex < totalQs - 1
                      ? () => ref.read(interviewProvider.notifier).nextQuestion()
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Question'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelectionView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select AI Interview Practice Mode',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Practice role-specific interview questions tailored to your target job description & resume.',
            style: TextStyle(color: AppColors.textMutedDark),
          ),
          const SizedBox(height: 20),
          _buildModeTile(
            context,
            title: 'Quick Practice (5 Questions)',
            subtitle: '5-minute warm-up focused on core job requirements.',
            icon: Icons.timer_outlined,
            mode: InterviewMode.quick,
          ),
          const SizedBox(height: 12),
          _buildModeTile(
            context,
            title: 'Technical Round (10 Questions)',
            subtitle: 'Deep technical questions on Flutter, Dart, REST APIs & SQLite.',
            icon: Icons.code_outlined,
            mode: InterviewMode.technical,
          ),
          const SizedBox(height: 12),
          _buildModeTile(
            context,
            title: 'Behavioral Round (STAR Framework)',
            subtitle: 'Evaluates Situation, Task, Action, and Result structured answers.',
            icon: Icons.psychology_outlined,
            mode: InterviewMode.behavioral,
          ),
        ],
      ),
    );
  }

  Widget _buildModeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required InterviewMode mode,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentViolet.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accentVioletLight),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          ref.read(interviewProvider.notifier).startNewSession(mode);
        },
      ),
    );
  }

  Widget _buildEvaluationReport(BuildContext context, InterviewEvaluation eval) {
    return Card(
      color: AppColors.accentViolet.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.accentViolet, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.accentVioletLight),
                const SizedBox(width: 8),
                Text(
                  'Answer Score: ${eval.overallScore} / 100',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentVioletLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEvalScoreChip('Relevance', eval.relevanceScore),
                _buildEvalScoreChip('Technical Depth', eval.technicalDepthScore),
                _buildEvalScoreChip('Specificity', eval.specificityScore),
                _buildEvalScoreChip('Structure', eval.structureScore),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'STAR Framework Breakdown:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            if (eval.starAnalysis.isNotEmpty)
              ...eval.starAnalysis.entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      '• ${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  )),
            const SizedBox(height: 12),
            const Text(
              'What Worked:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.matchStrong),
            ),
            ...eval.whatWorked.map((w) => Text('✓ $w', style: const TextStyle(fontSize: 12))),
            const SizedBox(height: 10),
            const Text(
              'How to Improve & Better Structure:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.matchPartial),
            ),
            Text(eval.betterStructure, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            const Text(
              'Suggested Follow-Up Question:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryBlueLight),
            ),
            Text(eval.suggestedFollowUp, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }

  Widget _buildEvalScoreChip(String label, int val) {
    return Column(
      children: [
        Text(
          '$val',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
        ),
      ],
    );
  }
}
