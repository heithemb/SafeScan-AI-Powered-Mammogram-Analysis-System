import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Controller.dart';
import 'ResultsPage.dart';

class UploadHome extends StatefulWidget {
  @override
  _UploadHomeState createState() => _UploadHomeState();
}

class _UploadHomeState extends State<UploadHome> {
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  double responsiveFont(double size, double screenWidth) {
    final scale = screenWidth / 375;
    return (size * scale).clamp(size * 0.8, size * 1.2);
  }

  Widget _navButton(String title, double fontSize) {
    return TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color(0xFFD16D91),
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final font24 = responsiveFont(24, screenWidth);
    final font14 = responsiveFont(14, screenWidth);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'SafeScan',
                style: GoogleFonts.inter(
                  color: const Color(0xFFD16D91),
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
                  const SizedBox(width: 12),
                  _navButton('Contact Us', font14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _selectedImageBytes = bytes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final font16 = responsiveFont(16, screenWidth);
    final boxSize = min(screenWidth * 0.8, screenHeight * 0.5);

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // Background layers
            Positioned.fill(
              child: Image.asset('assets/bg2.jpg', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.6)),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(screenWidth),
                    const SizedBox(height: 120),
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: boxSize,
                          height: boxSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A).withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: _selectedImageBytes == null
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload_file,
                                  size: 48, color: Colors.white),
                              const SizedBox(height: 10),
                              Text(
                                'Upload Mammogram',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: font16,
                                ),
                              ),
                            ],
                          )
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.memory(
                              _selectedImageBytes!,
                              width: boxSize,
                              height: boxSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedImageBytes != null) ...[
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(121, 0, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 16),
                        ),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          final result = await Controller.uploadImage(
                              _selectedImageBytes!);
                          setState(() => _isLoading = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResultsPage(
                                originalImageBytes: _selectedImageBytes!,
                                result: result ?? {},
                                hasDetections: result != null,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Send',
                          style: GoogleFonts.inter(
                              fontSize: font16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.77),
                  child: Center(
                    child: Lottie.asset('assets/lottie/lottie_loading2.json',
                        width: 320, height: 320),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}