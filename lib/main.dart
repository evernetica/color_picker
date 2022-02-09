import 'dart:async';

import 'package:camera/camera.dart';
import 'package:color_picker/app/app_root.dart';
import 'package:color_picker/data/repositories/colors_sheet_list_offline_repository.dart';
import 'package:color_picker/data/repositories/favourite_colors_file_repository.dart';
import 'package:color_picker/domain/use_cases/colors_sheet_list_use_case.dart';
import 'package:color_picker/domain/use_cases/favourite_colors_file_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

late List<CameraDescription> cameras;

late ColorsSheetListUseCase colorsSheetListUseCase;
late FavouriteColorsFileUseCase favouriteColorsFileUseCase;

dynamic l10n;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Wakelock.enable();

  cameras = await availableCameras();

  colorsSheetListUseCase =
      ColorsSheetListUseCase(ColorsSheetListOfflineRepositoryImpl());
  favouriteColorsFileUseCase =
      FavouriteColorsFileUseCase(FavouriteColorsFileRepositoryImpl());

  runApp(AppRoot());
}
