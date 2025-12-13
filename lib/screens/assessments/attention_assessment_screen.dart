
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../providers/cognitive_provider.dart';
import '../../models/cognitive_models.dart';

class AttentionAssessmentScreen extends StatefulWidget {
  const AttentionAssessmentScreen({super.key});

  @override
  State<AttentionAssessmentScreen> createState() => _AttentionAssessmentScreenState();
}

class _AttentionAssessmentScreenState extends State<AttentionAssessmentScreen> with SingleTickerProviderStateMixin {
  // Config
  static const int _startLength = 4;
  static const int _maxLength = 9;
  static const int _maxAttempts = 2; // per length
  static const int _displayDuration = 2; // seconds

  // State
  int _currentLength = _startLength;
  String _currentSequence = "";
  int _attemptsForCurrentLength = 0;
  int _consecutiveFailures = 0;
  List<String> _history = [];

  bool _isAssessmentActive = false;
  bool _isDisplaying = false;
  // ignore: unused_field, because it is used in lambdas
  bool _isListening = false;
  bool _showFeedback = false;
  bool _lastRoundSuccess = false;
  
  // Speech
  late stt.SpeechToText _speech;
  bool _isSpeechInitialized = false;
  String _recognizedText = ""; // The numbers recognized in current attempt
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    // Basic init logic similar to Fluency
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onError: (e) => setState(() => _statusMessage = "Error: ${e.errorMsg}"),
      );
      if (available) {
        setState(() => _isSpeechInitialized = true);
      }
    }
  }

  void _startAssessment() {
    setState(() {
      _isAssessmentActive = true;
      _currentLength = _startLength;
      _attemptsForCurrentLength = 0;
      _consecutiveFailures = 0;
      _history.clear();
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
        seq += rng.nextInt(10).toString(); // 0-9
    }
    setState(() {
      _currentSequence = seq;
      _recognizedText = "";
      _statusMessage = "Watch carefully...";
    });
  }

  void _playSequence() {
    setState(() => _isDisplaying = true);
    
    // Display for limited time
    Future.delayed(Duration(seconds: _displayDuration), () {
      if (mounted && _isAssessmentActive) {
        setState(() {
          _isDisplaying = false;
          _statusMessage = "Speak the numbers";
        });
        _startListening();
      }
    });
  }

  void _startListening() {
    if (!_isSpeechInitialized) {
      // Fallback or error
      return;
    }

    setState(() => _isListening = true);
    
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
           _processInput(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onDevice: false, 
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _processInput(String input) {
    // Clean input: remove non-digits
    String cleanInput = input.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Some STT might return words "one", "two". 
    // Quick map for common number words
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
    // Very basic mapping, expansive one needed for production
    const map = {
      'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
      'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9'
    };
    String res = "";
    final words = text.toLowerCase().split(RegExp(r'\s+'));
    for (var w in words) {
      if (map.containsKey(w)) res += map[w]!;
      else if (int.tryParse(w) != null) res += w;
    }
    return res;
  }

  void _validateRound(String input) {
    bool correct = input == _currentSequence;
    
    setState(() {
      _showFeedback = true;
      _lastRoundSuccess = correct;
    });

    // Feedback delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showFeedback = false);
      
      if (correct) {
        // Success: Increase length, reset failures
        setState(() {
          _currentLength++;
          _attemptsForCurrentLength = 0;
          _consecutiveFailures = 0;
        });
        _nextRound();
      } else {
        // Failure
        setState(() {
          _attemptsForCurrentLength++;
        });

        if (_attemptsForCurrentLength >= _maxAttempts) {
             // Failed both attempts at this length
             setState(() {
               _consecutiveFailures++; 
               // For Digit Span, usually you stop after failing a length completely
               // But prompt says "Stop when 2 consecutive failures at same length" (which usually means 2 strikes total?)
               // Usually standard is: 2 trials per span length. Discontinue after failure on BOTH trials of a given span length.
               // So if attempts >= 2, we stop? Or we treat "consecutive failures" as across lengths?
               // Prompt: "Stop when... 2 consecutive failures at same length"
               // This implies if I fail attempt 1 (streak=1) and attempt 2 (streak=2) -> Stop.
               // So if I fail max attempts for current length, I am done.
             });
             _finishAssessment();
        } else {
            // Retry same length (new sequence)
            _nextRound();
        }
      }
    });
  }

  void _finishAssessment() {
    setState(() => _isAssessmentActive = false);
    
    // Score is max length achieved (previous one if current failed)
    // If I failed length 4, score is 0? Or 3 (start-1)? Let's say max length completed.
    // If I passed length 5, then failed length 6 twice. Max is 5.
    // Logic: _currentLength is the one I performed (or tried). If validation failed, I didn't complete it.
    // But logic increments _currentLength on success. So if I am at length 6 and fail, my max was 5.
    // If I am at start length and fail, score 0.
    
    int maxLen = _currentLength - 1; 
    if (maxLen < 0) maxLen = 0;
    
    double score = (maxLen / _maxLength * 100).clamp(0, 100);

    final result = ObjectiveAssessmentResult(
      domain: CognitiveDomain.atencion,
      score: score,
      rawScore: maxLen.toDouble(),
      correctAnswers: maxLen, // approximating "sequences" to length
      totalAttempts: 0, // not tracking total sequences here for now
      completedAt: DateTime.now(),
      duration: Duration.zero,
    );
    
    Provider.of<CognitiveProvider>(context, listen: false).addAssessmentResult(result);
    _showResultDialog(maxLen);
  }

  void _showResultDialog(int length) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Attention Assessment Complete'),
        content: Text('Maximum Digit Span: $length'),
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
      appBar: AppBar(title: const Text('Digit Span (Forward)')),
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
        padding: const EdgeInsets.all(24.0),
        child: _isAssessmentActive ? _buildActiveView() : _buildIntroView(),
      ),
    );
  }

  Widget _buildIntroView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility, size: 80, color: Colors.teal),
          const SizedBox(height: 20),
          const Text(
            'Attention Task',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Memorize the digits shown and repeat them aloud.',
            textAlign: TextAlign.center,
          ),
           const SizedBox(height: 40),
           _isSpeechInitialized 
           ? ElevatedButton(
             onPressed: _startAssessment,
             child: const Text('START'),
           )
           : const CircularProgressIndicator(),
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
        Text('Length: $_currentLength', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        
        if (_isDisplaying) 
          // Show Sequence
           Text(
             _currentSequence.split('').join(' '), // Spacing
             style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 8),
           )
        else
          // Show Status / Listening
           Column(
             children: [
                const Icon(Icons.mic, size: 60, color: Colors.tealAccent),
                const SizedBox(height: 20),
                Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 20),
                ),
                 const SizedBox(height: 20),
                 Text(
                   _recognizedText.isEmpty ? "..." : _recognizedText,
                   style: const TextStyle(fontSize: 30, color: Colors.yellowAccent),
                 ),
             ],
           )
      ],
    );
  }
}
