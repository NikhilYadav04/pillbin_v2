import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));
  //runApp(const MyApp());
}
