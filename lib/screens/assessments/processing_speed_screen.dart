import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cognitive_provider.dart';
import '../../models/cognitive_models.dart';

class ProcessingSpeedScreen extends StatefulWidget {
  const ProcessingSpeedScreen({super.key});

  @override
  State<ProcessingSpeedScreen> createState() => _ProcessingSpeedScreenState();
}

class _ProcessingSpeedScreenState extends State<ProcessingSpeedScreen> {
  // Config
  static const int _totalNumbers = 25;

  // State
  List<int> _numbers = [];
  int _currentNumber = 1;
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedMillis = 0;
  int _errors = 0;
  bool _isGameActive = false;

  @override
  void initState() {
    super.initState();
    _generateLayout();
  }

  void _generateLayout() {
    _numbers = List.generate(_totalNumbers, (index) => index + 1);
    _numbers.shuffle();
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _currentNumber = 1;
      _errors = 0;
      _elapsedMillis = 0;
      _generateLayout();
      _startTime = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_startTime != null) {
        setState(() {
          _elapsedMillis = DateTime.now()
              .difference(_startTime!)
              .inMilliseconds;
        });
      }
    });
  }

  void _handleTap(int number) {
    if (!_isGameActive) return;

    if (number == _currentNumber) {
      setState(() {
        _currentNumber++;
      });
      if (_currentNumber > _totalNumbers) {
        _finishGame();
      }
    } else {
      // Wrong number tapped
      // Maybe simple visual feedback or vibration
      setState(() {
        _errors++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wrong number!'),
          duration: Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _finishGame() {
    _timer?.cancel();
    _isGameActive = false;

    // Score calculation
    // Speed score: (25 / seconds) * 10
    double seconds = _elapsedMillis / 1000.0;
    double score = (25 / seconds * 10).clamp(0, 100);

    final result = ObjectiveAssessmentResult(
      domain: CognitiveDomain.velocitatProcessament,
      score: score,
      rawScore: seconds, // seconds to complete
      correctAnswers: _totalNumbers,
      totalAttempts: _totalNumbers + _errors,
      completedAt: DateTime.now(),
      duration: Duration(milliseconds: _elapsedMillis),
    );

    Provider.of<CognitiveProvider>(
      context,
      listen: false,
    ).addAssessmentResult(result);
    _showResultDialog(seconds, _errors, score);
  }

  void _showResultDialog(double seconds, int errors, double score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Processing Speed Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time: ${seconds.toStringAsFixed(2)}s',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Errors: $errors', style: const TextStyle(color: Colors.red)),
            Text('Score: ${score.toInt()}/100'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect the Numbers')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cosmic_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(
                alpha: 0.4,
              ), // Adjust opacity (0.0 to 1.0)
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[900],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Find: $_currentNumber',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  Text(
                    _formatTime(_elapsedMillis),
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: _isGameActive ? _buildGrid() : _buildIntro()),
          ],
        ),
      ),
    );
  }

  String _formatTime(int millis) {
    int seconds = (millis / 1000).truncate();
    int deciseconds = ((millis % 1000) / 100).truncate();
    return '$seconds.$deciseconds';
  }

  Widget _buildIntro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app, size: 80, color: Colors.teal),
          const SizedBox(height: 20),
          const Text(
            'Processing Speed',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap numbers 1 to 25 in ascending order as fast as possible.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              backgroundColor: Colors.teal,
            ),
            child: const Text(
              'START TEST',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simple random positioning is messy, let's use a GridView but maybe randomized cells?
        // No, prompt says "randomly positioned". A custom Stack with random coords is best for "randomly positioned",
        // but GridView is cleaner for UI.
        // "Number Connection Test" (TMT A) is usually scattered.
        // Let's implement a clean 5x5 GridView for accessibility and usability on phones.
        // The numbers are already shuffled in _numbers list.

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _totalNumbers,
          itemBuilder: (context, index) {
            final number = _numbers[index];
            final isNext = number == _currentNumber;
            final isCompleted = number < _currentNumber;

            return GestureDetector(
              onTap: () => _handleTap(number),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.grey[800]
                      : (isNext ? Colors.teal : Colors.blueGrey[700]),
                  shape: BoxShape.circle,
                  border: isNext
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: isNext
                      ? [
                          BoxShadow(
                            color: Colors.tealAccent.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.grey)
                    : Text(
                        '$number',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isNext ? Colors.white : Colors.white70,
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
