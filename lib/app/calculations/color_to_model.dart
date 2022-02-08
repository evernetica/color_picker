import 'dart:math';
import 'package:flutter/material.dart';

abstract class ColorToModel {
  static List<int> colorToARGB(Color color) {
    List<int> result = [];

    for (int i = 0; i < 8; i += 2) {
      result.add(int.parse(color.hashCode.toRadixString(16).substring(i, i + 2),
          radix: 16));
    }

    return result;
  }

  static List<int> colorToCMYK(Color color) {
    List<int> rgb = colorToARGB(color).sublist(1);

    double r = rgb[0] / 255;
    double g = rgb[1] / 255;
    double b = rgb[2] / 255;

    double K = 1 - max(r, max(g, b));

    double C = (1 - r - K) / (1 - K) * 100;
    double M = (1 - g - K) / (1 - K) * 100;
    double Y = (1 - b - K) / (1 - K) * 100;

    K *= 100;

    if (C.isNaN) C = 0;
    if (M.isNaN) M = 0;
    if (Y.isNaN) Y = 0;

    C.clamp(0, 100);
    M.clamp(0, 100);
    Y.clamp(0, 100);
    K.clamp(0, 100);

    return [C.round(), M.round(), Y.round(), K.round()];
  }

  static List<int> colorToLab(Color color) {
    // first we convert RGB to XYZ

    List<int> rgb = colorToARGB(color).sublist(1);

    double r = rgb[0] / 255;
    double g = rgb[1] / 255;
    double b = rgb[2] / 255;

    r > 0.04045 ? r = pow((r + 0.055) / 1.055, 2.4).toDouble() : r = r / 12.92;
    g > 0.04045 ? g = pow((g + 0.055) / 1.055, 2.4).toDouble() : g = g / 12.92;
    b > 0.04045 ? b = pow((b + 0.055) / 1.055, 2.4).toDouble() : b = b / 12.92;

    r *= 100;
    g *= 100;
    b *= 100;

    double X = r * 0.4124 + g * 0.3576 + b * 0.1805;
    double Y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    double Z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    // then we convert XYZ to LAB with "daylight" reference preset
    // Reference-X, Y and Z refer to specific illuminants and observers.
    const double xRef = 94.811;
    const double yRef = 100;
    const double zRef = 107.304;

    X = X / xRef;
    Y = Y / yRef;
    Z = Z / zRef;

    X > 0.008856 ? X = pow(X, 1 / 3).toDouble() : X = (7.787 * X) + (16 / 116);
    Y > 0.008856 ? Y = pow(Y, 1 / 3).toDouble() : Y = (7.787 * Y) + (16 / 116);
    Z > 0.008856 ? Z = pow(Z, 1 / 3).toDouble() : Z = (7.787 * Z) + (16 / 116);

    double cieL = (116 * Y) - 16;
    double cieA = 500 * (X - Y);
    double cieB = 200 * (Y - Z);

    return [cieL.round(), cieA.round(), cieB.round()];
  }

  static List<int> colorToHSV(Color color) {
    List<int> rgb = colorToARGB(color).sublist(1);

    double r = rgb[0] / 255;
    double g = rgb[1] / 255;
    double b = rgb[2] / 255;

    double minimum = min<double>(r, min<double>(g, b));
    double maximum = max<double>(r, max<double>(g, b));
    double V = maximum;
    double delta = maximum - minimum;
    double S = -1, H = -1;

    if (maximum != 0) {
      S = delta / maximum;
    } else {
      S = 0;
      H = 0;
      return [H.round(), S.round(), V.round()];
    }

    if (r == maximum) {
      H = (g - b) / delta;
    } else if (g == maximum) {
      H = 2 + (b - r) / delta;
    } else {
      H = 4 + (r - g) / delta;
    }
    H *= 60; // degrees
    if (H < 0) {
      H += 360;
    }

    if (H.isNaN) H = 0;

    H.clamp(0, 360);
    S.clamp(0, 100);
    V.clamp(0, 100);

    S *= 100;
    V *= 100;

    return [H.round(), S.round(), V.round()];
  }
}
