import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:flutter/foundation.dart';
import 'shop.dart';
import 'quests.dart';

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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cosmic_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4), // Adjust opacity (0.0 to 1.0)
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Flutter3DViewer(
                controller: _controller,
                src: 'assets/models/world.glb',
              ),
            ),

            Positioned(
              top: 60,
              left: 40,
              child: FloatingActionButton(
                child: const Icon(Icons.shopify),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopPage()),
                  );
                },
              ),
            ),

            Positioned(
              top: 60,
              right: 40,
              child: FloatingActionButton(
                child: const Icon(Icons.list_alt),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QuestsPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
