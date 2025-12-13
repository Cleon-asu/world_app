import 'package:flutter/foundation.dart';
import 'models/world_object.dart';

class WorldProvider extends ChangeNotifier {
  final List<World3DObject> _objects = [];
  String _selectedObjectId = '';
  List<World3DObject> get objects => _objects;
  String get selectedObjectId => _selectedObjectId;
  World3DObject? getObjectById(String id) {
    try {
      return _objects.firstWhere((obj) => obj.id == id);
    } catch (e) {
      return null;
    }
  }

  void addObject(World3DObject object) {
    _objects.add(object);
    _selectedObjectId = object.id;
    notifyListeners();
  }

  void removeObject(String objectId) {
    _objects.removeWhere((obj) => obj.id == objectId);
    if (_selectedObjectId == objectId) {
      _selectedObjectId = _objects.isNotEmpty ? _objects.first.id : '';
    }
    notifyListeners();
  }

  void updateObject(String objectId, World3DObject updated) {
    int index = _objects.indexWhere((obj) => obj.id == objectId);
    if (index != -1) {
      _objects[index] = updated;
      notifyListeners();
    }
  }

  void selectObject(String objectId) {
    _selectedObjectId = objectId;
    notifyListeners();
  }

  void updateObjectAnimation(
    String objectId,
    String animationName,
    bool playing, {
    int loopCount = -1,
  }) {
    World3DObject? obj = getObjectById(objectId);
    if (obj != null) {
      updateObject(
        objectId,
        obj.copyWith(
          currentAnimation: animationName,
          animationPlaying: playing,
          animationLoopCount: loopCount,
        ),
      );
    }
  }

  void clearWorld() {
    _objects.clear();
    _selectedObjectId = '';
    notifyListeners();
  }
}
