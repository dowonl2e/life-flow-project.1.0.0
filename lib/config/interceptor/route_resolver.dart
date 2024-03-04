import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';

class CustomRouteObserver extends AutoRouteObserver{
  // 화면이 push 될 때
  @override
  void didPush(Route route, Route? previousRoute) {
    print('New route pushed: ${route.settings.name}');
  }

  // Tab router 가 초기화 될 때
  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    print('Tab route visited: ${route.name}');
  }
  // Tab 이동이 일어날 때
  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    print('Tab route re-visited: ${route.name}');
  }
}