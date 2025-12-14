import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pillbin/app.dart';
import 'package:pillbin/network/utils/http_client.dart';

class MyHttpOverrides extends io.HttpOverrides {
  @override
  io.HttpClient createHttpClient(io.SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (io.X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = MyHttpOverrides();

  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

  //* Initialize dotenv
  await dotenv.load();
  //await dotenv.load(fileName: ".env");

  await HttpClient().init();

  runApp(const MyApp());
}
