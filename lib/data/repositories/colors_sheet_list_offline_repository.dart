import 'package:color_picker/data/colors_sheet.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/domain/mappers/colors_sheet_item_mapper.dart';
import 'package:color_picker/domain/repositories_interfaces/i_colors_sheet_list_repository.dart';

class ColorsSheetListOfflineRepositoryImpl extends IColorsSheetListRepository {
  @override
  Future<List<ColorsSheetItemEntity>> getColorsSheetList() async {
    List<ColorsSheetItemEntity> colorsSheetList = [];

    ColorsSheet colorsSheet = ColorsSheet();

    for (String key in colorsSheet.map.keys) {
      colorsSheetList
          .add(ColorsSheetItemMapper.map(key, colorsSheet.map[key] ?? ""));
    }

    return colorsSheetList;
  }
}
