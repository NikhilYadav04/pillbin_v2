import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pillbin/app.dart';
import 'package:pillbin/network/utils/http_client.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

  //* Initialize dotenv
  await dotenv.load();
  //await dotenv.load(fileName: ".env");

  await HttpClient().init();

  runApp(const MyApp());
}
