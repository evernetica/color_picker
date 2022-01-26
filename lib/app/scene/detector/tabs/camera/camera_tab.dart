import 'dart:async';

import 'package:camera/camera.dart';
import 'package:color_picker/main.dart';
import 'package:flutter/material.dart';

class CameraTab extends StatelessWidget {
  CameraTab({Key? key}) : super(key: key);

  final CameraApp cameraApp = CameraApp();

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          cameraApp.takePicture();
        },
        child: cameraApp);
  }
}

class CameraApp extends StatefulWidget {
  CameraApp({Key? key}) : super(key: key);

  final StreamController<int> controller = StreamController<int>();
  StreamSubscription? subscription;

  void takePicture() {
    globalControllerTest.add(1);
  }

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    subscription = globalControllerTest.stream.listen((event) {
      takePicture();
    });

    controller = CameraController(cameras![0], ResolutionPreset.max);
    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void takePicture() async {
    XFile file = await controller!.takePicture();
    print(file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (!controller!.value.isInitialized) {
      return Container();
    }
    return CameraPreview(controller!);
  }
}
