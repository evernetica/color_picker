import 'dart:async';

import 'package:color_picker/app/scene/detector/cubit/detector_cubit.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/camera_view_widget.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_cubit.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

StreamController? timer;

class CameraTab extends StatelessWidget {
  const CameraTab(this.addColorController, {Key? key}) : super(key: key);

  final StreamController<ColorsSheetItemEntity> addColorController;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraTabCubit(),
      child: BlocBuilder<CameraTabCubit, CameraTabState>(
          builder: (context, state) {
        BlocProvider.of<CameraTabCubit>(context).loadDefaultColors(
            BlocProvider.of<DetectorScreenCubit>(context)
                .state
                .colorsSheetList);

        return state.isBuggedIphoneModel != null
            ? CameraViewWidget(
                state, state.isBuggedIphoneModel!, addColorController)
            : const Center(
                child: CircularProgressIndicator(),
              );
      }),
    );
  }
}
