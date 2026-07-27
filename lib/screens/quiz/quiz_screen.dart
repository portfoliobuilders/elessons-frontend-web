import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_scaffold.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Who is the author of "Romeo and Juliet"?',
      'options': ['Charles Dickens', 'William Shakespeare', 'Jane Austen', 'Mark Twain'],
      'answer': 1,
    },
    {
      'question': 'In which century was the printing press invented?',
      'options': ['14th', '15th', '16th', '17th'],
      'answer': 1,
    }
  ];

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List<String>;
    
    return AppScaffold(
      safeBottom: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nav
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE7EAF0), width: 1.5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.close_rounded, size: 24, color: AppColors.ink),
                  ),
                ),
                Text('Quiz', style: AppTextStyles.heading.copyWith(fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.signalRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 14, color: AppColors.signalRed),
                      SizedBox(width: 4),
                      Text('09:59', style: TextStyle(color: AppColors.signalRed, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Question ${_currentQuestionIndex + 1} of ${_questions.length}', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentQuestionIndex + 1) / _questions.length,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE6EAF2),
                      valueColor: const AlwaysStoppedAnimation(AppColors.navy),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Question Card
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.card,
                  ),
                  child: Text(
                    question['question'] as String,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5, color: AppColors.ink),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Options
                ...List.generate(options.length, (index) {
                  final isSelected = _selectedOption == index;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedOption = index),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.navy.withValues(alpha: 0.05) : Colors.white,
                          border: Border.all(
                            color: isSelected ? AppColors.navy : const Color(0xFFE6EAF2),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppColors.navy : const Color(0xFFD6DBE5), width: 2),
                                color: isSelected ? AppColors.navy : Colors.transparent,
                              ),
                              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _selectedOption == null
                  ? null
                  : () {
                      if (_currentQuestionIndex < _questions.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                          _selectedOption = null;
                        });
                      } else {
                        // Submit
                        Navigator.maybePop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quiz submitted!')));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                disabledBackgroundColor: AppColors.navy.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_currentQuestionIndex == _questions.length - 1 ? 'Submit Quiz' : 'Next Question', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
