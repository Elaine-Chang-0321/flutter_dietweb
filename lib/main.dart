import 'package:flutter/material.dart';
import 'package:flutter_dietweb/pages/home_page.dart';
import 'package:flutter_dietweb/pages/record_page.dart';
import 'package:flutter_dietweb/pages/history_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/record': (context) => const RecordPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}