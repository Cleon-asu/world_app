import 'package:hive_flutter/hive_flutter.dart';

class CurrencyStorage {
  static const String _dataBox = 'currency_box';
  static const String _currencyKey = 'currency';
  static const String _worldLevelKey = 'world_level';

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

  static int getWorldLevel() {
    final box = Hive.box(_dataBox);
    return box.get(_worldLevelKey, defaultValue: 1);
  }

  static Future<void> setWorldLevel(int value) async {
    final box = Hive.box(_dataBox);
    await box.put(_worldLevelKey, value);
  }
}
