import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_bc_detection/header.dart';
import 'uploadpage.dart';
import 'image_viewer.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> result;
  final Uint8List originalImageBytes;
  final bool hasDetections;

  const ResultsPage({
    Key? key,
    required this.result,
    required this.originalImageBytes,
    required this.hasDetections,
  }) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isZoomEnabled = ValueNotifier<bool>(false);
  late final AnimationController _animationController;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
      _showOverlay ? _animationController.forward() : _animationController.reverse();
    });
  }


  Widget _buildImageViewer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final maxW = screenWidth * 0.9;
    final maxH = screenHeight * 0.9;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ImageViewer(
            result: widget.result,
            originalImageBytes: widget.originalImageBytes,
            hasDetections: widget.hasDetections,
            isZoomEnabled: isZoomEnabled,
            animationController: _animationController,
            showOverlay: _showOverlay,
            onToggleOverlay: _toggleOverlay,
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(121, 0, 0, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          foregroundColor: Colors.white,
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UploadHome()),
        ),
        child: const Text('Back to Upload', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/bg2.jpg'), fit: BoxFit.cover),
        ),
        child: Container(
          color: Color.fromARGB(150, 42, 14, 24),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        buildHeader(context,screenWidth),
                        _buildImageViewer(context),
                        _buildBackButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}