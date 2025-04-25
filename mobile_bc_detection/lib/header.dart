import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_keys.dart';
Widget _navButton(String title, double fontSize, VoidCallback onPressed) {
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFF27A9D),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    ),
    child: Text(title),
  );
}



Widget buildHeader(BuildContext context, double screenWidth) {
  final font24 = responsiveFont(24, screenWidth);
  final font14 = responsiveFont(14, screenWidth);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              // Simple navigation without scroll logic
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.popUntil(context, (route) => route.isFirst);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (AppKeys.landingPageKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      AppKeys.landingPageKey.currentContext!,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              } else {
                if (AppKeys.landingPageKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    AppKeys.landingPageKey.currentContext!,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              }
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
                // Update the About Us button callback:
                _navButton('About Us', font14, () {
                  if (ModalRoute.of(context)?.settings.name != '/') {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (AppKeys.aboutUsKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          AppKeys.aboutUsKey.currentContext!,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  } else {
                    if (AppKeys.aboutUsKey.currentContext != null) {
                      Scrollable.ensureVisible(
                        AppKeys.aboutUsKey.currentContext!,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                }),
                _navButton('Contact Us', font14, () {
                  // Contact us logic
                  Navigator.pushNamed(context, '/contactus');
                }),
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
