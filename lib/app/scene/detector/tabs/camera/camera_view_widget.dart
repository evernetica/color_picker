import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraViewWidget extends StatefulWidget {
  const CameraViewWidget(
      this.state, this.isBuggedIphoneModel, this.addColorController,
      {Key? key})
      : super(key: key);

  final CameraTabState state;
  final bool isBuggedIphoneModel;
  final StreamController<ColorsSheetItemEntity> addColorController;

  @override
  _CameraViewWidgetState createState() => _CameraViewWidgetState();
}

class _CameraViewWidgetState extends State<CameraViewWidget> {
  CameraController? controller;
  Color? pickedColor;
  double? cameraPreviewOffset;
  bool isOffsetSet = false;

  @override
  void initState() {
    super.initState();

    widget.isBuggedIphoneModel
        ? controller = CameraController(cameras[0], ResolutionPreset.low)
        : controller = CameraController(cameras[0], ResolutionPreset.max);

    controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      colorsSheetListUseCase.getColorsSheetList();

      controller!.startImageStream((streamedImage) {
        if (streamedImage.format.group.name == "yuv420") {
          setState(() {
            if (!isOffsetSet) {
              cameraPreviewOffset =
                  _calculateOffset(0, streamedImage, context, 0.7, 0.05);
              isOffsetSet = true;
            }

            pickedColor = _calculateYuvColor(streamedImage);
          });
        } else if (streamedImage.format.group.name == "bgra8888") {
          setState(() {
            if (!isOffsetSet) {
              cameraPreviewOffset =
                  _calculateOffset(1, streamedImage, context, 0.7, 0.05);
              isOffsetSet = true;
            }

            pickedColor = _calculateBrgColor(streamedImage);
          });
        } else {
          setState(() {
            pickedColor = Colors.white;
            cameraPreviewOffset = 0;
          });
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

    if (cameraPreviewOffset == null) return Container();

    if (!controller!.value.isInitialized) return Container();

    Color? crosshairColor;

    if (pickedColor != null) {
      crosshairColor = Color.fromARGB(
        pickedColor!.alpha,
        255 - pickedColor!.red,
        255 - pickedColor!.green,
        255 - pickedColor!.blue,
      );
    }

    ScrollController scrollController = ScrollController(
        initialScrollOffset: cameraPreviewOffset!, keepScrollOffset: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 7,
          child: Center(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const NeverScrollableScrollPhysics(),
              child: CameraPreview(
                controller!,
                child: Icon(
                  Icons.pages,
                  color: crosshairColor ?? Colors.black,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: pickedColor != null
              ? TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Map<String, String> closestColor = _getClosestColor(
                        pickedColor.hashCode.toRadixString(16), widget);

                    widget.addColorController.sink.add(ColorsSheetItemEntity(
                        code: closestColor.keys.first,
                        name: closestColor.values.first));
                  },
                  child: _colorPreview(
                      pickedColor!, widget, crosshairColor ?? Colors.black),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
}

Color _calculateYuvColor(CameraImage cameraImage) {
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

Color _calculateBrgColor(CameraImage cameraImage) {
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

double _calculateOffset(
    int encodingId,
    CameraImage streamedImage,
    BuildContext context,
    double cameraPreviewHeightFactor,
    double crosshairWidthFactor) {
  double streamedHeight = 0;
  double streamedWidth = 0;

  switch (encodingId) {
    case 0:
      streamedHeight = streamedImage.width.toDouble();
      streamedWidth = streamedImage.height.toDouble();
      break;
    case 1:
      streamedHeight = streamedImage.height.toDouble();
      streamedWidth = streamedImage.width.toDouble();
      break;
  }

  double imageHeight =
      streamedHeight * MediaQuery.of(context).size.width / streamedWidth;

  return imageHeight / 2 -
      MediaQuery.of(context).size.height * cameraPreviewHeightFactor / 2 +
      MediaQuery.of(context).size.width *
          crosshairWidthFactor /
          2 *
          cameraPreviewHeightFactor;
}

Widget _colorPreview(
    Color color, CameraViewWidget widget, Color crosshairColor) {
  return FractionallySizedBox(
    widthFactor: 1,
    child: Container(
      color: color,
      child: widget.state.colorsSheetList.isNotEmpty
          ? Align(
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: _colorsInfoRow(color, widget),
                  ),
                  Expanded(
                    flex: 4,
                    child: _closestColorPreviewContainer(color, widget),
                  )
                ],
              ),
            )
          : FractionallySizedBox(
              widthFactor: 0.2,
              child: Align(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(
                    color: crosshairColor,
                  ),
                ),
              ),
            ),
    ),
  );
}

Widget _colorsInfoRow(Color color, CameraViewWidget widget) {
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
          _getClosestColor(color.hashCode.toRadixString(16), widget)
              .values
              .first,
          style: textStyle,
        ),
      ],
    ),
  );
}

Widget _closestColorPreviewContainer(Color color, CameraViewWidget widget) {
  return Align(
    alignment: Alignment.centerRight,
    child: FractionallySizedBox(
      widthFactor: 0.5,
      child: Container(
        color: Color(int.parse(
          "ff${_getClosestColor(color.hashCode.toRadixString(16), widget).keys.first}",
          radix: 16,
        )),
      ),
    ),
  );
}

Map<String, String> _getClosestColor(String hashCode, CameraViewWidget widget) {
  int dif = -1;
  String winner = "none";
  String winnerK = "none";

  List<String> codesList = [];

  for (ColorsSheetItemEntity entity in widget.state.colorsSheetList) {
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
      winner = widget.state.colorsSheetList[i].name;
      winnerK = widget.state.colorsSheetList[i].code.substring(1);
    }
  }

  return {winnerK: winner};
}
