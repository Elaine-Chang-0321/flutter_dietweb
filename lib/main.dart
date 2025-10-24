import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    body: Center(
      child: Text("Your goals start with a meal.",
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
    ),
  ),
));