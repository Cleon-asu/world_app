import '../models/cognitive_models.dart';

class TreatmentVideo {
  final String id;
  final String title;
  final String titleCA; // Catalan title
  final String youtubeUrl;
  final Duration? duration; // Optional, might be fetched or hardcoded
  final String? thumbnailUrl;
  final String category; // "Psychoeducation", "Mindfulness", "Strategies", "Lifestyle"
  final CognitiveDomain? targetDomain;
  final int orderInPlaylist;
  final bool isCompleted;
  final DateTime? lastWatchedAt;

  const TreatmentVideo({
    required this.id,
    required this.title,
    required this.titleCA,
    required this.youtubeUrl,
    this.duration,
    this.thumbnailUrl,
    required this.category,
    this.targetDomain,
    required this.orderInPlaylist,
    this.isCompleted = false,
    this.lastWatchedAt,
  });
}

class TreatmentPath {
  final String pathId;
  final String title;
  final String titleCA;
  final String description;
  final String category;
  final List<TreatmentVideo> videos;
  final CognitiveDomain? targetDomain; // null for general psychoeducation
  
  const TreatmentPath({
    required this.pathId,
    required this.title,
    required this.titleCA,
    required this.description,
    required this.category,
    required this.videos,
    this.targetDomain,
  });

  int get totalVideos => videos.length;
  int get completedVideos => videos.where((v) => v.isCompleted).length;
  double get completionPercentage => totalVideos == 0 ? 0 : completedVideos / totalVideos;
}
