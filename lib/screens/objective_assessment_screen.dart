import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cognitive_provider.dart';
import '../models/cognitive_models.dart';
import 'assessments/fluency_assessment_screen.dart';
import 'assessments/attention_assessment_screen.dart';
import 'assessments/processing_speed_screen.dart';
import 'assessments/working_memory_assessment_screen.dart';

class ObjectiveAssessmentScreen extends StatelessWidget {
  const ObjectiveAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CognitiveProvider>(
      builder: (context, provider, child) {
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCard(provider),
                const SizedBox(height: 20),
                const Text(
                  'Domain Performance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildResultCard(
                  context,
                  title: 'Verbal Fluency',
                  score: provider.getLatestScore(
                    CognitiveDomain.fluenciaAlternant,
                  ),
                  description: 'Word generation speed and flexibility.',
                  icon: Icons.chat_bubble_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FluencyAssessmentScreen(),
                      ),
                    );
                  },
                ),
                _buildResultCard(
                  context,
                  title: 'Attention',
                  score: provider.getLatestScore(CognitiveDomain.atencion),
                  description: 'Sustained focus and selective attention.',
                  icon: Icons.visibility_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AttentionAssessmentScreen(),
                      ),
                    );
                  },
                ),
                _buildResultCard(
                  context,
                  title: 'Working Memory',
                  score: provider.getLatestScore(
                    CognitiveDomain.memoriaTreball,
                  ),
                  description: 'Short-term information retention.',
                  icon: Icons.memory_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WorkingMemoryAssessmentScreen(),
                      ),
                    );
                  },
                ),
                _buildResultCard(
                  context,
                  title: 'Processing Speed',
                  score: provider.getLatestScore(
                    CognitiveDomain.velocitatProcessament,
                  ),
                  description: 'Speed of cognitive task completion.',
                  icon: Icons.speed_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProcessingSpeedScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(CognitiveProvider provider) {
    // Calculate overall health or other stats if available
    // For now we mock the "overall" stats based on existing data if present
    return Card(
      elevation: 4,
      color: Colors.teal.shade900,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Overall Cognitive Health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn(
                  '--',
                  'Accuracy',
                ), // Placeholder for aggregation logic
                _buildMetricColumn('--', 'Time'),
                _buildMetricColumn('--', 'Speed'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.tealAccent,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required int score,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    Color statusColor;
    String statusText;

    // Logic for "No Data" vs Score
    if (score == 0.0) {
      statusColor = Colors.grey;
      statusText = 'Start';
    } else if (score >= 80) {
      statusColor = Colors.greenAccent;
      statusText = 'Normal';
    } else if (score >= 60) {
      statusColor = Colors.yellowAccent;
      statusText = 'Mild Concern';
    } else {
      statusColor = Colors.redAccent;
      statusText = 'Significant';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: Colors.teal),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (score > 0)
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: score / 100,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${score.toInt()}/100',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
