import 'package:equatable/equatable.dart';

abstract class RouterState extends Equatable {
  const RouterState() : super();
}

class RouterStateDetectorScreen extends RouterState {
  const RouterStateDetectorScreen() : super();

  @override
  List<Object?> get props => [];
}