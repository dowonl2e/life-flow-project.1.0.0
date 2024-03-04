import 'package:auto_route/auto_route.dart';

import '../config/auth_guard.dart';
import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends $AppRouter {

  List<AuthGuard> authGuards = [AuthGuard()];

  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/', page: LaunchRoute.page),
    AutoRoute(path: '/signin', page: SignInRoute.page),
    AutoRoute(
      path: '/schedule',
      page: ScheduleMainRoute.page,
      children: [
        AutoRoute(path: 'currents', page: CurrentScheduleRoute.page, guards: authGuards),
        AutoRoute(path: 'calendar', page: CalenderScheduleRoute.page, guards: authGuards),
        AutoRoute(path: 'afters', page: AfterScheduleRoute.page, guards: authGuards),
        AutoRoute(path: 'stats', page: ScheduleTypeRoute.page, guards: authGuards),
        AutoRoute(path: 'settings', page: SettingRoute.page, guards: authGuards),
      ],
      guards: authGuards
    ),
  ];
}
