import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_bc_detection/LandingPage.dart';

Widget _navButton(String title, double fontSize, BuildContext context) {
  return Text(
    title,
    style: GoogleFonts.inter(
      color: const Color(0xFFF27A9D),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    ),
  );
}

Widget buildHeader(BuildContext context, double screenWidth ) {
  final font24 = responsiveFont(24, screenWidth);
  final font14 = responsiveFont(14, screenWidth);

  // Create a GlobalKey instance
  final GlobalKey aboutUsKey = GlobalKey();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
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
        ),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/',
                    ).then((_) {
                      Scrollable.ensureVisible(aboutUsKey.currentContext!);
                    }) ; },

                  child: _navButton('About Us', font14, context),
                ),


                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                  Navigator.pushNamed(context, '/contactus');

                    ;},
                    child: _navButton('Contact Us', font14, context),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

double responsiveFont(double size, double screenWidth) {
  final scale = screenWidth / 375;
  return (size * scale).clamp(size * 0.8, size * 1.2);
}
