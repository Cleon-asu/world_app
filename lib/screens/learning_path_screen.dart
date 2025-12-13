import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cognitive_provider.dart';
import '../models/cognitive_models.dart';
import '../models/treatment_models.dart';
import 'treatment_player_screen.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({super.key});

  // --- Static Content Definition ---

  static const _psychoeducationPath = TreatmentPath(
    pathId: "psychoeducation",
    title: "Understanding Cognitive Health",
    titleCA: "Entendre la salut cognitiva",
    description: "Fundamental knowledge about cognition and cognitive functions",
    category: "Psychoeducation",
    videos: [
      TreatmentVideo(
        id: "psy_001",
        title: "Cognition and Its Functions",
        titleCA: "La cognició i les seves funcions",
        youtubeUrl: "https://www.youtube.com/watch?v=hcBaJisV1Wo",
        category: "Psychoeducation",
        orderInPlaylist: 1,
      ),
      TreatmentVideo(
        id: "psy_002",
        title: "Cognitive Changes in Cancer",
        titleCA: "Canvis cognitius en el càncer",
        youtubeUrl: "https://www.youtube.com/watch?v=sB6u7ZhNrHk",
        category: "Psychoeducation",
        orderInPlaylist: 2,
      ),
      TreatmentVideo(
        id: "psy_003",
        title: "Managing Cognitive Symptoms",
        titleCA: "Gestionar símptomes cognitius",
        youtubeUrl: "https://www.youtube.com/watch?v=24P5B6L0IgQ",
        category: "Psychoeducation",
        orderInPlaylist: 3,
      ),
    ],
  );

  static const _mindfulnessAttentionPath = TreatmentPath(
    pathId: "mindfulness_attention",
    title: "Mindfulness for Attention",
    titleCA: "Mindfulness per l'atenció",
    description: "Mindfulness exercises to improve attention and focus",
    category: "Mindfulness",
    targetDomain: CognitiveDomain.atencion,
    videos: [
      TreatmentVideo(
        id: "mind_001",
        title: "Attention Exercise 1",
        titleCA: "Exercici d'atenció 1",
        youtubeUrl: "https://www.youtube.com/watch?v=B_M8eFq2GCA",
        category: "Mindfulness",
        orderInPlaylist: 1,
      ),
      TreatmentVideo(
        id: "mind_002",
        title: "Attention Exercise 2",
        titleCA: "Exercici d'atenció 2",
        youtubeUrl: "https://www.youtube.com/watch?v=_5HCl5CDA94",
        category: "Mindfulness",
        orderInPlaylist: 2,
      ),
      TreatmentVideo(
        id: "mind_003",
        title: "Attention Exercise 3",
        titleCA: "Exercici d'atenció 3",
        youtubeUrl: "https://www.youtube.com/watch?v=fXDHm8PP6qo",
        category: "Mindfulness",
        orderInPlaylist: 3,
      ),
       TreatmentVideo(
        id: "mind_004",
        title: "Attention Exercise 4",
        titleCA: "Exercici d'atenció 4",
        youtubeUrl: "https://www.youtube.com/watch?v=OlyIT2zIimw",
        category: "Mindfulness",
        orderInPlaylist: 4,
      ),
       TreatmentVideo(
        id: "mind_005",
        title: "Attention Exercise 5",
        titleCA: "Exercici d'atenció 5",
        youtubeUrl: "https://www.youtube.com/watch?v=zXqljYzFb3w",
        category: "Mindfulness",
        orderInPlaylist: 5,
      ),
    ],
  );

  static const _strategiesMemoryPath = TreatmentPath(
    pathId: "strategies_memory",
    title: "Memory Enhancement Strategies",
    titleCA: "Estratègies per millorar la memòria",
    description: "Practical techniques to improve memory retention and recall",
    category: "Strategies",
    targetDomain: CognitiveDomain.memoriaTreball,
    videos: [
      TreatmentVideo(
        id: "strat_mem_001",
        title: "Memory Strategy 1",
        titleCA: "Estratègia de memòria 1",
        youtubeUrl: "https://www.youtube.com/watch?v=RExO6edCQYk",
        category: "Strategies",
        orderInPlaylist: 1,
      ),
      TreatmentVideo(
        id: "strat_mem_002",
        title: "Memory Strategy 2",
        titleCA: "Estratègia de memòria 2",
        youtubeUrl: "https://www.youtube.com/watch?v=FJIy-R3Gze4",
        category: "Strategies",
        orderInPlaylist: 2,
      ),
      TreatmentVideo(
        id: "strat_mem_003",
        title: "Memory Strategy 3",
        titleCA: "Estratègia de memòria 3",
        youtubeUrl: "https://www.youtube.com/watch?v=iGTnb1YeRNw",
        category: "Strategies",
        orderInPlaylist: 3,
      ),
    ],
  );

  static const _strategiesSpeedPath = TreatmentPath(
    pathId: "strategies_speed",
    title: "Processing Speed Techniques",
    titleCA: "Tècniques per la velocitat de processament",
    description: "Strategies to improve cognitive processing speed",
    category: "Strategies",
    targetDomain: CognitiveDomain.velocitatProcessament,
    videos: [
      TreatmentVideo(
        id: "strat_speed_001",
        title: "Speed Strategy 1",
        titleCA: "Estratègia velocitat 1",
        youtubeUrl: "https://www.youtube.com/watch?v=RExO6edCQYk",
        category: "Strategies",
        orderInPlaylist: 1,
      ),
       TreatmentVideo(
        id: "strat_speed_002",
        title: "Speed Strategy 2",
        titleCA: "Estratègia velocitat 2",
        youtubeUrl: "https://www.youtube.com/watch?v=FJIy-R3Gze4",
        category: "Strategies",
        orderInPlaylist: 2,
      ),
    ],
  );

  static const _mindfulnessFluencyPath = TreatmentPath(
    pathId: "mindfulness_fluency",
    title: "Mindfulness for Verbal Fluency",
    titleCA: "Mindfulness per la fluència verbal",
    description: "Mindfulness practices to enhance verbal expression",
    category: "Mindfulness",
    targetDomain: CognitiveDomain.fluenciaAlternant,
    videos: [
      TreatmentVideo(
        id: "mind_flu_001",
        title: "Fluency Exercise 1",
        titleCA: "Exercici fluència 1",
        youtubeUrl: "https://www.youtube.com/watch?v=B_M8eFq2GCA",
        category: "Mindfulness",
        orderInPlaylist: 1,
      ),
       TreatmentVideo(
        id: "mind_flu_002",
        title: "Fluency Exercise 2",
        titleCA: "Exercici fluència 2",
        youtubeUrl: "https://www.youtube.com/watch?v=_5HCl5CDA94",
        category: "Mindfulness",
        orderInPlaylist: 2,
      ),
       TreatmentVideo(
        id: "mind_flu_003",
        title: "Fluency Exercise 3",
        titleCA: "Exercici fluència 3",
        youtubeUrl: "https://www.youtube.com/watch?v=fXDHm8PP6qo",
        category: "Mindfulness",
        orderInPlaylist: 3,
      ),
       TreatmentVideo(
        id: "mind_flu_004",
        title: "Fluency Exercise 4",
        titleCA: "Exercici fluència 4",
        youtubeUrl: "https://www.youtube.com/watch?v=OlyIT2zIimw",
        category: "Mindfulness",
        orderInPlaylist: 4,
      ),
       TreatmentVideo(
        id: "mind_flu_005",
        title: "Fluency Exercise 5",
        titleCA: "Exercici fluència 5",
        youtubeUrl: "https://www.youtube.com/watch?v=zXqljYzFb3w",
        category: "Mindfulness",
        orderInPlaylist: 5,
      ),
    ],
  );

  static const _lifestylePath = TreatmentPath(
    pathId: "lifestyle_prevention",
    title: "Maintaining Cognitive Health",
    titleCA: "Mantenir la salut cognitiva",
    description: "Congratulations! No cognitive issues detected. Maintain healthy habits:",
    category: "Lifestyle",
    videos: [
      TreatmentVideo(
        id: "life_001",
        title: "Exercise for Brain Health",
        titleCA: "Fer esport",
        youtubeUrl: "",
        category: "Exercise",
        orderInPlaylist: 1,
      ),
      TreatmentVideo(
        id: "life_002",
        title: "Nutrition and Cognition",
        titleCA: "Cuidar l'alimentació",
        youtubeUrl: "",
        category: "Nutrition",
        orderInPlaylist: 2,
      ),
      TreatmentVideo(
        id: "life_003",
        title: "Continuous Learning",
        titleCA: "Aprendre coses noves",
        youtubeUrl: "",
        category: "Learning",
        orderInPlaylist: 3,
      ),
      TreatmentVideo(
        id: "life_004",
        title: "Social Engagement",
        titleCA: "Sociabilitzar",
        youtubeUrl: "",
        category: "Social",
        orderInPlaylist: 4,
      ),
      TreatmentVideo(
        id: "life_005",
        title: "Mindfulness Practice",
        titleCA: "Fer Mindfulness",
        youtubeUrl: "",
        category: "Mindfulness",
        orderInPlaylist: 5,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<CognitiveProvider>(
      builder: (context, provider, child) {
        final assignedPaths = _generateRecommendations(provider);

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
                if (assignedPaths.isEmpty)
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 16),
                     child: Text('Complete assessments to get personalized recommendations.', style: TextStyle(color: Colors.grey)),
                   )
                else
                   ...assignedPaths.map((path) => _buildPathCard(context, path)),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TreatmentPath> _generateRecommendations(CognitiveProvider provider) {
    final assignedPaths = <TreatmentPath>[];
    bool anyDeficit = false;

    // Helper check deficit: Objective < 60 OR Subjective >= 3
    bool hasDeficit(CognitiveDomain domain) {
      final objScore = provider.getLatestScore(domain);
      final subjScore = provider.getSubjectiveScore(domain);
      
      // Objective Deficit: Score exists (>0) and is low (<60)
      final bool objDeficit = objScore > 0 && objScore < 60;
      
      // Subjective Deficit: Score exists (>0?) and is high (>=3) (1-5 scale, 5 is bad)
      // Assuming 0 means not taken/no data
      final bool subjDeficit = subjScore >= 3.0;

      return objDeficit || subjDeficit;
    }

    // Check Domains
    final bool attDeficit = hasDeficit(CognitiveDomain.atencion);
    final bool memDeficit = hasDeficit(CognitiveDomain.memoriaTreball);
    final bool speedDeficit = hasDeficit(CognitiveDomain.velocitatProcessament);
    final bool fluDeficit = hasDeficit(CognitiveDomain.fluenciaAlternant);
    final bool execDeficit = hasDeficit(CognitiveDomain.funcionsExecutives);

    if (attDeficit || memDeficit || speedDeficit || fluDeficit || execDeficit) {
        anyDeficit = true;
        // Always add Psychoeducation if ANY deficit
        assignedPaths.add(_psychoeducationPath);
    }

    if (attDeficit) assignedPaths.add(_mindfulnessAttentionPath);
    if (memDeficit) assignedPaths.add(_strategiesMemoryPath);
    if (speedDeficit) assignedPaths.add(_strategiesSpeedPath);
    if (fluDeficit) assignedPaths.add(_mindfulnessFluencyPath);
    
    // Fallback: If no deficits found (and assuming at least some data exists to say "healthy")
    // Or if currently we just want to show Lifestyle when nothing else matches
    if (!anyDeficit) {
      // Check if we actually have data? Or just default to Lifestyle?
      // Prompt says: "Shown when all domains are healthy"
      // We will show it if no other paths were added.
      assignedPaths.add(_lifestylePath);
    }

    return assignedPaths;
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

  Widget _buildPathCard(BuildContext context, TreatmentPath path) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForCategory(path.category).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(_getIconForCategory(path.category), color: _getColorForCategory(path.category), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(path.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(path.category.toUpperCase(), style: TextStyle(fontSize: 12, color: _getColorForCategory(path.category), letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(path.description, style: const TextStyle(color: Colors.grey)),
          ),
          // Videos List
          ...path.videos.map((video) => ListTile(
            leading: const Icon(Icons.play_circle_outline, color: Colors.white70),
            title: Text(video.title, style: const TextStyle(fontSize: 14)),
            subtitle: Text(video.titleCA, style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TreatmentPlayerScreen(video: video),
                ),
              );
            },
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case "Psychoeducation": return Colors.blueAccent;
      case "Mindfulness": return Colors.purpleAccent;
      case "Strategies": return Colors.orangeAccent;
      case "Lifestyle": return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  IconData _getIconForCategory(String category) {
     switch (category) {
      case "Psychoeducation": return Icons.school;
      case "Mindfulness": return Icons.self_improvement;
      case "Strategies": return Icons.lightbulb;
      case "Lifestyle": return Icons.favorite;
      default: return Icons.article;
    }
  }
}
