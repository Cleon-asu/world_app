import 'package:flutter/material.dart';

class ObjectiveAssessmentScreen extends StatelessWidget {
  const ObjectiveAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Objective Assessments'),
        automaticallyImplyLeading: false, // Don't show back button in tabs
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          const Text(
            'Domain Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildResultCard(
            context,
            title: 'Verbal Fluency',
            score: 85,
            description: 'Word generation speed and flexibility.',
            icon: Icons.chat_bubble_outline,
          ),
          _buildResultCard(
            context,
            title: 'Attention',
            score: 72,
            description: 'Sustained focus and selective attention.',
            icon: Icons.visibility_outlined,
          ),
          _buildResultCard(
            context,
            title: 'Working Memory',
            score: 90,
            description: 'Short-term information retention.',
            icon: Icons.memory_outlined,
          ),
          _buildResultCard(
            context,
            title: 'Processing Speed',
            score: 45,
            description: 'Speed of cognitive task completion.',
            icon: Icons.speed_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
                _buildMetricColumn('73%', 'Accuracy'),
                _buildMetricColumn('14m', 'Time'),
                _buildMetricColumn('Avg', 'Speed'),
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.tealAccent),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context, {
    required String title,
    required double score,
    required String description,
    required IconData icon,
  }) {
    // Determine color and status based on score
    Color statusColor;
    String statusText;
    
    if (score >= 80) {
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(50), 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withAlpha(100)),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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
    );
  }
}
