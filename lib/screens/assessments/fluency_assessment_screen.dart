import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../providers/cognitive_provider.dart';
import '../../models/cognitive_models.dart';

class FluencyAssessmentScreen extends StatefulWidget {
  const FluencyAssessmentScreen({super.key});

  @override
  State<FluencyAssessmentScreen> createState() =>
      _FluencyAssessmentScreenState();
}

class _FluencyAssessmentScreenState extends State<FluencyAssessmentScreen> {
  // Assessment Configuration
  late final String _targetLetter;
  final String _targetCategory = "Fruits/Vegetables";
  final int _durationSeconds = 30;

  // State
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isListening = false;
  bool _isAssessmentActive = false;
  bool _isSpeechInitialized = false;
  bool _isInitializing = true;

  // Speech Recognition
  late stt.SpeechToText _speech;
  final List<String> _detectedWords = [];
  String _lastError = "";
  final String _currentLocaleId = "en-US";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _targetLetter = String.fromCharCode(Random().nextInt(26) + 65);
    _initSpeech();
  }

  Future<void> _initSpeech() async {

    setState(() {
      _isInitializing = true;
      _lastError = "";
    });

    bool hasPermission = await _checkPermissions();

    if (!hasPermission) {
      setState(() {
        _lastError = "Microphone/Speech permissions denied.";
        _isInitializing = false;
      });
      return;
    }

    try {

      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('[STATUS CALLBACK] Speech Status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);

            if (_isAssessmentActive && _secondsRemaining > 0) {
              _startListening();
            }
          }
        },
        onError: (error) {
          setState(() => _lastError = error.errorMsg);
        },
        debugLogging: true,
      );

      if (available) {
        setState(() {
          _isSpeechInitialized = true;
          _isInitializing = false;
        });

      } else {
        setState(() {
          _lastError = "Speech recognition not available on this device.";
          _isInitializing = false;
        });

        if (mounted) {
          _showSpeechUnavailableDialog();
        }
      }
    } catch (e) {
      setState(() {
        _lastError = "Init Error: $e";
        _isInitializing = false;
      });

      if (mounted) {
        _showSpeechUnavailableDialog();
      }
    }
  }

  void _startListening() {
    if (!_isSpeechInitialized || _isListening) return;

    _speech.listen(
      onResult: (result) {
        // Robust splitting: Space, comma, dot, newline
        final rawText = result.recognizedWords;
        final words = rawText.split(RegExp(r'[ \.,\n]+'));

        for (var word in words) {
          word = word.trim().replaceAll(
            RegExp(r'[^\w]'),
            '',
          ); // Remove special chars
          if (word.isNotEmpty && !_detectedWords.contains(word)) {
            // In a real alternated fluency test, we would check if it matches the pattern
            // (Letter vs Category) here.
            setState(() {
              _detectedWords.add(word);
            });
          }
        }
      },
      localeId: _currentLocaleId,
      listenFor: Duration(seconds: _durationSeconds + 10), // Buffer
      pauseFor: const Duration(seconds: 10), // Allow longer pauses
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
      onDevice:
          false, // Try server-based for better quality if available? Or true for speed.
    );

    setState(() => _isListening = true);
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _showSpeechUnavailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech Service Missing'),
        content: const Text(
          'Speech recognition is not available on this device.\n\n'
          'If you are using an Emulator, please ensure it has the "Google App" installed and enabled.\n\n'
          'If you are on a physical device, please make sure Google Voice Typing or a similar service is enabled in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkPermissions() async {
    var status = await Permission.microphone.status;

    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }

  void _runAssessment() {
    setState(() {
      _isAssessmentActive = true;
      _secondsRemaining = _durationSeconds;
      _detectedWords.clear();
      _lastError = "";
    });

    _startListening();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _finishAssessment();
      }
    });
  }

  void _finishAssessment() {
    _timer?.cancel();
    _stopListening();
    setState(() {
      _isAssessmentActive = false;
    });

    // Save Results
    final provider = Provider.of<CognitiveProvider>(context, listen: false);

    // Simple mock scoring:
    int matchingCount = _detectedWords
        .where((w) => w.toUpperCase().startsWith(_targetLetter))
        .length;

    // Score based on matching word count
    double score = (matchingCount / 20 * 100).clamp(0, 100);

    final result = ObjectiveAssessmentResult(
      domain: CognitiveDomain.fluenciaAlternant,
      score: score.toInt(),
      rawScore: _detectedWords.length,
      correctAnswers: matchingCount, // Only count words starting with target letter
      totalAttempts: _detectedWords.length,
      completedAt: DateTime.now(),
      duration: Duration(seconds: _durationSeconds),
    );

    provider.addAssessmentResult(result);

    // Show Report
    _showResultDialog(result);
  }

  void _showResultDialog(ObjectiveAssessmentResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Assessment Finished'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Words detected: ${result.correctAnswers}'),
            const SizedBox(height: 10),
            Text(
              'Score: ${result.score.toInt()}/100',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Detected words:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: _detectedWords
                  .map((w) => Chip(label: Text(w)))
                  .toList(),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
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
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verbal Fluency')),
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
        child: Column(
          children: [
            _buildHeaderHelper(),
            const Spacer(),

            if (!_isAssessmentActive) _buildIntroView() else _buildActiveView(),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderHelper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.chat_bubble_outline, color: Colors.teal),
        const SizedBox(width: 8),
        Text(
          'Alternating Fluency',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildIntroView() {
    return Column(
      children: [
        const Text(
          'Target:',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Text(
          'Letter $_targetLetter  ↔  Category $_targetCategory',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        Text(
          'Say a word starting with the letter $_targetLetter, then a word from the category (Fruits/Veg), then switch back.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Text(
          'e.g. "Pear" ($_targetLetter) -> "Apple" (Fruit) -> "Potato" ($_targetLetter)...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
        const SizedBox(height: 40),

        if (_isInitializing)
          const Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Initializing microphone...'),
            ],
          )
        else if (_isSpeechInitialized)
          ElevatedButton.icon(
            onPressed: _runAssessment,
            icon: const Icon(Icons.mic),
            label: const Text('START RECORDING'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          )
        else
          Column(
            children: [
              const Text(
                'Microphone initialization failed.',
                style: TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _initSpeech,
                icon: const Icon(Icons.refresh),
                label: const Text('RETRY INITIALIZATION'),
              ),
            ],
          ),

        if (!_isInitializing && _lastError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              'Error: $_lastError',
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildActiveView() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: _secondsRemaining / _durationSeconds,
                strokeWidth: 8,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _secondsRemaining < 10 ? Colors.red : Colors.teal,
                ),
              ),
            ),
            Text(
              '$_secondsRemaining',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 40),
        if (_isListening)
          const Text(
            'Listening...',
            style: TextStyle(
              color: Colors.tealAccent,
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          const Text(
            'Processing...',
            style: TextStyle(color: Colors.orange, fontSize: 18),
          ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Column(
            children: [
              Text(
                'Words detected: ${_detectedWords.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.0,
                children: _detectedWords
                    .map(
                      (w) => Chip(
                        label: Text(w),
                        backgroundColor: Colors.teal.withValues(alpha: 0.2),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
