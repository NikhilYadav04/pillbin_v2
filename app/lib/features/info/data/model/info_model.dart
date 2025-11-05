import 'package:flutter/material.dart';

class InfoModel {
  final String title;
  final List<TextSpan> description;
  final String image;

  InfoModel(
      {required this.title, required this.description, required this.image});
}
