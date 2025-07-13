import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle standardFont() {
  return GoogleFonts.amiri(
    color: Colors.black,
    fontSize: 26,
  );
}

TextStyle salahText(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return GoogleFonts.amiri(
    color: Colors.white,
    fontSize: width * 0.060,
  );
}
TextStyle qiblahText(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return GoogleFonts.amiri(
    color: Colors.black,
    fontSize: width * 0.060,
  );
}

TextStyle currentDateStyle(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return GoogleFonts.amiri(
    color: Colors.white,
    fontSize: width * 0.040,
  );
}
