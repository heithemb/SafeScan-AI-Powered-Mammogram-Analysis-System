import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'uploadpage.dart';

class ResultsPage extends StatefulWidget {
  final Uint8List imageBytes;
  final Uint8List originalImageBytes;
  final bool hasDetections; // Add this



  ResultsPage({required this.imageBytes, required this.originalImageBytes , required this.hasDetections,});
  

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> isZoomEnabled = ValueNotifier<bool>(false);
  late AnimationController _animationController;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
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
      if (_showOverlay) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildImageStack() {
    return Stack(
      children: [
        
        Image.memory(
          widget.imageBytes,
          fit: BoxFit.cover,
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _animationController.value,
              child: Image.memory(
              widget.originalImageBytes,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 40.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
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
                                      child: Text(
                                        "About Us",
                                        style: TextStyle(color: Color(0xFFD16D91)),),
                                    ),
                                    SizedBox(width: 10),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Contact Us",
                                        style: TextStyle(color: Color(0xFFD16D91)),)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Center(
  child: Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: Color(0xFF1A1A1A).withOpacity(0.85),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Stack(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isZoomEnabled,
          builder: (context, zoomEnabled, child) {
            return zoomEnabled
                ? InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: _buildImageStack(),
                  )
                : _buildImageStack();
          },
        ),
        
        // No detection overlay (only shows when hasDetections is false AND not showing original image)
        if (!widget.hasDetections && _animationController.value == 0)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.77),
              alignment: Alignment.center,
              child: Text(
                'No Abnormality detected',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Overlay toggle button
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Icon(
                        _showOverlay 
                          ? Icons.layers_clear 
                          : Icons.layers,
                        color: Colors.white,
                      );
                    },
                  ),
                  onPressed: _toggleOverlay,
                ),
              ),
              SizedBox(width: 10),
              // Zoom button
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isZoomEnabled,
                  builder: (context, zoomEnabled, child) {
                    return IconButton(
                      icon: Icon(
                        zoomEnabled
                            ? Icons.zoom_out_map
                            : Icons.zoom_in_map,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        isZoomEnabled.value = !isZoomEnabled.value;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return _animationController.value > 0.0
                  ? Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _showOverlay 
                          ? 'Original image visible' 
                          : 'Original image fading out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : SizedBox.shrink();
            },
          ),
        ),
      ],
    ),
  ),
),
                          SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(169, 0, 0, 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 16),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UploadHome()),
                                );
                              },
                              child: Text(
                                'Back to Upload',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}