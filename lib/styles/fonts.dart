import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



TextStyle standardFont(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return GoogleFonts.amiri(
    color: isDark ? Colors.white : Colors.black,
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
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return GoogleFonts.cairo(
    color: isDark ? Colors.grey[200] : Colors.black,
    fontSize: width * 0.058,
  );
}

TextStyle currentDateStyle(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return GoogleFonts.amiri(
    color: Colors.white,
    fontSize: width * 0.040,
  );
}
