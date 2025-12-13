import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../world_provider.dart';
import '../models/world_object.dart';

class ObjectPalette extends StatelessWidget {
  final List<Map<String, dynamic>> availableModels = const [
    {
      'name': 'Robot',
      'path': 'assets/models/robot.glb',
      'animations': ['Idle', 'Walk', 'Run', 'Jump'],
    },
    {
      'name': 'Astronaut',
      'path': 'assets/models/astronaut.glb',
      'animations': ['Idle', 'Wave', 'Dance'],
    },
    {
      'name': 'Tree',
      'path': 'assets/models/tree.glb',
      'animations': ['Sway', 'Grow'],
    },
    {
      'name': 'Crystal',
      'path': 'assets/models/crystal.glb',
      'animations': ['Spin', 'Pulse'],
    },
  ];

  const ObjectPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Object Palette',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: availableModels.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> model = availableModels[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      World3DObject newObject = World3DObject(
                        name:
                            '${model['name']} ${context.read<WorldProvider>().objects.length + 1}',
                        modelPath: model['path'],
                        availableAnimations:
                            List<String>.from(model['animations']),
                      );
                      context.read<WorldProvider>().addObject(newObject);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(model['name']),
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
