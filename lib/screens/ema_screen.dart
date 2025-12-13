import 'package:flutter/material.dart';

class EMAScreen extends StatefulWidget {
  const EMAScreen({super.key});

  @override
  State<EMAScreen> createState() => _EMAScreenState();
}

class _EMAScreenState extends State<EMAScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  
  // Data model for questions
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'I found it difficult to focus on a single task for more than 10 minutes.',
      'category': 'Attention',
    },
    {
      'question': 'I was easily distracted by background noises or movement.',
      'category': 'Attention',
    },
    {
      'question': 'It took me longer than usual to understand what people were saying.',
      'category': 'Processing Speed',
    },
    {
      'question': 'I felt my thinking was slower than normal today.',
      'category': 'Processing Speed',
    },
    {
      'question': 'I had trouble finding the right words when speaking.',
      'category': 'Verbal Fluency',
    },
    {
      'question': 'I struggled to follow the thread of a conversation.',
      'category': 'Verbal Fluency',
    },
    {
      'question': 'I forgot what I was doing while in the middle of a task.',
      'category': 'Working Memory',
    },
    {
      'question': 'I had difficulty remembering a short list of items.',
      'category': 'Working Memory',
    },
    {
      'question': 'I found it hard to plan my day or organize my tasks.',
      'category': 'Executive Function',
    },
    {
      'question': 'I acted impulsively without thinking through the consequences.',
      'category': 'Executive Function',
    },
  ];

  // Store answers: Index -> Score (1-5)
  final Map<int, int> _answers = {};

  void _handleAnswer(int score) {
    setState(() {
      _answers[_currentIndex] = score;
    });

    // Wait a brief moment then move to next
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < _questions.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _showCompletionDialog();
      }
    });
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
              // Reset for demo purposes or navigate away
              setState(() {
                _currentIndex = 0;
                _answers.clear();
                _pageController.jumpToPage(0);
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Assessment (EMA)'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // User must answer to advance
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(_questions[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentIndex + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentIndex + 1}/${_questions.length}'),
              Text(_questions[_currentIndex]['category']),
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

  Widget _buildQuestionCard(Map<String, dynamic> data, int index) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 1),
          Text(
            data['question'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          Spacer(flex: 1),
          _buildLikertScale(index),
          Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLikertScale(int questionIndex) {
    int? currentAnswer = _answers[questionIndex];

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
            bool isSelected = currentAnswer == score;
            return InkWell(
              onTap: () => _handleAnswer(score),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 56 : 48,
                height: isSelected ? 56 : 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.teal : Colors.grey[800],
                  border: Border.all(
                    color: isSelected ? Colors.tealAccent : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 10, spreadRadius: 2)]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey[400],
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
