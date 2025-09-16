import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pillbin/app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

  //* Initialize dotenv
  await dotenv.load();
  //await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}
