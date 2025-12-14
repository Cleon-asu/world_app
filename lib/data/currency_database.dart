import 'package:hive_flutter/hive_flutter.dart';

class CurrencyStorage {
  static const String _dataBox = 'currency_box';
  static const String _currencyKey = 'currency';
  static const String _selectedWorldLevelKey = 'selected_world_level';
  static const String _ownedItemsKey = 'owned_items';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_dataBox);
  }

  static int getCurrency() {
    final box = Hive.box(_dataBox);
    return box.get(_currencyKey, defaultValue: 0);
  }

  static Future<void> setCurrency(int value) async {
    final box = Hive.box(_dataBox);
    await box.put(_currencyKey, value);
  }

  static int getSelectedWorldLevel() {
    final box = Hive.box(_dataBox);
    return box.get(_selectedWorldLevelKey, defaultValue: 1);
  }

  static Future<void> setSelectedWorldLevel(int value) async {
    final box = Hive.box(_dataBox);
    await box.put(_selectedWorldLevelKey, value);
  }

  static List<int> getOwnedItems() {
    final box = Hive.box(_dataBox);
    return box.get(_ownedItemsKey, defaultValue: List.of([0]));
  }

  static Future<void> addOwnedItem(int value) async {
    final box = Hive.box(_dataBox);
    List<int> itemList = box.get(_ownedItemsKey, defaultValue: List.of([0]));
    itemList.add(value);
    await box.put(_ownedItemsKey, itemList);
  }
}
