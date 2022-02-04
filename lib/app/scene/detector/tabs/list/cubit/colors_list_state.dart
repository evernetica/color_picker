import 'package:equatable/equatable.dart';

class ColorsListState extends Equatable {
  const ColorsListState({int colorInfoIndex = -1})
      : _colorInfoIndex = colorInfoIndex,
        super();

  final int _colorInfoIndex;

  int get colorInfoIndex => _colorInfoIndex;

  @override
  List<Object?> get props => [_colorInfoIndex];
}
