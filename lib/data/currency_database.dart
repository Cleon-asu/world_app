import 'package:hive_flutter/hive_flutter.dart';

class CurrencyStorage {
  static const String _currencyBox = 'currency_box';
  static const String _currencyKey = 'currency';
  
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_currencyBox);
  }
  
  static int getCurrency() {
    final box = Hive.box(_currencyBox);
    return box.get(_currencyKey, defaultValue: 0);
  }
  
  static Future<void> setCurrency(int value) async {
    final box = Hive.box(_currencyBox);
    await box.put(_currencyKey, value);
  }
}