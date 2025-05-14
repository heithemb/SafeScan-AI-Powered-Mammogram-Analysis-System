import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Controller.dart';
import 'ResultsPage.dart';
import 'header.dart';

class UploadHome extends StatefulWidget {
  @override
  _UploadHomeState createState() => _UploadHomeState();
}

class _UploadHomeState extends State<UploadHome> {
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  String? _selectedSystem;
  bool _showManualInput = false;
  String? _fileExtension;
  final TextEditingController _pixelSizeController = TextEditingController();

  final List<Map<String, dynamic>> _mammogramSystems = [
    {'name': 'uMammo 890i', 'size': 0.0495},
    {'name': 'uMammo 590u', 'size': 0.076},
    {'name': 'uMammo 590i', 'size': 0.085},
    {'name': 'BEMEMS Pinkview-DR Smart', 'size': 0.075},
    {'name': 'Fujifilm FCRm', 'size': 0.050},
    {'name': 'Siemens Mammomat Inspiration (70)', 'size': 0.070},
    {'name': 'Siemens Mammomat Inspiration (85)', 'size': 0.085},
    {'name': 'GE Senographe Essential', 'size': 0.100},
    {'name': 'Hologic Selenia Dimensions', 'size': 0.070},
    {'name': 'Philips MicroDose', 'size': 0.050},
    {'name': 'Agfa DX-M HM5.0', 'size': 0.050},
    {'name': 'Agfa DR 24M', 'size': 0.076},
    {'name': 'Other', 'size': null},
  ];

  double _calculatePixelSpacing() {
    if (_selectedSystem == 'Other') {
      return double.tryParse(_pixelSizeController.text) ?? 0.0;
    } else {
      final system = _mammogramSystems.firstWhere(
            (system) => system['name'] == _selectedSystem,
        orElse: () => {'size': 0.0},
      );
      return system['size'] ?? 0.0;
    }
  }

  @override
  void dispose() {
    _pixelSizeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'dcm', 'dicom'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _selectedImageBytes = result.files.single.bytes;
        _fileExtension = result.files.single.extension?.toLowerCase();
      });
    }
  }

  Widget _buildSystemSelection(double screenWidth) {
    final font14 = responsiveFont(14, screenWidth);
    final font12 = responsiveFont(12, screenWidth);
    final maxWidth = min(500.0, screenWidth);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: maxWidth,
          child: DropdownButtonFormField<String>(
            value: _selectedSystem,
            decoration: InputDecoration(
              labelText: 'Select Mammogram System',
              labelStyle: GoogleFonts.inter(color: Colors.white, fontSize: font14),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFD16D91)),
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
            ),
            dropdownColor: const Color(0xFF1A1A1A).withOpacity(0.9),
            style: GoogleFonts.inter(color: Colors.white, fontSize: font14),
            items: _mammogramSystems.map((system) {
              return DropdownMenuItem<String>(
                value: system['name'],
                child: Text(system['name']),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSystem = value;
                _showManualInput = value == 'Other';
              });
            },
            validator: (value) =>
            value == null ? 'Please select a mammogram system' : null,
          ),
        ),
        if (_showManualInput)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: SizedBox(
              width: maxWidth,
              child: TextFormField(
                controller: _pixelSizeController,
                style: GoogleFonts.inter(color: Colors.white, fontSize: font14),
                decoration: InputDecoration(
                  labelText: 'Enter Pixel Size (mm)',
                  labelStyle: GoogleFonts.inter(color: Colors.white, fontSize: font14),
                  hintText: 'e.g., 0.1',
                  hintStyle: GoogleFonts.inter(color: Colors.white54, fontSize: font12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFD16D91)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A).withOpacity(0.7),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_selectedSystem == 'Other' && (value == null || value.isEmpty)) {
                    return 'Please enter pixel size';
                  }
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
          ),
      ],
    );
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
            Positioned.fill(
              child: Image.asset('assets/bg2.jpg', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Container(color: const Color.fromARGB(150, 42, 14, 24)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildHeader(context, screenWidth),
                    const SizedBox(height: 60),
                    Center(
                      child: GestureDetector(
                        onTap: _pickFile,
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
                              Icon(Icons.upload_file, size: 48, color: Colors.white),
                              const SizedBox(height: 10),
                              Text(
                                'Upload Mammogram',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: font16),
                              ),
                            ],
                          )
                              : (_fileExtension == 'dcm' || _fileExtension == 'dicom')
                              ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.description, size: 48, color: Colors.white),
                              const SizedBox(height: 10),
                              Text(
                                'DICOM file uploaded',
                                style: GoogleFonts.inter(color: Colors.white, fontSize: font16),
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
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: _buildSystemSelection(screenWidth),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(121, 0, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                        ),
                        onPressed: () async {
                          if (_selectedSystem == null) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Please select a mammogram system', style: GoogleFonts.inter()),
                              backgroundColor: Colors.black,
                            ));
                            return;
                          }
                          if (_selectedSystem == 'Other' &&
                              (_pixelSizeController.text.isEmpty || double.tryParse(_pixelSizeController.text) == null)) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Please enter a valid pixel spacing', style: GoogleFonts.inter()),
                              backgroundColor: Colors.black,
                            ));
                            return;
                          }

                          setState(() => _isLoading = true);
                          final pixelSpacing = _calculatePixelSpacing();
                          final result = await Controller.uploadImage(_selectedImageBytes!,_fileExtension!, pixelSpacing);
                          setState(() => _isLoading = false);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResultsPage(
                                  originalImageBytes: result?['full_Normal_image']!,
                                  result: result ?? {},
                                  hasDetections: result?['detections'],
                                ),
                              ),
                            );

                        },
                        child: Text('Send', style: GoogleFonts.inter(fontSize: font16, color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.77),
                  child: Center(
                    child: Lottie.asset('assets/lottie/lottie_loading2.json', width: 320, height: 320),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
