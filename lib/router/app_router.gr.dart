// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:mylifeflow_app/launch.dart' as _i4;
import 'package:mylifeflow_app/schedule/after.dart' as _i1;
import 'package:mylifeflow_app/schedule/calendar.dart' as _i2;
import 'package:mylifeflow_app/schedule/current.dart' as _i3;
import 'package:mylifeflow_app/schedule/schedule_main.dart' as _i5;
import 'package:mylifeflow_app/schedule/statistics/scheduletypes.dart' as _i6;
import 'package:mylifeflow_app/settings/settings.dart' as _i7;
import 'package:mylifeflow_app/user/sign_in.dart' as _i8;

abstract class $AppRouter extends _i9.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    AfterScheduleRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AfterSchedulePage(),
      );
    },
    CalenderScheduleRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i2.CalenderSchedulePage(),
      );
    },
    CurrentScheduleRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.CurrentSchedulePage(),
      );
    },
    LaunchRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i4.LaunchPage(),
      );
    },
    ScheduleMainRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.ScheduleMainPage(),
      );
    },
    ScheduleTypeRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.ScheduleTypePage(),
      );
    },
    SettingRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.SettingPage(),
      );
    },
    SignInRoute.name: (routeData) {
      return _i9.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i8.SignInPage(),
      );
    },
  };
}

/// generated route for
/// [_i1.AfterSchedulePage]
class AfterScheduleRoute extends _i9.PageRouteInfo<void> {
  const AfterScheduleRoute({List<_i9.PageRouteInfo>? children})
      : super(
          AfterScheduleRoute.name,
          initialChildren: children,
        );

  static const String name = 'AfterScheduleRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i2.CalenderSchedulePage]
class CalenderScheduleRoute extends _i9.PageRouteInfo<void> {
  const CalenderScheduleRoute({List<_i9.PageRouteInfo>? children})
      : super(
          CalenderScheduleRoute.name,
          initialChildren: children,
        );

  static const String name = 'CalenderScheduleRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i3.CurrentSchedulePage]
class CurrentScheduleRoute extends _i9.PageRouteInfo<void> {
  const CurrentScheduleRoute({List<_i9.PageRouteInfo>? children})
      : super(
          CurrentScheduleRoute.name,
          initialChildren: children,
        );

  static const String name = 'CurrentScheduleRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i4.LaunchPage]
class LaunchRoute extends _i9.PageRouteInfo<void> {
  const LaunchRoute({List<_i9.PageRouteInfo>? children})
      : super(
          LaunchRoute.name,
          initialChildren: children,
        );

  static const String name = 'LaunchRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i5.ScheduleMainPage]
class ScheduleMainRoute extends _i9.PageRouteInfo<void> {
  const ScheduleMainRoute({List<_i9.PageRouteInfo>? children})
      : super(
          ScheduleMainRoute.name,
          initialChildren: children,
        );

  static const String name = 'ScheduleMainRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i6.ScheduleTypePage]
class ScheduleTypeRoute extends _i9.PageRouteInfo<void> {
  const ScheduleTypeRoute({List<_i9.PageRouteInfo>? children})
      : super(
          ScheduleTypeRoute.name,
          initialChildren: children,
        );

  static const String name = 'ScheduleTypeRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i7.SettingPage]
class SettingRoute extends _i9.PageRouteInfo<void> {
  const SettingRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SettingRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}

/// generated route for
/// [_i8.SignInPage]
class SignInRoute extends _i9.PageRouteInfo<void> {
  const SignInRoute({List<_i9.PageRouteInfo>? children})
      : super(
          SignInRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignInRoute';

  static const _i9.PageInfo<void> page = _i9.PageInfo<void>(name);
}
