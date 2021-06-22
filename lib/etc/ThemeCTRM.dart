import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorsCTRM {
  static const primaryColor = const Color(0xFF1261a1);
  static const primaryColorAlphaAA = const Color(0xAA1261a1);
  static const primaryColorHalfDark = const Color(0xFF127FFC);
  static const primaryColorDark = const Color(0xFF1258FC);
  static const primaryColorSuperDark = const Color(0xFF1142F2);
  static const primaryColorDarkAlpha66 = const Color(0x661258FC);
  static const primaryColorComplementary = const Color(0xFFE6A31C);
  static const primaryColorMonochromatic = const Color(0xFF2B4266);
  static const primaryColorAnalogBlue = const Color(0xFF1261a1);
  static const primaryColorAnalogGreen = const Color(0xFF12a152);
  static const primaryColorTriadicPurple = const Color(0xFF9a12a1);
  static const primaryColorTriadicBrown = const Color(0xFFa19a12);
  static const primaryColorTetraticPurple = const Color(0xFF5212a1);
  static const primaryColorTetraticRed = const Color(0xFFa11219);
  static const primaryColorTetraticGreen = const Color(0xFF61a112);

}

class FontsStyleCTRM{
  static TextStyle primaryFontWhite = GoogleFonts.concertOne(color: Colors.white);
  static TextStyle primaryFont19White = GoogleFonts.concertOne(color: Colors.white, fontSize: 19,);
  static TextStyle primaryFont = GoogleFonts.concertOne(color: ColorsCTRM.primaryColorSuperDark);
  static TextStyle primaryFontMiniWhite = GoogleFonts.concertOne(color: Colors.white, fontSize: 13,);
  static TextStyle primaryFont18Dark= GoogleFonts.concertOne(color: ColorsCTRM.primaryColorDark, fontSize: 18);
  static TextStyle primaryFont25SuperDark = GoogleFonts.concertOne(fontSize: 25, color: ColorsCTRM.primaryColorSuperDark);
  static TextStyle primaryFont20Dark = GoogleFonts.concertOne(color: ColorsCTRM.primaryColorDark, fontSize: 20);
  static TextStyle primaryFontBoldBlack = GoogleFonts.concertOne(fontWeight: FontWeight.bold);
  static TextStyle primaryFontBlack = GoogleFonts.concertOne();
  static TextStyle primaryFontListSpacing = GoogleFonts.concertOne(textStyle: TextStyle(color: Colors.white, letterSpacing: 1));
  static TextStyle primaryFontListSpacingGreen = GoogleFonts.concertOne(textStyle: TextStyle(color: Colors.lightGreenAccent, letterSpacing: 1));
  static TextStyle primaryFontListSpacingBlue = GoogleFonts.concertOne(textStyle: TextStyle(color: Colors.lightBlueAccent, letterSpacing: 1));
}

ThemeData ThemeCTRM(){

  ThemeData themeCTRM = ThemeData(
    primaryColor: Color(0xFF1261a1),
  );

  return themeCTRM;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}