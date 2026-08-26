import 'dart:io' as io;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:pillbin/app.dart';
import 'package:pillbin/firebase_options.dart';
import 'package:pillbin/network/utils/http_client.dart';

void _useSystemPhotoPicker() {
  final ImagePickerPlatform picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) {
    picker.useAndroidPhotoPicker = true;
  }
}

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
  _useSystemPhotoPicker();

  //runApp(DevicePreview(enabled: !kReleaseMode, builder: (context) => MyApp()));

  //* Initialize dotenv
  await dotenv.load();
  //await dotenv.load(fileName: ".env")
  //;

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await HttpClient().init();

  runApp(const MyApp());
}
