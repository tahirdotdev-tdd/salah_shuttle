import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HijriDateTile extends StatefulWidget {
  final Color tileColor;

  const HijriDateTile({super.key, required this.tileColor});

  @override
  State<HijriDateTile> createState() => _HijriDateTileState();
}

class _HijriDateTileState extends State<HijriDateTile> {
  String gregorianDate = '';
  String hijriDate = '';
  String hijriMonthMeaning = '';
  bool isLoading = true;
  bool _pressed = false;

  final Map<String, String> monthMeanings = {
    'Muharram': 'Sacred Month',
    'Safar': 'Month of Journey',
    'Rabi al-Awwal': 'Birth of Prophet ﷺ',
    'Rabi al-Thani': 'Second Spring',
    'Jumada al-Awwal': 'First Dry Month',
    'Jumada al-Thani': 'Second Dry Month',
    'Rajab': 'Sacred Month',
    'Sha\'ban': 'Preparation Month',
    'Ramadan': 'Month of Fasting',
    'Shawwal': 'Month of Celebration',
    'Dhu al-Qi\'dah': 'Sacred Month',
    'Dhu al-Hijjah': 'Month of Hajj',
  };

  @override
  void initState() {
    super.initState();
    fetchHijriDate();
  }

  Future<void> fetchHijriDate() async {
    setState(() => isLoading = true);
    final today = DateTime.now();
    final formattedDate = "${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}";
    final url = "https://api.aladhan.com/v1/gToH?date=$formattedDate";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hijri = data['data']['hijri'];
        final gregorian = data['data']['gregorian'];
        final rawMonthName = (hijri['month']['en'] as String)
            .replaceAll('ḥ', 'h')
            .replaceAll('Ḥ', 'H')
            .replaceAll('\'', '')
            .trim();

        setState(() {
          gregorianDate = "${gregorian['weekday']['en']}, ${gregorian['date']}";
          hijriDate = "${hijri['weekday']['en']}, ${hijri['date']} (${hijri['month']['en']}) ${hijri['year']} AH";
          hijriMonthMeaning = monthMeanings[rawMonthName] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        gregorianDate = 'Error';
        hijriDate = 'Error';
        hijriMonthMeaning = '';
        isLoading = false;
      });
    }
  }

  void _onTapDown(_) => setState(() => _pressed = true);
  void _onTapUp(_) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final tileWidth = width * 0.9;
    final tileHeight = tileWidth * 0.75;
    final shadowOffset = tileHeight * 0.065;
    final offset = _pressed ? shadowOffset : 0.0;

    final borderColor = isDark ? Colors.white : Colors.black;
    final tileBgColor = isDark ? const Color(0xFF1e1e1e) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return isLoading
        ? Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.green, size: 100))
        : GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: SizedBox(
        height: tileHeight + shadowOffset,
        width: tileWidth,
        child: Stack(
          children: [
            // Shadow layer
            Positioned(
              right: 0,
              top: shadowOffset,
              child: Container(
                height: tileHeight,
                width: tileWidth * 0.96,
                decoration: BoxDecoration(
                  color: tileBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 3, color: borderColor),
                ),
              ),
            ),
            // Front animated tile
            Positioned(
              left: 0,
              top: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                transform: Matrix4.translationValues(offset, offset, 0),
                child: Container(
                  height: tileHeight,
                  width: tileWidth * 0.965,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: tileBgColor,
                    border: Border.all(width: 3, color: borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gregorianDate,
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.038,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          hijriDate,
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.048,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '🌙 Meaning: $hijriMonthMeaning',
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.035,
                            color: textColor.withOpacity(0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
