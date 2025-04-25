import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatefulWidget {
  final GlobalKey aboutUsKey;
  final bool scrollToAboutUs; // 👈 Add a flag for triggering scroll

  const LandingPage({
    super.key,
    required this.aboutUsKey,
    this.scrollToAboutUs = false, // 👈 Optional, default is false
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 👇 Wait for build and scroll if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollToAboutUs && widget.aboutUsKey.currentContext != null) {
        Scrollable.ensureVisible(
          widget.aboutUsKey.currentContext!,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double responsiveFont(double size) {
      final scale = screenWidth / 375;
      final scaled = size * scale;
      return scaled.clamp(size * 0.8, size * 1.2);
    }

    double horizontalPadding = min(24.0, screenWidth * 0.05);
    double verticalPadding = min(16.0, screenHeight * 0.02);
    final maxImageSize = min(screenWidth * 0.8, 300.0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg2.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: const Color.fromARGB(150, 42, 14, 24)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                                        widget.aboutUsKey.currentContext!,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                  onTap: () {
                                  Navigator.pushNamed(context, '/contactus');},
                                    child:  _navButton('Contact Us', responsiveFont(14)),),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsiveFont(16)),

                      Center(
                        child: Container(
                          margin: EdgeInsets.only(top: responsiveFont(60)),
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
                              padding: const EdgeInsets.symmetric(
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

                      Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/UploadPage',
                            arguments: {
                              'key': widget.aboutUsKey,
                            },
                          ),
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

                      SizedBox(height: responsiveFont(60)),

                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth > 1100
                                ? 900
                                : screenWidth > 800
                                    ? 750
                                    : screenWidth > 750
                                        ? 700
                                        : double.infinity,
                          ),
                          child: Container(
                            key: widget.aboutUsKey,
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
                                Text(
                                  'At SafeScan, we are dedicated to revolutionizing breast cancer detection through advanced technology and clinical insight...',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: responsiveFont(14),
                                    height: 1.6,
                                  ),
                                ),
                                SizedBox(height: responsiveFont(16)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _buildPinkDot(),
                                    const SizedBox(width: 8),
                                    _buildPinkDot(),
                                    const SizedBox(width: 8),
                                    _buildPinkDot(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

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
