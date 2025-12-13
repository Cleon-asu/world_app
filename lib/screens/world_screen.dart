import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../world_provider.dart';
import '../models/world_object.dart';
import 'object_palette.dart';
import 'object_inspector.dart';

class WorldScreen extends StatefulWidget {
  const WorldScreen({super.key});

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen>
    with SingleTickerProviderStateMixin {
  late Flutter3DController _controller;
  late AnimationController _rotationController;
  late VoidCallback _modelLoadedListener;

  @override
  void initState() {
    super.initState();
    _controller = Flutter3DController();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Listen to model load state
    _modelLoadedListener = () {
      if (kDebugMode) {
        // only print during debug
        print('Model loaded: ${_controller.onModelLoaded.value}');
      }
    };
    _controller.onModelLoaded.addListener(_modelLoadedListener);
  }

  @override
  void dispose() {
    // Remove the listener to avoid leaks. Do not call controller.dispose()
    // unless the package documents it.
    _controller.onModelLoaded.removeListener(_modelLoadedListener);
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D World Builder'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddObjectDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => _clearWorld(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // Main 3D viewport
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black12,
              child: Column(
                children: [
                  Expanded(
                    child: _build3DViewport(),
                  ),
                  _buildObjectList(context),
                ],
              ),
            ),
          ),
          // Right sidebar
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: ObjectInspector(),
                ),
                Expanded(
                  child: ObjectPalette(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewport() {
    return Consumer<WorldProvider>(
      builder: (context, worldProvider, _) {
        if (worldProvider.objects.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public, size: 64, color: Colors.teal),
                const SizedBox(height: 20),
                const Text('Empty World'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showAddObjectDialog(context),
                  child: const Text('Add First Object'),
                ),
              ],
            ),
          );
        }

        // For MVP, display first object or selected object
        World3DObject displayObject = worldProvider.getObjectById(worldProvider.selectedObjectId) ?? worldProvider.objects.first;
        return Flutter3DViewer(
          controller: _controller,
          src: displayObject.modelPath,
        );
      },
    );
  }

  Widget _buildObjectList(BuildContext context) {
    return Consumer<WorldProvider>(
      builder: (context, worldProvider, _) {
        return Container(
          color: Colors.black26,
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: worldProvider.objects.length,
            itemBuilder: (context, index) {
              World3DObject obj = worldProvider.objects[index];
              bool isSelected = obj.id == worldProvider.selectedObjectId;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => worldProvider.selectObject(obj.id),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.cyan : Colors.teal.withAlpha(128),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black45,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.widgets, color: Colors.teal),
                        const SizedBox(height: 4),
                        Text(
                          obj.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 10),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showAddObjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String objectName = '';
        return AlertDialog(
          title: const Text('Add 3D Object'),
          content: TextField(
            onChanged: (value) => objectName = value,
            decoration: const InputDecoration(
              hintText: 'Enter object name',
              labelText: 'Object Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (objectName.isNotEmpty) {
                  // Use sample model path (replace with your actual GLB files)
                  World3DObject newObject = World3DObject(
                    name: objectName,
                    modelPath: 'assets/models/astronaut.glb', // Sample model
                    availableAnimations: ['Idle', 'Wave', 'Jump'],
                  );
                  context.read<WorldProvider>().addObject(newObject);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _clearWorld(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear World?'),
        content: const Text('This will remove all objects from the world.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<WorldProvider>().clearWorld();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
  }