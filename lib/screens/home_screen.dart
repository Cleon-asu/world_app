import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter/foundation.dart';
import 'shop.dart';
import 'objective_assessment_screen.dart';
import 'ema_screen.dart';
import 'learning_path_screen.dart';
import 'package:world_app/data/currency_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Flutter3DController _controller;
  late final VoidCallback _modelLoadedListener;
  int _worldLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadWorldLevel();

    _controller = Flutter3DController();

    _modelLoadedListener = () {
      if (kDebugMode) {
        print('Model loaded: ${_controller.onModelLoaded.value}');
      }
    };

    _controller.onModelLoaded.addListener(_modelLoadedListener);
  }

  @override
  void dispose() {
    _controller.onModelLoaded.removeListener(_modelLoadedListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWorldLevel();
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cosmic_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Flutter3DViewer(
                controller: _controller,
                src: _getModelPath(_worldLevel),
              ),
            ),

            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    child: const Icon(Icons.shopify),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopPage()),
                      );
                    },
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.calendar_month),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EMAScreen()),
                      );
                    },
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.book),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LearningPathScreen(),
                        ),
                      );
                    },
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.bar_chart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ObjectiveAssessmentScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadWorldLevel() {
    final value = CurrencyStorage.getSelectedWorldLevel();
    setState(() {
      _worldLevel = value;
    });
  }

  String _getModelPath(int worldLevel) {
    List<String> modelPaths = [
      'assets/models/world_1.glb',
      'assets/models/world_2.glb',
      'assets/models/world_3.glb',
      'assets/models/world_4.glb',
    ];
    return modelPaths[worldLevel-1];
  }
}
