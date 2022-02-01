import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';

abstract class IFavouriteColorsFileRepository {
  Future<List<ColorsSheetItemEntity>> getFavouriteColorsFromFile();

  Future<void> saveFavouriteColorsToFile(
      List<ColorsSheetItemEntity> favouriteColorsList);
}
