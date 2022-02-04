import 'package:color_picker/app/scene/detector/tabs/list/cubit/colors_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ColorsListCubit extends Cubit<ColorsListState> {
  ColorsListCubit() : super(const ColorsListState());

  setColorInfoIndex({int index = -1}) {
    if (index == state.colorInfoIndex) {
      emit(const ColorsListState());
    } else {
      emit(ColorsListState(colorInfoIndex: index));
    }
  }
}
