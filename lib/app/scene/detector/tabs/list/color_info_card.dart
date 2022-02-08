import 'dart:ui';

import 'package:color_picker/app/calculations/color_operations.dart';
import 'package:color_picker/app/calculations/color_to_model.dart';
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
    Color previewColor =
        ColorOperations.modifyColor(widget._colorToSave, value);
    Color invertedColor =
        ColorOperations.getExtremelyInvertedColor(previewColor);

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
    List<int> argbColors = ColorToModel.colorToARGB(previewColor);
    List<int> cmykColors = ColorToModel.colorToCMYK(previewColor);
    List<int> labColors = ColorToModel.colorToLab(previewColor);
    List<int> hsvColors = ColorToModel.colorToHSV(previewColor);

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
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${channelsNames[i]}: " +
                          ("${channelsValues[i]} "),
                      style: const TextStyle(
                        fontFeatures: [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                  ),
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

String _getPercentsString(double value) {
  int newValue = ColorOperations.getPercentsFromValue(value).round();
  return newValue > 0 ? "+$newValue%" : "$newValue%";
}
