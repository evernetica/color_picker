import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetectorScreenCubit extends Cubit<DetectorScreenState> {
  DetectorScreenCubit() : super(const CameraState());
}
