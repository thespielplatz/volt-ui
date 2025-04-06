import 'package:flutter/material.dart';
import 'package:volt_ui/layout/the_header.dart';
import 'package:volt_ui/pages/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Volt UI';
    return const MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: TheHeader(title: appTitle),
        backgroundColor: Color(0xFF0F1B34),
        body: HomePage(),
      ),
    );
  }
}
