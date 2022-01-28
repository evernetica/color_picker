import 'package:color_picker/app/scene/detector/tabs/camera/cubit/camera_tab_state.dart';
import 'package:color_picker/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraTabCubit extends Cubit<CameraTabState> {
  CameraTabCubit() : super(const CameraTabState()) {

    loadDefaultColors();
  }

  void loadDefaultColors() async {
    emit(CameraTabState(
        colorsSheetList: await colorsSheetListUseCase.getColorsSheetList()));
  }
}
