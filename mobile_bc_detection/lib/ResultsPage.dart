import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'uploadpage.dart'; // Make sure to import your UploadHome page

class ResultsPage extends StatelessWidget {
  final Uint8List imageBytes;

  ResultsPage({required this.imageBytes});

  double responsiveHeight(double size, BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return size * screenHeight / 812;
  }

  double responsiveWidth(double size, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return size * screenWidth / 375;
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
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A1A).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                width: 	382,
                                height: 458,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: InteractiveViewer(
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Image.memory(
                                      imageBytes,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF9C2F4A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => UploadHome()),
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
