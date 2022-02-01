import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/domain/repositories_interfaces/i_favourite_colors_file_repository.dart';

class FavouriteColorsFileUseCase {
  FavouriteColorsFileUseCase(this.repository);

  final IFavouriteColorsFileRepository repository;

  Future<List<ColorsSheetItemEntity>> getFavouriteColorsFromFile() =>
      repository.getFavouriteColorsFromFile();

  Future<void> saveFavouriteColorsToFile(
          List<ColorsSheetItemEntity> favouriteColorsList) =>
      repository.saveFavouriteColorsToFile(favouriteColorsList);
}
