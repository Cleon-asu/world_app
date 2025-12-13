import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter/foundation.dart';
import 'shop.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  late final Flutter3DController _controller;
  late final VoidCallback _modelLoadedListener;

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
  backgroundColor: Colors.black,
  body: Stack(
    children: [
      Center(
        child: Flutter3DViewer(
          controller: _controller,
          src: 'assets/models/astronaut.glb',
        ),
      ),

      // 🔵 Navigation button
      Positioned(
        bottom: 24,
        right: 24,
        child: FloatingActionButton(
          child: const Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ShopPage(),
              ),
            );
          },
        ),
      ),
    ],
  ),
);
  }
}