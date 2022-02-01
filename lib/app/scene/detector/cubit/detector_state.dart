import 'dart:async';

import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:equatable/equatable.dart';

class DetectorScreenState extends Equatable {
  DetectorScreenState(List<ColorsSheetItemEntity>? colorsEntitiesList, StreamController<ColorsSheetItemEntity>? addColorController)
      : _colorsEntitiesList = colorsEntitiesList ?? const [],
        _addColorController = addColorController ?? StreamController(),
        super();

  final StreamController<ColorsSheetItemEntity> _addColorController;

  StreamController<ColorsSheetItemEntity> get addColorController =>
      _addColorController;

  final List<ColorsSheetItemEntity> _colorsEntitiesList;

  List<ColorsSheetItemEntity> get colorsEntitiesList => _colorsEntitiesList;

  @override
  List<Object?> get props => [_colorsEntitiesList];
}
