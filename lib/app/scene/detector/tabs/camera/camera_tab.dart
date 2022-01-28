import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:color_picker/data/colors_temp_sheet.dart';
import 'package:color_picker/main.dart';
import 'package:flutter/material.dart';

StreamController? timer;

class CameraTab extends StatelessWidget {
  const CameraTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CameraApp();
  }
}

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController? controller;
  Color? pickedColor;

  @override
  void initState() {
    super.initState();

    controller = CameraController(cameras[0], ResolutionPreset.low);

    controller!.initialize().then((_) async {
      if (!mounted) {
        return;
      }

      await controller!.startImageStream((streamedImage) {
        if (streamedImage.format.group.name == "yuv420") {
          int width = streamedImage.width;
          int height = streamedImage.height;

          Uint8List bytesY = streamedImage.planes.toList()[0].bytes;
          Uint8List bytesU = streamedImage.planes.toList()[1].bytes;
          Uint8List bytesV = streamedImage.planes.toList()[2].bytes;

          // Y
          int Y = bytesY[width ~/ 2 + height ~/ 2 * width];
          // U
          int U = bytesU[width ~/ 2 + (height ~/ 2) ~/ 2 * width];
          // V
          int V = bytesV[width ~/ 2 + (height ~/ 2) ~/ 2 * width];

          int r = (Y + (1.370705 * (V - 128))).toInt();
          int g = (Y - (0.698001 * (V - 128)) - (0.337633 * (U - 128))).toInt();
          int b = (Y + (1.732446 * (U - 128))).toInt();

          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          setState(() {
            pickedColor = Color.fromARGB(
              /* a */
              255,
              /* r */ r,
              /* g */ g,
              /* b */ b,
            );
          });
        } else if (streamedImage.format.group.name == "bgra8888") {
          int width = streamedImage.width;
          int height = streamedImage.height;

          Uint8List rawBytes = streamedImage.planes.last.bytes;
          int bytesInRow = streamedImage.planes.first.bytesPerRow;
          int bytesInPixel = streamedImage.planes.first.bytesPerRow ~/ width;

          List<int> pixelBytes = [];

          for (int i = 0; i < bytesInPixel; i++) {
            pixelBytes.add(rawBytes[
                height ~/ 2 * bytesInRow + width ~/ 2 * bytesInPixel + i]);
          }

          setState(() {
            // b0   g1   r2   a3

            // a0   r1   g2   b3

            pickedColor = Color.fromARGB(
              /* a */
              pixelBytes[3],
              /* r */ pixelBytes[2],
              /* g */ pixelBytes[1],
              /* b */ pixelBytes[0],
            );
          });
        } else {
          pickedColor = Colors.white;
        }
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

    Color? crossHairColor;

    if (pickedColor != null) {
      crossHairColor = Color.fromARGB(
        pickedColor!.alpha,
        255 - pickedColor!.red,
        255 - pickedColor!.green,
        255 - pickedColor!.blue,
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
        if (pickedColor != null) Expanded(child: _colorPreview(pickedColor!)),
      ],
    );
  }
}

Widget _colorPreview(Color color) {
  return Container(
    color: color,
    child: Align(
      alignment: Alignment.topCenter,
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: _colorsInfoRow(color),
          ),
          Expanded(
            flex: 4,
            child: _closestColorPreviewContainer(color),
          )
        ],
      ),
    ),
  );
}

Widget _colorsInfoRow(Color color) {
  TextStyle textStyle = const TextStyle(
    inherit: false,
    color: Colors.white,
  );

  return Container(
    color: Colors.black,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Hex: #${color.hashCode.toRadixString(16)}",
          style: textStyle,
        ),
        Text(
          _getClosestColor(color.hashCode.toRadixString(16)).values.first,
          style: textStyle,
        ),
      ],
    ),
  );
}

Widget _closestColorPreviewContainer(Color color) {
  return Align(
    alignment: Alignment.centerRight,
    child: FractionallySizedBox(
      widthFactor: 0.5,
      child: Container(
        color: Color(int.parse(
          "ff${_getClosestColor(color.hashCode.toRadixString(16)).keys.first}",
          radix: 16,
        )),
      ),
    ),
  );
}

Map<String, String> _getClosestColor(String hashCode) {
  int dif = -1;
  String winner = "none";
  String winnerK = "none";

  List<String> keys = ColorsMap.map.keys.toList();

  int rScanned = int.parse(hashCode.substring(2, 4), radix: 16);
  int gScanned = int.parse(hashCode.substring(4, 6), radix: 16);
  int bScanned = int.parse(hashCode.substring(6, 8), radix: 16);

  for (String key in keys) {
    int r = rScanned - int.parse(key.substring(1, 3), radix: 16);
    int g = gScanned - int.parse(key.substring(3, 5), radix: 16);
    int b = bScanned - int.parse(key.substring(5, 7), radix: 16);

    if (r < 0) r *= -1;
    if (g < 0) g *= -1;
    if (b < 0) b *= -1;

    int currentDif = r + g + b;

    if (currentDif < dif || dif == -1) {
      dif = currentDif;
      winner = ColorsMap.map[key]!;
      winnerK = key.substring(1);
    }
  }

  return {winnerK: winner};
}