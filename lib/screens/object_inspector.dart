import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../world_provider.dart';
import '../models/world_object.dart';

class ObjectInspector extends StatelessWidget {
  const ObjectInspector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorldProvider>(
      builder: (context, worldProvider, _) {
        World3DObject? selected =
            worldProvider.getObjectById(worldProvider.selectedObjectId);
        if (selected == null) {
          return const Center(
            child: Text('Select an object'),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selected.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildSlider(
                  'Scale',
                  selected.scaleX,
                  0.1,
                  3.0,
                  (value) {
                    worldProvider.updateObject(
                      selected.id,
                      selected.copyWith(
                        scaleX: value,
                        scaleY: value,
                        scaleZ: value,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildAnimationControls(context, selected, worldProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildAnimationControls(
    BuildContext context,
    World3DObject object,
    WorldProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animation'),
        const SizedBox(height: 8),
        ...object.availableAnimations.map(
          (anim) => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                provider.updateObjectAnimation(
                  object.id,
                  anim,
                  true,
                  loopCount: -1,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    object.currentAnimation == anim ? Colors.cyan : Colors.teal,
              ),
              child: Text(anim),
            ),
          ),
        ),
      ],
    );
  }
}
