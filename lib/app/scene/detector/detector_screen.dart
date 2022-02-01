import 'package:color_picker/app/scene/detector/cubit/detector_cubit.dart';
import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/camera_tab.dart';
import 'package:color_picker/app/scene/detector/tabs/list/colors_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenDetector extends StatelessWidget {
  const ScreenDetector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetectorScreenCubit(),
      child: BlocBuilder<DetectorScreenCubit, DetectorScreenState>(
        builder: (context, state) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: TabBarView(
                children: [
                  CameraTab(state.addColorController),
                  ColorsListTab(state.colorsEntitiesList, BlocProvider.of<DetectorScreenCubit>(context).removeColorFromList),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
