import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
final GlobalKey aboutUsKey;

  const LandingPage({super.key, required this.aboutUsKey});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive font with tighter clamp for larger screens
    double responsiveFont(double size) {
      final scale = screenWidth / 375; // base: mobile
      final scaled = size * scale;
      // clamp between 0.8x and 1.2x
      return scaled.clamp(size * 0.8, size * 1.2);
    }

    // Helper sizes
    double horizontalPadding = min(24.0, screenWidth * 0.05);
    double verticalPadding = min(16.0, screenHeight * 0.02);

    // Determine max image box size
    final maxImageSize = min(screenWidth * 0.8, 300.0);

    // Create a key for the About Us section
    final GlobalKey aboutUsKey = GlobalKey();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/bg2.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color.fromARGB(150, 42, 14, 24)),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
          child: Text(
                'SafeScan',
                style: GoogleFonts.inter(
                  color: const Color(0xFFF27A9D),
                  fontSize: responsiveFont(24),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          

                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                children: [
                                  _navButton(
                                    'About Us',
                                    responsiveFont(14),
                                    onPressed: () {
                                      Scrollable.ensureVisible(
                                        aboutUsKey.currentContext!,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 12),
                                  _navButton('Contact Us', responsiveFont(14)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsiveFont(16)),

                      // Image container with max size
                      Center(
                        child: Container(
                        margin: EdgeInsets.only(top: responsiveFont(60)), // or whatever value you want
                          width: maxImageSize,
                          height: maxImageSize,
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
                                top: maxImageSize * 0.25,
                                right: 0,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x80F27A9D),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
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

                      SizedBox(height: responsiveFont(24)),

                      // Title
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
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveFont(16)),

                      // Subtitle
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: responsiveFont(32)),

                      // Get Started button
                     

                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/UploadPage'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA2314E),
                            padding: EdgeInsets.symmetric(
                              horizontal: responsiveFont(40),
                              vertical: responsiveFont(14),
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

                      // About Us Section
                      SizedBox(height: responsiveFont(60)),
                     Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth > 1100
                                ? 900
                                : screenWidth > 800
                                    ? 750
                                    : screenWidth >750 ?700
                                       : double.infinity,

                          ),
                          child: Container(
                            key: aboutUsKey,
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: responsiveFont(25),
                            ),
                            margin: EdgeInsets.only(top: responsiveFont(100)),
                            decoration: BoxDecoration(
                              color: const Color(0x30F27A9D),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0x50F27A9D),
                                width: 1,
                              ),
                            ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Title
                            Text(
                              'About SafeScan',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFF27A9D),
                                fontSize: responsiveFont(20),
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: responsiveFont(16)),
                            // Content
                            Text(
                              'At SafeScan, we are dedicated to revolutionizing breast cancer detection through advanced technology and clinical insight. Our mission is to empower radiologists with intelligent tools that assist in the early detection. We combine cutting-edge AI algorithms with a user-friendly interface to support healthcare professionals in identifying potential malignancies with greater precision and confidence.\n\nTogether, we believe technology and medicine can save lives—one mammogram at a time.',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: responsiveFont(14),
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: responsiveFont(16)),
                            // Decorative elements
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildPinkDot(),
                                SizedBox(width: 8),
                                _buildPinkDot(),
                                SizedBox(width: 8),
                                _buildPinkDot(),
                              ],
                            ),
                          ],
                        ),
                      ),),),
                      SizedBox(height: responsiveFont(40)),
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

  Widget _navButton(String title, double fontSize, {VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed,
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

  Widget _buildPinkDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFF27A9D),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF27A9D).withOpacity(0.7),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}