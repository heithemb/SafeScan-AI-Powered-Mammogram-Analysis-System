import 'dart:typed_data';
import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final Uint8List imageBytes;

  ResultsPage({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Center(
        child: Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
