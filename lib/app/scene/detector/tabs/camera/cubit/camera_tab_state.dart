import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:equatable/equatable.dart';

class CameraTabState extends Equatable {
  const CameraTabState(
      {List<ColorsSheetItemEntity>? colorsSheetList, bool? isBuggedIphoneModel})
      : _colorsSheetList = colorsSheetList ?? const [],
        _isBuggedIphoneModel = isBuggedIphoneModel,
        super();

  final List<ColorsSheetItemEntity> _colorsSheetList;
  final bool? _isBuggedIphoneModel;

  List<ColorsSheetItemEntity> get colorsSheetList => _colorsSheetList;

  bool? get isBuggedIphoneModel => _isBuggedIphoneModel;

  @override
  List<Object?> get props => [_colorsSheetList, _isBuggedIphoneModel];
}
