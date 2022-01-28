import 'dart:async';

import 'package:color_picker/app/scene/detector/tabs/camera/camera_view_widget.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_cubit.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

StreamController? timer;

class CameraTab extends StatelessWidget {
  const CameraTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraTabCubit(),
      child: BlocBuilder<CameraTabCubit, CameraTabState>(
        builder: (context, state) => CameraViewWidget(state),
      ),
    );
  }
}
