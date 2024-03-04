import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mylifeflow_app/router/app_router.gr.dart';

@RoutePage()
class ScheduleMainPage extends StatelessWidget {
  const ScheduleMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        CurrentScheduleRoute(),
        CalenderScheduleRoute(),
        AfterScheduleRoute(),
        ScheduleTypeRoute(),
        SettingRoute(),
      ],
      inheritNavigatorObservers: true,
      transitionBuilder: (context,child,animation)=> FadeTransition(
        opacity: animation,
        // the passed child is technically our animated selected-tab page
        child: child,
      ),
      builder: (context, child) {
        final tabRouter = AutoTabsRouter.of(context);

        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: tabRouter.activeIndex,
            onTap: (index) {
              tabRouter.setActiveIndex(index, notify: true);
            },
            unselectedItemColor: Colors.black54,
            showUnselectedLabels: true,
            unselectedLabelStyle: TextStyle(
              color: Colors.black26
            ),
            selectedLabelStyle: TextStyle(
              color: Colors.black
            ),
            backgroundColor: Colors.white,
            fixedColor: Colors.black,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.list,), label: '전체일정'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: '달력'),
              BottomNavigationBarItem(icon: Icon(Icons.list_alt_rounded), label: '추후일정'),
              BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: '차트'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
            ],
          ),
        );
      },
    );
  }

}


