import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive design helpers
    double responsiveFont(double size) {
      final scale = screenWidth / 375; // Base width: iPhone 11
      return (size * scale).clamp(size * 0.8, size * 1.5); // Limit scaling range
    }
    
    double responsiveWidth(double size) => size * screenWidth / 375;
    double responsiveHeight(double size) => size * screenHeight / 812;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/bg2.jpg', // Replace with your asset path
              fit: BoxFit.cover,
            ),
          ),
          
          // Color overlay for better text visibility
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(150, 42, 14, 24), // Semi-transparent overlay
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsiveWidth(24),
                    vertical: responsiveHeight(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Top bar - always in one line
                      SizedBox(
                        width: double.infinity,
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
                                    fontSize: responsiveFont(24),
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
                                    _navButton('About Us', responsiveFont(14)),
                                    SizedBox(width: responsiveWidth(12)),
                                    _navButton('Contact Us', responsiveFont(14)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: responsiveHeight(40)),

                      /// Image box
                      Center(
                        child: Container(
                          width: screenWidth * 0.8,
                          height: screenWidth * 0.8,
                          constraints: BoxConstraints(
                            maxWidth: responsiveWidth(300),
                            maxHeight: responsiveWidth(300),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: const DecorationImage(
                              image: AssetImage('assets/mammo.png'),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              color: const Color(0xFFF27A9D), 
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Container(
                                margin: EdgeInsets.only(
                                      top: responsiveWidth(100),
                                      right: responsiveWidth(0),
                                    ),                              
                                padding: EdgeInsets.symmetric(
                                horizontal: responsiveWidth(30),
                                vertical: responsiveHeight(30),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x80F27A9D),
                                borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(8),  // Circular on left
                                          right: Radius.circular(0),),
                                border: Border.all(color: const Color(0xFFF27A9D)),
                              ),
                              child: Text(
                                'MALIGNANCY',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsiveFont(14),
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(40)),

                      /// Title
                      Center(
                        child: Text(
                          'Empowering Early Detection\nwith AI',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFF27A9D),
                            fontSize: responsiveFont(24),
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(16)),

                      /// Subtitle
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsiveWidth(16)),
                          child: Text(
                            'SafeScan helps you detect potential breast cancer signs using AI-powered analysis of mammogram images.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: responsiveFont(14),
                              height: 1.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveHeight(32)),

                      /// Get Started button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/UploadPage');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA2314E),
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveWidth(40),
                              vertical: responsiveHeight(14),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.5),
                          ),
                          child: Text(
                            'Get Started',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: responsiveFont(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}