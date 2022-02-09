import 'package:color_picker/app/scene/detector/cubit/detector_cubit.dart';
import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:color_picker/app/scene/detector/tabs/camera/camera_tab.dart';
import 'package:color_picker/app/scene/detector/tabs/list/colors_list_tab.dart';
import 'package:color_picker/main.dart';
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
          return TabBarDetectorScreen(state);
        },
      ),
    );
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
    controller?.addListener(() {
      BlocProvider.of<DetectorScreenCubit>(context)
          .setCurrentTab(controller!.index);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _detectorScreenAppBar(context, widget.state, controller),
        backgroundColor: Colors.white,
        body: DefaultTabController(
          length: 2,
          child: TabBarView(
            controller: controller,
            children: [
              CameraTab(widget.state.addColorController),
              ColorsListTab(
                widget.state.colorsEntitiesList,
                BlocProvider.of<DetectorScreenCubit>(context)
                    .removeColorFromList,
                BlocProvider.of<DetectorScreenCubit>(context)
                    .saveFavouritesToFile,
              ),
            ],
          ),
        ));
  }
}

AppBar _detectorScreenAppBar(BuildContext context, DetectorScreenState state,
    TabController? controller) {
  switch (state.currentTab) {
    case 1:
      return appBarListTab(controller);
    default:
      return appBarCameraTab();
  }
}

Widget _tabIndicator(int currentTab, [int length = 2]) {
  Widget indicatorCircle(int tab) => Padding(
        padding: const EdgeInsets.all(4.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tab == currentTab ? Colors.white70 : Colors.white24,
            ),
          ),
        ),
      );

  List<Widget> widgets = [];
  for (int i = 0; i < length; i++) {
    widgets.add(indicatorCircle(i));
  }

  return FractionallySizedBox(
    heightFactor: 0.25,
    child: IntrinsicWidth(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    ),
  );
}

AppBar appBarListTab(TabController? controller) {
  return AppBar(
    leading: TextButton(
        onPressed: () {
          controller?.animateTo(0);
        },
        style: ButtonStyle(
          foregroundColor:
              MaterialStateColor.resolveWith((states) => Colors.white),
          overlayColor:
              MaterialStateColor.resolveWith((states) => Colors.white30),
        ),
        child: const Icon(Icons.arrow_back)),
    backgroundColor: Colors.black,
    title: Text(l10n?.favouritesTitle ?? ""),
    flexibleSpace: Align(
      alignment: Alignment.bottomCenter,
      child: _tabIndicator(1),
    ),
    actions: [
      _popupMenuButton(),
    ],
  );
}

Widget _popupMenuButton() {
  return PopupMenuButton(
    child: const Padding(
      padding: EdgeInsets.all(16.0),
      child: Icon(Icons.menu),
    ),
    itemBuilder: (context) => [
      PopupMenuItem(
        onTap: () {
          BlocProvider.of<DetectorScreenCubit>(context).deleteAllFavourites();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Icon(
              Icons.delete_sweep,
              color: Colors.black,
            ),
            Text(l10n?.deleteAllButtonText ?? ""),
          ],
        ),
      ),
    ],
  );
}

AppBar appBarCameraTab() {
  return AppBar(
    shadowColor: Colors.transparent,
    backgroundColor: Colors.black12,
    title: const Text("Color Picker"),
    flexibleSpace: Align(
      alignment: Alignment.bottomCenter,
      child: _tabIndicator(0),
    ),
  );
}
