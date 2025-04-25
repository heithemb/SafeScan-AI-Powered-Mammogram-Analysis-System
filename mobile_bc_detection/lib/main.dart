import 'dart:ui';
import 'package:flutter/material.dart';
import 'UploadPage.dart';
import 'LandingPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey aboutUsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(aboutUsKey: aboutUsKey), // Pass the GlobalKey here
        '/UploadPage':(context)=>UploadHome(),
      },
    );
  }
}
