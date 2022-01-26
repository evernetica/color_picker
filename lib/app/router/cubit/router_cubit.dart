import 'package:color_picker/app/router/cubit/router_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouterCubit extends Cubit<RouterState> {
  RouterCubit() : super(const RouterStateDetectorScreen());
}
