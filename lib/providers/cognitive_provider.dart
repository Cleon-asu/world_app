
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/cognitive_models.dart';

class CognitiveProvider extends ChangeNotifier {
  // Assessment History
  final List<ObjectiveAssessmentResult> _assessmentHistory = [];
  
  // EMA State
  List<EMAQuestion> _emaQuestions = [];
  final List<EMAResponse> _currentSessionResponses = [];
  bool _emaCompletedToday = false;
  // ignore: unused_field, because it is used
  DateTime? _lastEmaCompletion;

  List<ObjectiveAssessmentResult> get assessmentHistory => _assessmentHistory;
  List<EMAQuestion> get emaQuestions => _emaQuestions;
  bool get emaCompletedToday => _emaCompletedToday;

  // --- Initialization ---
  Future<void> loadQuestions() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/ema_questions.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> questionsJson = data['questions'];
      
      _emaQuestions = questionsJson.map((q) => EMAQuestion.fromJson(q)).toList();
      _emaQuestions.sort((a, b) => a.order.compareTo(b.order));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading EMA questions: $e');
    }
  }

  // --- Objective Assessments ---

  void addAssessmentResult(ObjectiveAssessmentResult result) {
    _assessmentHistory.add(result);
    notifyListeners();
  }

  // Helper to get latest score for a domain
  double getLatestScore(CognitiveDomain domain) {
    final domainResults = _assessmentHistory.where((r) => r.domain == domain).toList();
    if (domainResults.isEmpty) return 0.0;
    domainResults.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return domainResults.first.score;
  }

  // --- EMA (Subjective) ---

  void submitEmaResponse(EMAResponse response) {
    // Remove existing response for same question if any (allow changing answer)
    _currentSessionResponses.removeWhere((r) => r.questionId == response.questionId);
    _currentSessionResponses.add(response);
    notifyListeners();
  }

  void completeEmaSession() {
    if (_currentSessionResponses.length >= _emaQuestions.length) {
      _emaCompletedToday = true;
      _lastEmaCompletion = DateTime.now();
      // In a real app, save to persistence here
      _currentSessionResponses.clear();
      notifyListeners();
    }
  }

  // --- Scoring & Recommendations ---

  // Calculate subjective score (0-100) for a domain based on EMA
  // 1-5 scale: 1=Good, 5=Bad (Based on "difficulty" questions)
  // We invert it so 100 is Good, 0 is Bad for consistency with objective scores?
  // User Prompt: "Threshold >= 3.0 avg = deficit present"
  // Let's keep raw avg 1-5 for internal logic, but expose a normalized risk score if needed.
  double getSubjectiveScore(CognitiveDomain domain) {
    // This needs to be persisted or aggregated. For now, we return a mock or simplified calculation
    // assuming we have stored responses somewhere permanent.
    // For this prototype, we'll assume NO history if session cleared.
    // TODO: Implement persistent storage for EMA history.
    return 0.0; 
  }
}
