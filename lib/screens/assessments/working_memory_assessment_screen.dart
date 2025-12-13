import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../providers/cognitive_provider.dart';
import '../../models/cognitive_models.dart';

class WorkingMemoryAssessmentScreen extends StatefulWidget {
  const WorkingMemoryAssessmentScreen({super.key});

  @override
  State<WorkingMemoryAssessmentScreen> createState() =>
      _WorkingMemoryAssessmentScreenState();
}

class _WorkingMemoryAssessmentScreenState
    extends State<WorkingMemoryAssessmentScreen>
    with SingleTickerProviderStateMixin {
  // Config
  static const int _startLength =
      3; // Backward is harder, start lower? Standard is often 2 or 3.
  static const int _maxLength = 8;
  static const int _maxAttempts = 2;
  static const int _displayDuration = 2;

  // State
  int _currentLength = _startLength;
  String _currentSequence = "";
  int _attemptsForCurrentLength = 0;
  int _consecutiveFailures = 0;

  bool _isAssessmentActive = false;
  bool _isDisplaying = false;
  // ignore: unused_field, because it is used in lambdas
  bool _isListening = false;
  bool _showFeedback = false;
  bool _lastRoundSuccess = false;

  // Speech
  late stt.SpeechToText _speech;
  bool _isSpeechInitialized = false;
  String _recognizedText = "";
  String _statusMessage = "";
  String _lastError = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool hasPermission = await _checkPermissions();
    if (!hasPermission) return;

    try {
      bool available = await _speech.initialize(
        onError: (e) => setState(() => _statusMessage = "Error: ${e.errorMsg}"),
      );
      if (available) {
        setState(() => _isSpeechInitialized = true);
      }
    } catch (e) {
      setState(() => _lastError = e.toString());
    }
  }

  Future<bool> _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  void _startAssessment() {
    setState(() {
      _isAssessmentActive = true;
      _currentLength = _startLength;
      _attemptsForCurrentLength = 0;
      _consecutiveFailures = 0;
      _currentSequence = "";
      _recognizedText = "";
      _lastError = "";
      _nextRound();
    });
  }

  void _nextRound() {
    if (_consecutiveFailures >= 2 || _currentLength > _maxLength) {
      _finishAssessment();
      return;
    }

    _generateSequence();
    _playSequence();
  }

  void _generateSequence() {
    final rng = Random();
    String seq = "";
    for (int i = 0; i < _currentLength; i++) {
      seq += rng.nextInt(10).toString();
    }
    setState(() {
      _currentSequence = seq;
      _recognizedText = "";
      _statusMessage = "Watch carefully...";
    });
  }

  void _playSequence() {
    setState(() => _isDisplaying = true);

    Future.delayed(Duration(seconds: _displayDuration), () {
      if (mounted && _isAssessmentActive) {
        setState(() {
          _isDisplaying = false;
          _statusMessage = "Say the numbers BACKWARDS";
        });
        _startListening();
      }
    });
  }

  void _startListening() {
    if (!_isSpeechInitialized) return;

    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _processInput(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onDevice: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _processInput(String input) {
    String cleanInput = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanInput.isEmpty && input.isNotEmpty) {
      cleanInput = _convertWordsToDigits(input);
    }

    setState(() {
      _recognizedText = cleanInput;
      _isListening = false;
    });
    _speech.stop();
    _validateRound(cleanInput);
  }

  String _convertWordsToDigits(String text) {
    const map = {
      'zero': '0',
      'one': '1',
      'two': '2',
      'three': '3',
      'four': '4',
      'five': '5',
      'six': '6',
      'seven': '7',
      'eight': '8',
      'nine': '9',
    };
    String res = "";
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    for (var w in words) {
      if (map.containsKey(w))
        res += map[w]!;
      else if (int.tryParse(w) != null)
        res += w;
    }
    return res;
  }

  void _validateRound(String input) {
    // REVERSE Logic for Working Memory
    String required = _currentSequence.split('').reversed.join('');
    bool correct = input == required;

    setState(() {
      _showFeedback = true;
      _lastRoundSuccess = correct;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showFeedback = false);

      if (correct) {
        setState(() {
          _currentLength++;
          _attemptsForCurrentLength = 0;
          _consecutiveFailures = 0;
        });
        _nextRound();
      } else {
        setState(() {
          _attemptsForCurrentLength++;
        });

        if (_attemptsForCurrentLength >= _maxAttempts) {
          setState(() {
            _consecutiveFailures++;
          });
          _finishAssessment();
        } else {
          _nextRound();
        }
      }
    });
  }

  void _finishAssessment() {
    setState(() => _isAssessmentActive = false);

    int maxLen = _currentLength - 1;
    if (maxLen < 0) maxLen = 0;

    int score = (maxLen / _maxLength * 100).clamp(0, 100).toInt();

    final result = ObjectiveAssessmentResult(
      domain: CognitiveDomain.memoriaTreball, // Working Memory
      score: score,
      rawScore: maxLen,
      correctAnswers: maxLen,
      totalAttempts: 0,
      completedAt: DateTime.now(),
      duration: Duration.zero,
    );

    Provider.of<CognitiveProvider>(
      context,
      listen: false,
    ).addAssessmentResult(result);
    _showResultDialog(maxLen);
  }

  void _showResultDialog(int length) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Working Memory Complete'),
        content: Text('Max Backward Digit Span: $length'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
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
        child: _isAssessmentActive ? _buildActiveView() : _buildIntroView(),
      ),
    );
  }

  Widget _buildIntroView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 80, color: Colors.teal),
          const SizedBox(height: 20),
          const Text(
            'Working Memory',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'Memorize the digits shown, then repeat them in REVERSE order.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ex: "1 - 2 - 3" -> Say "3 - 2 - 1"',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 40),
          _isSpeechInitialized
              ? ElevatedButton(
                  onPressed: _startAssessment,
                  child: const Text('START'),
                )
              : const CircularProgressIndicator(),

          if (_lastError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Error: $_lastError',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActiveView() {
    if (_showFeedback) {
      return Center(
        child: Icon(
          _lastRoundSuccess ? Icons.check_circle : Icons.error,
          color: _lastRoundSuccess ? Colors.green : Colors.red,
          size: 100,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Length: $_currentLength',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 40),

        if (_isDisplaying)
          Text(
            _currentSequence.split('').join(' '),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          )
        else
          Column(
            children: [
              const Icon(Icons.mic, size: 60, color: Colors.tealAccent),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(fontSize: 20, color: Colors.tealAccent),
              ),
              const SizedBox(height: 20),
              Text(
                _recognizedText.isEmpty ? "..." : _recognizedText,
                style: const TextStyle(
                  fontSize: 30,
                  color: Colors.yellowAccent,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
