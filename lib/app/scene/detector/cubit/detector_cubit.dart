import 'dart:async';

import 'package:color_picker/app/scene/detector/cubit/detector_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetectorScreenCubit extends Cubit<DetectorScreenState> {
  StreamSubscription? subscription;

  DetectorScreenCubit() : super(DetectorScreenState()) {
    getDefaultColorsSheetList();

    getFavouriteColorsFromFile();

    subscription = state.addColorController.stream.listen((event) {
      List<ColorsSheetItemEntity> colorsEntitiesList = [
        ...state.colorsEntitiesList
      ];
      colorsEntitiesList.add(event);
      emit(DetectorScreenState(
        colorsEntitiesList: colorsEntitiesList,
        addColorController: state.addColorController,
        currentTab: state.currentTab,
        colorsSheetList: state.colorsSheetList,
      ));

      saveFavouritesToFile();
    });
  }

  void getDefaultColorsSheetList() async {
    List<ColorsSheetItemEntity> colorsSheetList = [];

    while (colorsSheetList.isEmpty) {
      try {
        colorsSheetList = await colorsSheetListUseCase.getColorsSheetList();
      } catch (ex) {
        await Future.delayed(const Duration(seconds: 3));
        continue;
      }
    }

    emit(DetectorScreenState(
      colorsEntitiesList: state.colorsEntitiesList,
      addColorController: state.addColorController,
      currentTab: state.currentTab,
      colorsSheetList: colorsSheetList,
    ));
  }

  void removeColorFromList(int index) {
    List<ColorsSheetItemEntity> colorsEntitiesList = [
      ...state.colorsEntitiesList
    ];

    colorsEntitiesList.removeAt(index);

    emit(DetectorScreenState(
      colorsEntitiesList: colorsEntitiesList,
      addColorController: state.addColorController,
      currentTab: state.currentTab,
      colorsSheetList: state.colorsSheetList,
    ));

    saveFavouritesToFile();
  }

  void getFavouriteColorsFromFile() async {
    emit(DetectorScreenState(
      colorsEntitiesList:
          await favouriteColorsFileUseCase.getFavouriteColorsFromFile(),
      addColorController: state.addColorController,
      currentTab: state.currentTab,
      colorsSheetList: state.colorsSheetList,
    ));
  }

  void saveFavouritesToFile() async {
    favouriteColorsFileUseCase
        .saveFavouriteColorsToFile(state.colorsEntitiesList);
  }

  void deleteAllFavourites() {
    emit(DetectorScreenState(
      colorsEntitiesList: const [],
      addColorController: state.addColorController,
      currentTab: state.currentTab,
      colorsSheetList: state.colorsSheetList,
    ));
    saveFavouritesToFile();
  }

  void setCurrentTab(int tab) {
    emit(DetectorScreenState(
      colorsEntitiesList: state.colorsEntitiesList,
      addColorController: state.addColorController,
      currentTab: tab,
      colorsSheetList: state.colorsSheetList,
    ));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
