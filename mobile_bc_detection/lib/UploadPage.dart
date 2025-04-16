import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'Controller.dart';
import 'ResultsPage.dart';  // add this at the top

class UploadHome extends StatefulWidget {
  @override
  _UploadHomeState createState() => _UploadHomeState();
}

class _UploadHomeState extends State<UploadHome> {
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  double responsiveHeight(double size, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return size * screenHeight / 812;
  }

  double responsiveWidth(double size, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return size * screenWidth / 375;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
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
                          child: Text("About Us", style: TextStyle(color: Color(0xFFD16D91))),
                        ),
                        SizedBox(width: 10),
                        TextButton(
                          onPressed: () {},
                          child: Text("Contact Us", style: TextStyle(color: Color(0xFFD16D91))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  margin: EdgeInsets.only(top: responsiveHeight(120, context)),
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A1A).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _selectedImageBytes == null
                      ? Column(
                    children: [
                      Icon(Icons.upload_file, size: 48, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'Upload Mammogram',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      _selectedImageBytes!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9C2F4A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                ),
                onPressed: _selectedImageBytes == null
                    ? null
                    : () async {
                  Uint8List? resultImageBytes = await Controller.uploadImage(_selectedImageBytes!);
                  if (resultImageBytes != null) {
                    // Navigate to ResultsPage and pass the image bytes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultsPage(imageBytes: resultImageBytes),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Upload failed ❌')),
                    );
                  }
                },
                child: Text(
                  'Send',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
