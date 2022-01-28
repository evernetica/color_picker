import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';

abstract class ColorsSheetItemMapper {
  static ColorsSheetItemEntity map(String code, String name) =>
      ColorsSheetItemEntity(code: code, name: name);
}