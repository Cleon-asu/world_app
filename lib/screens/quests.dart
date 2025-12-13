import 'package:flutter/material.dart';

class QuestsPage extends StatelessWidget {
  const QuestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quests Page'),
      ),
      body: const Center(
        child: Text(
          'This is a placeholder page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}