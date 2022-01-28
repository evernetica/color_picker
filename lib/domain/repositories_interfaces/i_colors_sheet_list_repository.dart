import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';

abstract class IColorsSheetListRepository {
  Future<List<ColorsSheetItemEntity>> getColorsSheetList();
}