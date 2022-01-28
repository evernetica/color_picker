import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:equatable/equatable.dart';

class CameraTabState extends Equatable {
  const CameraTabState({List<ColorsSheetItemEntity>? colorsSheetList})
      : _colorsSheetList = colorsSheetList ?? const [],
        super();

  final List<ColorsSheetItemEntity> _colorsSheetList;

  List<ColorsSheetItemEntity> get colorsSheetList => _colorsSheetList;

  @override
  List<Object?> get props => [_colorsSheetList.length];
}
