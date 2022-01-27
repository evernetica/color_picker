import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:color_picker/main.dart';
import 'package:flutter/material.dart';

StreamController? timer;

class CameraTab extends StatelessWidget {
  const CameraTab({Key? key}) : super(key: key);

  final CameraApp cameraApp = const CameraApp();

  @override
  Widget build(BuildContext context) {
    return cameraApp;
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  Container? containerColor;

  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras[0], ResolutionPreset.low);

    controller!.initialize().then((_) async {
      if (!mounted) {
        return;
      }

      await controller!.startImageStream((streamedImage) {
        setState(() {
          int width = streamedImage.width;
          int height = streamedImage.height;
          Uint8List rawBytes = streamedImage.planes.first.bytes;

          int bytesInRow = streamedImage.planes.first.bytesPerRow;
          int bytesInPixel = streamedImage.planes.first.bytesPerRow ~/ width;

          List<int> pixelBytes = [];

          for (int i = 0; i < bytesInPixel; i++) {
            pixelBytes.add(rawBytes[
                height ~/ 2 * bytesInRow + width ~/ 2 * bytesInPixel + i]);
          }

          // b0   g1   r2   a3

          // a0   r1   g2   b3

          containerColor = Container(
            color: Color.fromARGB(
              /* a */
              pixelBytes[3],
              /* r */ pixelBytes[2],
              /* g */ pixelBytes[1],
              /* b */ pixelBytes[0],
            ),
          );
        });
      });

      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) return Container();

    if (!controller!.value.isInitialized) return Container();

    Color? pickedColor = containerColor?.color;

    Color? crossHairColor;

    if (pickedColor != null) {
      crossHairColor = Color.fromARGB(
        pickedColor.alpha,
        255 - pickedColor.red,
        255 - pickedColor.green,
        255 - pickedColor.blue,
      );
    }

    return Column(
      children: [
        CameraPreview(
          controller!,
          child: Icon(
            Icons.pages,
            color: crossHairColor ?? Colors.black,
          ),
        ),
        if (containerColor != null) Expanded(child: containerColor!),
      ],
    );
  }
}
