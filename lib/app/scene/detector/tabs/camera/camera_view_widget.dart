import 'dart:async';

import 'package:camera/camera.dart';
import 'package:color_picker/app/calculations/color_operations.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        if (!mounted) {
          return;
        }

        if (streamedImage.format.group.name == "yuv420") {
          setState(() {
            if (!isOffsetSet) {
              cameraPreviewOffset =
                  _calculateOffset(0, streamedImage, context, 0.7, 0.05);
              isOffsetSet = true;
            }

            pickedColor = ColorOperations.calculateYuvColor(streamedImage);
          });
        } else if (streamedImage.format.group.name == "bgra8888") {
          setState(() {
            if (!isOffsetSet) {
              cameraPreviewOffset =
                  _calculateOffset(1, streamedImage, context, 0.7, 0.05);
              isOffsetSet = true;
            }

            pickedColor = ColorOperations.calculateBrgColor(streamedImage);
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
      crosshairColor = ColorOperations.getExtremelyInvertedColor(pickedColor!);
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
              ? _colorPreview(
                  context, pickedColor!, widget, crosshairColor ?? Colors.black)
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ],
    );
  }
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
    context, Color color, CameraViewWidget widget, Color crosshairColor) {
  return FractionallySizedBox(
    widthFactor: 1,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Container(
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
        Align(
          alignment: Alignment.topCenter,
          child: FractionallySizedBox(
            heightFactor: 0.8,
            widthFactor: 0.6,
            child: Center(
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "Tap here to save the color",
                  style: TextStyle(
                      inherit: false,
                      color: crosshairColor.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => crosshairColor.withOpacity(0.5)),
              ),
              onPressed: () {
                Map<String, String> closestColor =
                    ColorOperations.getClosestColor(
                        color.hashCode.toRadixString(16), widget.state);

                widget.addColorController.sink.add(ColorsSheetItemEntity(
                    code: closestColor.keys.first,
                    name: closestColor.values.first));

                Fluttertoast.showToast(
                  msg: "Color saved to favourites",
                  backgroundColor:
                      ColorOperations.codeToColor(closestColor.keys.first),
                  textColor: crosshairColor,
                  gravity: ToastGravity.TOP,
                );
              },
              child: Container(),
            ),
          ),
        ),
      ],
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
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Hex: #${color.hashCode.toRadixString(16).substring(2)}",
            style: textStyle,
          ),
          Text(
            ColorOperations.getClosestColor(
                    color.hashCode.toRadixString(16), widget.state)
                .values
                .first,
            style: textStyle,
          ),
        ],
      ),
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
          "ff${ColorOperations.getClosestColor(color.hashCode.toRadixString(16), widget.state).keys.first}",
          radix: 16,
        )),
      ),
    ),
  );
}
