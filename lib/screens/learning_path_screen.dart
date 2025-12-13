import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cognitive_provider.dart';
import '../models/cognitive_models.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CognitiveProvider>(
      builder: (context, provider, child) {
        final recommendations = _generateRecommendations(provider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Treatment Path'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Recommended for You'),
                if (recommendations.isEmpty)
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 16),
                     child: Text('Complete assessments to get personalized recommendations.', style: TextStyle(color: Colors.grey)),
                   )
                else
                   ...recommendations.map((r) => _buildRecommendationCard(
                     context,
                     title: r['title'] as String,
                     description: r['description'] as String,
                     duration: r['duration'] as String,
                     color: r['color'] as Color,
                     icon: r['icon'] as IconData,
                   )),

                 const SizedBox(height: 20),
                _buildSectionHeader('Daily Wellness'),
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildLifestyleCard('Sleep Hygiene', 'Tips for rest', Icons.bed),
                      _buildLifestyleCard('Nutrition', 'Brain foods', Icons.restaurant),
                      _buildLifestyleCard('Social', 'Connect', Icons.people),
                      _buildLifestyleCard('Exercise', 'Cardio', Icons.directions_run),
                      _buildLifestyleCard('Learning', 'New skills', Icons.school),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _buildSectionHeader('Library'),
                 _buildLibraryItem('Understanding Cognitive Decline', 'Psychoeducation - 3 min'),
                 _buildLibraryItem('Strategies for Memory', 'Tips & Tricks - 6 min'),
                 _buildLibraryItem('The Role of Exercise', 'Science - 4 min'),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _generateRecommendations(CognitiveProvider provider) {
    final recommendations = <Map<String, dynamic>>[];
    
    // Check latest scores and assume <60 is a deficit
    // Note: Scores default to 0.0 if not taken. We might want to skip recs if not taken (or recommend taking them).
    // For this prototype, if score is > 0 and < 60 -> Recommend.
    
    double attn = provider.getLatestScore(CognitiveDomain.atencion);
    if (attn > 0 && attn < 60) {
      recommendations.add({
        'title': 'Attention: Mindfulness Focus',
        'description': 'Guided audio to help strengthen sustained attention.',
        'duration': '10 min',
        'color': Colors.blue.shade800,
        'icon': Icons.self_improvement,
      });
    }

    double speed = provider.getLatestScore(CognitiveDomain.velocitatProcessament);
    if (speed > 0 && speed < 60) {
      recommendations.add({
        'title': 'Processing Speed: Basic Drills',
        'description': 'Improve your reaction time with these simple visual tasks.',
        'duration': '5 min',
        'color': Colors.orange.shade800,
        'icon': Icons.speed,
      });
    }

    double fluency = provider.getLatestScore(CognitiveDomain.fluenciaAlternant);
    if (fluency > 0 && fluency < 60) {
      recommendations.add({
        'title': 'Verbal Fluency Exercises',
        'description': 'Practice vocabulary generation techniques.',
        'duration': '8 min',
        'color': Colors.pink.shade800,
        'icon': Icons.chat,
      });
    }
    
    // Fallback if healthy or no data
    if (recommendations.isEmpty) {
        recommendations.add({
          'title': 'Daily Cognitive Workout',
          'description': 'Keep your brain sharp with a mix of exercises.',
          'duration': '15 min',
          'color': Colors.teal.shade800,
          'icon': Icons.fitness_center,
        });
    }

    return recommendations;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required String title,
    required String description,
    required String duration,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(icon, size: 40, color: Colors.white),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.teal),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: const TextStyle(fontSize: 12, color: Colors.teal),
                      ),
                      const Spacer(),
                      const Icon(Icons.play_circle_fill, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard(String title, String subtitle, IconData icon) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.teal.withValues(alpha: 0.2),
            child: Icon(icon, color: Colors.tealAccent),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLibraryItem(String title, String subtitle) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.article, color: Colors.blueGrey),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {},
    );
  }
}
