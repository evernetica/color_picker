import 'dart:convert';

import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/domain/mappers/colors_sheet_item_mapper.dart';
import 'package:color_picker/domain/repositories_interfaces/i_colors_sheet_list_repository.dart';
import 'package:http/http.dart' as http;

class ColorsSheetListGitRepositoryImpl implements IColorsSheetListRepository {
  @override
  Future<List<ColorsSheetItemEntity>> getColorsSheetList() async {
    http.Response response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/jonathantneal/color-names/master/color-names.json'));

    Map<String, dynamic> json = jsonDecode(response.body);

    List<ColorsSheetItemEntity> colorsSheetList = [];

    for (String key in json.keys) {
      colorsSheetList.add(ColorsSheetItemMapper.map(key, json[key]));
    }

    return colorsSheetList;
  }
}
