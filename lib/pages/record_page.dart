import 'package:flutter/material.dart';

class RecordPage extends StatelessWidget {
  const RecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Meal Page'),
      ),
      body: const Center(
        child: Text('Record Meal Page'),
      ),
    );
  }
}