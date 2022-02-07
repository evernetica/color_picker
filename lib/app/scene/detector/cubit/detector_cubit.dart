import 'dart:async';

import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetectorScreenCubit extends Cubit<DetectorScreenState> {
  StreamSubscription? subscription;

  DetectorScreenCubit() : super(DetectorScreenState(null, null, null)) {
    getFavouriteColorsFromFile();

    subscription = state.addColorController.stream.listen((event) {
      List<ColorsSheetItemEntity> colorsEntitiesList = [
        ...state.colorsEntitiesList
      ];
      colorsEntitiesList.add(event);
      emit(DetectorScreenState(
          colorsEntitiesList, state.addColorController, state.currentTab));

      saveFavouritesToFile();
    });
  }

  void removeColorFromList(int index) {
    List<ColorsSheetItemEntity> colorsEntitiesList = [
      ...state.colorsEntitiesList
    ];

    colorsEntitiesList.removeAt(index);

    emit(DetectorScreenState(
        colorsEntitiesList, state.addColorController, state.currentTab));

    saveFavouritesToFile();
  }

  void getFavouriteColorsFromFile() async {
    emit(DetectorScreenState(
        await favouriteColorsFileUseCase.getFavouriteColorsFromFile(),
        state.addColorController,
        state.currentTab));
  }

  void saveFavouritesToFile() async {
    favouriteColorsFileUseCase
        .saveFavouriteColorsToFile(state.colorsEntitiesList);
  }

  void deleteAllFavourites() {
    emit(DetectorScreenState(
        const [], state.addColorController, state.currentTab));
    saveFavouritesToFile();
  }

  void setCurrentTab(int tab) {
    emit(DetectorScreenState(state.colorsEntitiesList, state.addColorController, tab));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
