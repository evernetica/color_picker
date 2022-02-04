import 'dart:math';
import 'dart:ui';

import 'package:color_picker/app/scene/detector/tabs/camera/camera_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ColorInfoCard extends StatefulWidget {
  const ColorInfoCard({Key? key, Color colorToSave = Colors.white})
      : _colorToSave = colorToSave,
        super(key: key);

  final Color _colorToSave;

  @override
  State<StatefulWidget> createState() => ColorInfoCardState();
}

class ColorInfoCardState extends State<ColorInfoCard> {
  double value = 50;

  @override
  Widget build(BuildContext context) {
    Color previewColor = _modifyColor(widget._colorToSave, value);
    Color invertedColor = getExtremelyInvertedColor(previewColor);

    return Column(
      children: [
        _colorPalette(),
        ..._colorPreview(previewColor, invertedColor),
        _convertedCodesPanel(previewColor),
      ],
    );
  }

  Widget _colorPalette() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 24.0,
        right: 24.0,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: const [0, 0.5, 1],
                  colors: [Colors.white, widget._colorToSave, Colors.black],
                ),
              ),
            ),
            Positioned(
              left:
                  (MediaQuery.of(context).size.width - 48 - 16) * value / 100 -
                      2.5,
              top: 0,
              width: 5,
              height: MediaQuery.of(context).size.width - 48 - 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  border: Border.symmetric(
                    vertical: BorderSide(
                      width: 1,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _colorPreview(Color previewColor, Color invertedColor) {
    return [
      Slider(
        activeColor: Colors.grey,
        inactiveColor: Colors.grey,
        min: 0,
        max: 100,
        value: value,
        onChanged: (newValue) {
          setState(() {
            value = newValue;
          });
        },
      ),
      AspectRatio(
        aspectRatio: 5 / 1,
        child: Container(
          color: previewColor,
          child: Center(
            child: Text(
              _getPercentsString(value),
              style: TextStyle(
                inherit: false,
                color: invertedColor,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _convertedCodesPanel(Color previewColor) {
    List<int> argbColors = colorToARGB(previewColor);
    List<int> cmykColors = colorToCMYK(previewColor);
    List<int> labColors = colorToLab(previewColor);
    List<int> hsvColors = colorToHSV(previewColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Center(
          child: FittedBox(
            child: IntrinsicHeight(
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Flexible(
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            colorCodePresenter(
                                ["R", "G", "B"],
                                argbColors.sublist(1),
                                "RGB",
                                previewColor.hashCode
                                    .toRadixString(16)
                                    .substring(2),
                                true),
                            colorCodePresenter(["C", "M", "Y", "K"], cmykColors,
                                "CMYK", "", false),
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            colorCodePresenter(["L", "A", "B"], labColors,
                                "LAB (daylight)", "", true),
                            colorCodePresenter(["H", "S", "V"], hsvColors,
                                "HSV (HSB)", "", false),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget colorCodePresenter(List<String> channelsNames, List<int> channelsValues,
    String modelName, String code, bool maintainSize) {
  ButtonStyle buttonStyle = ButtonStyle(
    foregroundColor: MaterialStateColor.resolveWith((states) => Colors.black26),
    overlayColor: MaterialStateColor.resolveWith((states) => Colors.black12),
  );

  if (channelsValues.length != channelsNames.length) {
    throw Exception("channelsNames.length != channelsValues.length");
  }

  print("${modelName} first = ${channelsValues[0]}");

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$modelName:",
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22.0,
              fontFeatures: [
                FontFeature.tabularFigures(),
              ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (int i = 0; i < channelsNames.length; i++)
              Text(
                "${channelsNames[i]}: " +
                    ("${channelsValues[i]} ").padLeft(4, "0"),
                style: const TextStyle(
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
            TextButton(
              style: buttonStyle,
              onPressed: () {
                _copyChannelsValues(channelsValues);
              },
              child: const Icon(Icons.copy),
            ),
          ],
        ),
        Visibility(
          visible: code.isNotEmpty,
          maintainSize: maintainSize,
          maintainAnimation: maintainSize,
          maintainState: maintainSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "#$code",
                style: const TextStyle(
                  fontFeatures: [
                    FontFeature.tabularFigures(),
                  ],
                ),
              ),
              TextButton(
                style: buttonStyle,
                onPressed: () {
                  _copyHashCode(code);
                },
                child: const Icon(Icons.copy),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void _copyHashCode(String code) {
  Clipboard.setData(ClipboardData(text: code));

  Fluttertoast.showToast(msg: "Copied: $code");
}

void _copyChannelsValues(List<int> channelsValues) {
  String text = "";

  for (int i = 0; i < channelsValues.length; i++) {
    text += "${channelsValues[i]}" +
        ((i == (channelsValues.length - 1)) ? "" : ", ");
  }

  Clipboard.setData(ClipboardData(text: text));

  Fluttertoast.showToast(msg: "Copied: $text");
}

List<int> colorToARGB(Color color) {
  List<int> result = [];

  for (int i = 0; i < 8; i += 2) {
    result.add(int.parse(color.hashCode.toRadixString(16).substring(i, i + 2),
        radix: 16));
  }

  return result;
}

List<int> colorToCMYK(Color color) {
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

List<int> colorToLab(Color color) {
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

List<int> colorToHSV(Color color) {
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

Color _modifyColor(Color initialColor, double initialValue) {
  List<int> argbList = colorToARGB(initialColor);

  int initialR = argbList[1];
  int initialG = argbList[2];
  int initialB = argbList[3];

  double value = _getPercentsFromValue(initialValue);

  bool isNegative = value < 0;
  double deltaR = _getChannelDelta(initialR, isNegative);
  double deltaG = _getChannelDelta(initialG, isNegative);
  double deltaB = _getChannelDelta(initialB, isNegative);

  double r = initialR - (deltaR * value);
  double g = initialG - (deltaG * value);
  double b = initialB - (deltaB * value);

  return Color.fromARGB(255, r.round(), g.round(), b.round());
}

double _getChannelDelta(int initialValue, bool isNegative) {
  return isNegative ? (255 - initialValue) / 100 : initialValue / 100;
}

double _getPercentsFromValue(double value) {
  return value * 200 / 100 - 100;
}

String _getPercentsString(double value) {
  int newValue = _getPercentsFromValue(value).round();
  return newValue > 0 ? "+$newValue%" : "$newValue%";
}
