import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:color_picker/app/calculations/color_to_model.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:flutter/material.dart';

abstract class ColorOperations {
  static Color modifyColor(Color initialColor, double initialValue) {
    List<int> argbList = ColorToModel.colorToARGB(initialColor);

    int initialR = argbList[1];
    int initialG = argbList[2];
    int initialB = argbList[3];

    double value = getPercentsFromValue(initialValue);

    bool isNegative = value < 0;
    double deltaR = getChannelDelta(initialR, isNegative);
    double deltaG = getChannelDelta(initialG, isNegative);
    double deltaB = getChannelDelta(initialB, isNegative);

    double r = initialR - (deltaR * value);
    double g = initialG - (deltaG * value);
    double b = initialB - (deltaB * value);

    return Color.fromARGB(255, r.round(), g.round(), b.round());
  }

  static double getChannelDelta(int initialValue, bool isNegative) {
    return isNegative ? (255 - initialValue) / 100 : initialValue / 100;
  }

  static double getPercentsFromValue(double value) {
    return value * 200 / 100 - 100;
  }

  static Color getExtremelyInvertedColor(Color baseColor) {
    int r = 255 - baseColor.red;
    int g = 255 - baseColor.green;
    int b = 255 - baseColor.blue;

    int avg = (r + g + b) ~/ 3;

    r = avg >= 128 ? 255 : 0;
    g = avg >= 128 ? 255 : 0;
    b = avg >= 128 ? 255 : 0;

    return Color.fromARGB(
      baseColor.alpha,
      r,
      g,
      b,
    );
  }

  /// old color inverting method. currently using [getExtremelyInvertedColor].
  /// may be useful later
/*
Color _getInvertedColor(Color baseColor) {
  int r = 255 - baseColor.red;
  int g = 255 - baseColor.green;
  int b = 255 - baseColor.blue;

  bool isRedGray = r > 64 && r < 192;
  bool isGreenGray = g > 64 && g < 192;
  bool isBlueGray = b > 64 && b < 192;

  if (isRedGray && isGreenGray && isBlueGray) {
    r = 0;
    g = 0;
    b = 0;
  }

  return Color.fromARGB(
    baseColor.alpha,
    r,
    g,
    b,
  );
}*/

  static Color codeToColor(String code) {
    int r = int.parse(code.substring(0, 2), radix: 16);
    int g = int.parse(code.substring(2, 4), radix: 16);
    int b = int.parse(code.substring(4, 6), radix: 16);

    return Color.fromARGB(255, r, g, b);
  }

  static Color calculateYuvColor(CameraImage cameraImage) {
    int width = cameraImage.width;
    int height = cameraImage.height;

    Uint8List bytesY = cameraImage.planes.toList()[0].bytes;
    Uint8List bytesU = cameraImage.planes.toList()[1].bytes;
    Uint8List bytesV = cameraImage.planes.toList()[2].bytes;

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

    return Color.fromARGB(255, r, g, b);
  }

  static Color calculateBrgColor(CameraImage cameraImage) {
    int width = cameraImage.width;
    int height = cameraImage.height;

    Uint8List rawBytes = cameraImage.planes.last.bytes;
    int bytesInRow = cameraImage.planes.first.bytesPerRow;
    int bytesInPixel = cameraImage.planes.first.bytesPerRow ~/ width;

    List<int> pixelBytes = [];

    for (int i = 0; i < bytesInPixel; i++) {
      pixelBytes.add(
          rawBytes[height ~/ 2 * bytesInRow + width ~/ 2 * bytesInPixel + i]);
    }

    // b0   g1   r2   a3

    // a0   r1   g2   b3

    return Color.fromARGB(
      /* a */
      pixelBytes[3],
      /* r */ pixelBytes[2],
      /* g */ pixelBytes[1],
      /* b */ pixelBytes[0],
    );
  }

  static Map<String, String> getClosestColor(
      String hashCode, CameraTabState state) {
    int dif = -1;
    String winner = "none";
    String winnerK = "none";

    List<String> codesList = [];

    for (ColorsSheetItemEntity entity in state.colorsSheetList) {
      codesList.add(entity.code);
    }

    int rScanned = int.parse(hashCode.substring(2, 4), radix: 16);
    int gScanned = int.parse(hashCode.substring(4, 6), radix: 16);
    int bScanned = int.parse(hashCode.substring(6, 8), radix: 16);

    for (int i = 0; i < codesList.length; i++) {
      int r = rScanned - int.parse(codesList[i].substring(1, 3), radix: 16);
      int g = gScanned - int.parse(codesList[i].substring(3, 5), radix: 16);
      int b = bScanned - int.parse(codesList[i].substring(5, 7), radix: 16);

      if (r < 0) r *= -1;
      if (g < 0) g *= -1;
      if (b < 0) b *= -1;

      int currentDif = r + g + b;

      if (currentDif < dif || dif == -1) {
        dif = currentDif;
        winner = state.colorsSheetList[i].name;
        winnerK = state.colorsSheetList[i].code.substring(1);
      }
    }

    return {winnerK: winner};
  }
}
