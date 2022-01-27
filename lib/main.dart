import 'dart:async';

import 'package:camera/camera.dart';
import 'package:color_picker/app/app_root.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(AppRoot());
}
