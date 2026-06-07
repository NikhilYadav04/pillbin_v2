import 'package:flutter/material.dart';

enum NudgeType {
  donationApproved,
  donationPending,
  medicineExpiry,
  featureLocations,
  featureBlogs,
  featureDonations,
}

class Nudge {
  final NudgeType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final String? route;

  const Nudge({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.actionLabel,
    this.route,
  });
}
