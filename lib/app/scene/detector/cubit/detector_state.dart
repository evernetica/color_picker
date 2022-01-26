import 'package:equatable/equatable.dart';

abstract class DetectorScreenState extends Equatable {
  const DetectorScreenState() : super();
}

class CameraState extends DetectorScreenState {
  const CameraState() : super();

  @override
  List<Object?> get props => [];
}

class ColorsListState extends DetectorScreenState {
  const ColorsListState() : super();

  @override
  List<Object?> get props => [];
}
