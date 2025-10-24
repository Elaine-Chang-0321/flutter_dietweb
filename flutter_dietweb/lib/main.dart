import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    body: Center(
      child: Text("Let's go diet",
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
    ),
  ),
));