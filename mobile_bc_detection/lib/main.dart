import 'dart:ui';
import 'package:flutter/material.dart';
import 'UploadPage.dart';
import 'LandingPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/':(context)=>LandingPage(),
        '/UploadPage':(context)=>UploadHome(),
      },
    );
  }
}