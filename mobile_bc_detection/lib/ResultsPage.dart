import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Responsive helpers
  double responsiveFont(double size, double screenWidth) {
    final scale = screenWidth / 375; // base mobile width
    final scaled = size * scale;
    return scaled.clamp(size * 0.8, size * 1.2);
  }

  Widget _navButton(String title, double fontSize) {
    return TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFFF27A9D),
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final font24 = responsiveFont(24, screenWidth);
    final font14 = responsiveFont(14, screenWidth);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'SafeScan',
                style: GoogleFonts.inter(
                  color: const Color(0xFFF27A9D),
                  fontSize: font24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  _navButton('About Us', font14),
                  SizedBox(width: 12),
                  _navButton('Contact Us', font14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        _buildHeader(screenWidth),
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