import 'dart:async';

import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:equatable/equatable.dart';

class DetectorScreenState extends Equatable {
  DetectorScreenState({
    List<ColorsSheetItemEntity>? colorsEntitiesList,
    StreamController<ColorsSheetItemEntity>? addColorController,
    int? currentTab,
    List<ColorsSheetItemEntity>? colorsSheetList,
  })  : _colorsEntitiesList = colorsEntitiesList ?? const [],
        _addColorController = addColorController ?? StreamController(),
        _colorsSheetList = colorsSheetList ?? const [],
        _currentTab = currentTab ?? 0,
        super();

  final StreamController<ColorsSheetItemEntity> _addColorController;

  StreamController<ColorsSheetItemEntity> get addColorController =>
      _addColorController;

  final List<ColorsSheetItemEntity> _colorsEntitiesList;

  List<ColorsSheetItemEntity> get colorsEntitiesList => _colorsEntitiesList;

  final int _currentTab;

  int get currentTab => _currentTab;

  final List<ColorsSheetItemEntity> _colorsSheetList;

  List<ColorsSheetItemEntity> get colorsSheetList => _colorsSheetList;

  @override
  List<Object?> get props => [
        _colorsEntitiesList,
        _currentTab,
        _colorsSheetList,
      ];
}
