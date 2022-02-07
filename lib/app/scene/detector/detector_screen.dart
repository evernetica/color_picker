import 'package:color_picker/app/scene/detector/cubit/detector_cubit.dart';
import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/camera_tab.dart';
import 'package:color_picker/app/scene/detector/tabs/list/colors_list_tab.dart';
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
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: _detectorScreenAppBar(context, state.currentTab),
            backgroundColor: Colors.white,
            body: TabBarDetectorScreen(state),
          );
        },
      ),
    );
  }

  AppBar _detectorScreenAppBar(BuildContext context, int tab) {
    switch (tab) {
      case 1:
        return AppBar(
          leading: Icon(Icons.arrow_back),
          backgroundColor: Colors.black,
          title: const Text("Favourites"),
          flexibleSpace: const Align(
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.code,
              color: Colors.white38,
            ),
          ),
        );
      default:
        return AppBar(
          shadowColor: Colors.transparent,
          backgroundColor: Colors.black12,
          title: const Text("Color Picker"),
          flexibleSpace: const Align(
            alignment: Alignment.bottomCenter,
            child: Icon(Icons.code, color: Colors.white38),
          ),
        );
    }
  }
}

class TabBarDetectorScreen extends StatefulWidget {
  const TabBarDetectorScreen(this.state, {Key? key}) : super(key: key);

  final DetectorScreenState state;

  @override
  State<StatefulWidget> createState() => TabBarDetectorScreenState();
}

class TabBarDetectorScreenState extends State<TabBarDetectorScreen>
    with TickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);

    print("add listener");
    controller?.addListener(() {
      BlocProvider.of<DetectorScreenCubit>(context)
          .setCurrentTab(controller!.index);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: TabBarView(
        controller: controller,
        children: [
          CameraTab(widget.state.addColorController),
          ColorsListTab(
            widget.state.colorsEntitiesList,
            BlocProvider.of<DetectorScreenCubit>(context).removeColorFromList,
            BlocProvider.of<DetectorScreenCubit>(context).saveFavouritesToFile,
          ),
        ],
      ),
    );
  }
}
