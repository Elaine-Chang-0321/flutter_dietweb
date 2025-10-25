import 'package:flutter/material.dart';
import 'package:flutter_dietweb/pages/home_page.dart';
import 'package:flutter_dietweb/pages/record_page.dart';
import 'package:flutter_dietweb/pages/history_page.dart';
import 'package:flutter_dietweb/stores/goal_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoalStore>(
          create: (_) => GoalStore(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/record': (context) => const RecordPage(),
          '/history': (context) => const HistoryPage(),
        },
      ),
    );
  }
}