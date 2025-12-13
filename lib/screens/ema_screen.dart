import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cognitive_provider.dart';
import '../models/cognitive_models.dart';

class EMAScreen extends StatefulWidget {
  const EMAScreen({super.key});

  @override
  State<EMAScreen> createState() => _EMAScreenState();
}

class _EMAScreenState extends State<EMAScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Local state to track current session answers before submission
  // Or we can just use the provider directly if we want instant saves
  // For now let's use local and submit to provider
  
  void _handleAnswer(CognitiveProvider provider, EMAQuestion question, int score) {
    // Save response to provider
    provider.submitEmaResponse(EMAResponse(
      questionId: question.id,
      score: score,
      domain: question.domain,
      respondedAt: DateTime.now(),
    ));

    // Wait a brief moment then move to next
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < provider.emaQuestions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        provider.completeEmaSession();
        _showCompletionDialog();
      }
    });

    // We don't need setState for _currentIndex here as PageView handles it via onPageChanged
    // But we might need it to update the UI selection if we rely on provider state re-build
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Assessment Complete'),
        content: const Text('Thank you for completing the daily assessment. Your responses have been recorded.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app, maybe navigate back to home
              // For now reset index for display purposes? Or just leave it at end state.
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CognitiveProvider>(
      builder: (context, provider, child) {
        if (provider.emaCompletedToday) {
           return Scaffold(
            appBar: AppBar(title: const Text('Daily Assessment (EMA)'), automaticallyImplyLeading: false),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.tealAccent),
                  SizedBox(height: 20),
                  Text('All caught up!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('You have completed today\'s assessment.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        if (provider.emaQuestions.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Assessment (EMA)'),
            automaticallyImplyLeading: false,
          ),
          body: Column(
            children: [
              _buildProgressBar(provider),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(), // User must answer to advance
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: provider.emaQuestions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(provider, provider.emaQuestions[index], index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(CognitiveProvider provider) {
    double progress = (_currentIndex + 1) / provider.emaQuestions.length;
    final currentQuestion = provider.emaQuestions[_currentIndex];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentIndex + 1}/${provider.emaQuestions.length}'),
              Text(currentQuestion.domain.toString().split('.').last.toUpperCase()),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(CognitiveProvider provider, EMAQuestion question, int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),
          Text(
            question.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const Spacer(flex: 1),
          _buildLikertScale(provider, question, index),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLikertScale(CognitiveProvider provider, EMAQuestion question, int questionIndex) {
    // Check if we have an answer already
    int? currentAnswer;
    try {
        // Find if we have a response for this question in the current session
        // Only works if we expose the session or methods to check
        // For simplicity, we just use local state? No, we switched to provider.
        // Let's iterate providers current session responses if accessible or just rely on selection visual feedback
        // Actually, we don't display "previous" selection if we go back currently (PageView disabled back swipe)
        // So we just need to handle new selection.
    } catch (_) {}

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Strongly\nDisagree', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
             Text('Strongly\nAgree', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            int score = i + 1;
            // Visual feedback could be improved if we tracked state, but for now simple tap
            bool isSelected = false; // We don't persist visual state in this simple version
            
            return InkWell(
              onTap: () => _handleAnswer(provider, question, score),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[800],
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
