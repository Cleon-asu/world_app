
enum CognitiveDomain {
  fluenciaAlternant,
  atencion,
  memoriaTreball,
  velocitatProcessament
}

class ObjectiveAssessmentResult {
  final CognitiveDomain domain;
  final double score; // 0-100
  final double rawScore; // metric specific (seconds, count, etc)
  final int correctAnswers;
  final int totalAttempts; // or total sequences
  final DateTime completedAt;
  final Duration duration;

  ObjectiveAssessmentResult({
    required this.domain,
    required this.score,
    required this.rawScore,
    required this.correctAnswers,
    required this.totalAttempts,
    required this.completedAt,
    required this.duration,
  });
}

class EMAQuestion {
  final String id;
  final String text;
  final CognitiveDomain domain;
  final int order;

  EMAQuestion({
    required this.id,
    required this.text,
    required this.domain,
    required this.order,
  });

  factory EMAQuestion.fromJson(Map<String, dynamic> json) {
    CognitiveDomain domain;
    switch (json['domain']) {
      case 'attention':
        domain = CognitiveDomain.atencion;
        break;
      case 'memory':
        domain = CognitiveDomain.memoriaTreball;
        break;
      case 'processingSpeed':
        domain = CognitiveDomain.velocitatProcessament;
        break;
      case 'fluencia':
        domain = CognitiveDomain.fluenciaAlternant;
        break;
      default:
        domain = CognitiveDomain.atencion;
    }
    return EMAQuestion(
      id: json['id'],
      text: json['text'],
      domain: domain,
      order: json['order'],
    );
  }
}

class EMAResponse {
  final String questionId;
  final int score; // 1-5
  final DateTime respondedAt;
  final CognitiveDomain domain;

  EMAResponse({
    required this.questionId,
    required this.score,
    required this.respondedAt,
    required this.domain,
  });
}
