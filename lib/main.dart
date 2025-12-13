import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'world_provider.dart';
import 'screens/home_screen.dart';
import 'data/currency_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await CurrencyStorage.init();
  runApp(const WorldBuilderApp());
}

class WorldBuilderApp extends StatelessWidget {
  const WorldBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorldProvider()),
      ],
      child: MaterialApp(
        title: '3D World Builder',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.teal,
          colorScheme: ColorScheme.dark(
            primary: Colors.teal,
            secondary: Colors.cyan,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
