import 'dart:async';

import 'package:camera/camera.dart';
import 'package:color_picker/app/app_root.dart';
import 'package:color_picker/data/repositories/colors_sheet_list_git_repository.dart';
import 'package:color_picker/domain/use_cases/colors_sheet_list_use_case.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

late ColorsSheetListUseCase colorsSheetListUseCase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  colorsSheetListUseCase =
      ColorsSheetListUseCase(ColorsSheetListGitRepositoryImpl());

  runApp(AppRoot());
}
