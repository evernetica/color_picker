import 'package:color_picker/app/router/cubit/router_cubit.dart';
import 'package:color_picker/app/router/cubit/router_state.dart';
import 'package:color_picker/app/router/root_router_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoot extends StatelessWidget {
  AppRoot({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouterCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: BlocBuilder<RouterCubit, RouterState>(
            builder: (context, state) => Router(
              routerDelegate: RouterRootDelegate(
                navigatorKey,
                context.read<RouterCubit>(),
              ),
              backButtonDispatcher: RootBackButtonDispatcher(),
            ),
          ),
        ),
      ),
    );
  }
}
