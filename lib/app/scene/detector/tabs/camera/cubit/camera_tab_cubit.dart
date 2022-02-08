import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:color_picker/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraTabCubit extends Cubit<CameraTabState> {
  CameraTabCubit() : super(const CameraTabState()) {
    loadDefaultColors();
    checkIfBuggedIphone();
  }

  //  "iPhone7,2"                       :        "iPhone 6"
  //  "iPhone7,1"                       :        "iPhone 6 Plus"
  //  "iPhone8,1"                       :        "iPhone 6s"
  //  "iPhone8,2"                       :        "iPhone 6s Plus"
  //  "iPhone9,1", "iPhone9,3"          :        "iPhone 7"
  //  "iPhone9,2", "iPhone9,4"          :        "iPhone 7 Plus"
  //  "iPhone8,4"                       :        "iPhone SE"
  //  "iPhone10,1", "iPhone10,4"        :        "iPhone 8"
  //  "iPhone10,2", "iPhone10,5"        :        "iPhone 8 Plus"

  final List<String> utsNames = const [
    "iPhone7,2",
    "iPhone7,1",
    "iPhone8,1",
    "iPhone8,2",
    "iPhone9,1",
    "iPhone9,3",
    "iPhone9,2",
    "iPhone9,4",
    "iPhone8,4",
    "iPhone10,1",
    "iPhone10,4",
    "iPhone10,2",
    "iPhone10,5",
  ];

  void checkIfBuggedIphone() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    BaseDeviceInfo deviceInfo = await deviceInfoPlugin.deviceInfo;

    if (deviceInfo.runtimeType == AndroidDeviceInfo) {
      emit(CameraTabState(
          colorsSheetList: state.colorsSheetList, isBuggedIphoneModel: false));
      return;
    }

    for (String utsName in utsNames) {
      if ((deviceInfo as IosDeviceInfo).utsname.machine!.contains(utsName)) {
        emit(CameraTabState(
            colorsSheetList: state.colorsSheetList, isBuggedIphoneModel: true));
        return;
      }
    }

    emit(CameraTabState(
        colorsSheetList: state.colorsSheetList, isBuggedIphoneModel: false));
  }

  void loadDefaultColors() async {
    emit(CameraTabState(
        colorsSheetList: await colorsSheetListUseCase.getColorsSheetList(),
        isBuggedIphoneModel: state.isBuggedIphoneModel));
  }
}
