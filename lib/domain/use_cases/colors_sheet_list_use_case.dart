import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/domain/repositories_interfaces/i_colors_sheet_list_repository.dart';

class ColorsSheetListUseCase {
  ColorsSheetListUseCase(this.repository);

  final IColorsSheetListRepository repository;

  Future<List<ColorsSheetItemEntity>> getColorsSheetList() =>
      repository.getColorsSheetList();
}
