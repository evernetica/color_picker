import 'package:color_picker/app/scene/detector/cubit/detector_cubit.dart';
import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/camera_tab.dart';
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
          return const DefaultTabController(
            length: 2,
            child: Scaffold(
              body: TabBarView(
                children: [
                  CameraTab(),
                  Icon(Icons.list_alt),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
