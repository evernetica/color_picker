import 'package:color_picker/app/router/cubit/router_cubit.dart';
import 'package:color_picker/app/router/cubit/router_state.dart';
import 'package:color_picker/app/router/root_router_delegate.dart';
import 'package:color_picker/main.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppRoot extends StatelessWidget {
  AppRoot({Key? key}) : super(key: key);

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RouterCubit(),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child:
              BlocBuilder<RouterCubit, RouterState>(builder: (context, state) {
            l10n = AppLocalizations.of(context);

            return Router(
              routerDelegate: RouterRootDelegate(
                navigatorKey,
                context.read<RouterCubit>(),
              ),
              backButtonDispatcher: RootBackButtonDispatcher(),
            );
          }),
        ),
      ),
    );
  }
}
