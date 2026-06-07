import 'package:flutter/material.dart';

class PillBinLight {
  static TextStyle style({double fontSize = 14, Color? color}) => TextStyle(
        fontFamily: 'Poppins-Light',
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
        color: color,
      );
}

class PillBinRegular {
  static TextStyle style({double fontSize = 14, Color? color}) => TextStyle(
        fontFamily: 'Poppins-Regular',
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color,
      );
}

class PillBinMedium {
  static TextStyle style({double fontSize = 14, Color? color}) => TextStyle(
        fontFamily: 'Poppins-Medium',
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color,
      );
}

class PillBinBold {
  static TextStyle style({double fontSize = 14, Color? color}) => TextStyle(
        fontFamily: 'Poppins-Bold',
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
      );
}
