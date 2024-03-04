import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mylifeflow_app/router/app_router.dart';

import 'config/interceptor/route_resolver.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: AutoRouterDelegate(
        _appRouter,
        navigatorObservers: () => [CustomRouteObserver()],
      ),
      routeInformationParser: _appRouter.defaultRouteParser(),

    );

  }
}

