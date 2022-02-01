import 'dart:convert';
import 'dart:io';

import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/domain/repositories_interfaces/i_favourite_colors_file_repository.dart';
import 'package:path_provider/path_provider.dart';

class FavouriteColorsFileRepositoryImpl extends IFavouriteColorsFileRepository {
  @override
  Future<List<ColorsSheetItemEntity>> getFavouriteColorsFromFile() async {
    List<ColorsSheetItemEntity> listFromFile = [];

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;

    File file = File('$path/favouriteColors.json');

    String contents = await file.readAsString();

    Map<String, dynamic> colorsMap = jsonDecode(contents);

    for (String key in colorsMap.keys) {
      listFromFile
          .add(ColorsSheetItemEntity(code: key, name: colorsMap[key] ?? ""));
    }

    return listFromFile;
  }

  @override
  Future<void> saveFavouriteColorsToFile(
      List<ColorsSheetItemEntity> favouriteColorsList) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path;

    File file = File('$path/favouriteColors.json');

    Map<String, String> colorsMap = {};

    for (ColorsSheetItemEntity colorItem in favouriteColorsList) {
      colorsMap.addAll({colorItem.code: colorItem.name});
    }

    await file.writeAsString(jsonEncode(colorsMap));
  }
}
