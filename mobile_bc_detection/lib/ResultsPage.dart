import 'dart:typed_data';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'),
            fit: BoxFit.cover,
          ),
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
                        _buildHeader(),
                        _buildImageViewer(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SafeScan',
            style: TextStyle(
              color: Color(0xFFD16D91),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: const Text("About Us", style: TextStyle(color: Color(0xFFD16D91))),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {},
                child: const Text("Contact Us", style: TextStyle(color: Color(0xFFD16D91))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
          onToggleOverlay: _toggleOverlay, // Add this callback

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
        ),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UploadHome()),
        ),
        child: const Text(
          'Back to Upload',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}