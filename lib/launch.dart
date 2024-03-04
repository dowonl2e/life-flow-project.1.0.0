import 'dart:async';

import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mylifeflow_app/router/app_router.gr.dart';
import 'package:mylifeflow_app/schedule/schedule_main.dart';
import 'package:mylifeflow_app/user/sign_in.dart';

import 'common/values/const.dart';

@RoutePage()
class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final storage = FlutterSecureStorage(); //flutter_secure_storage 사용을 위한 초기화 작업
  bool isAuthentication = false;
  String? token, userEmail;

  final _innerRouterKey = GlobalKey<AutoRouterState>();

  @override
  void initState() {
    super.initState();

    //비동기로 flutter secure storage 정보를 불러오는 작업.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });

    Timer(Duration(milliseconds: 2000), () {
      // context.router.popAndPush(const SignInRoute());

      switch(isAuthentication){
        case true:
          context.router.popAndPush(const ScheduleMainRoute());
          break;
        case false:
          context.router.popAndPush(const SignInRoute());
          break;
      }
    });
  }

  _asyncMethod() async {
    userEmail = await storage.read(key: userEmailKey);
    if (userEmail != null) {
      isAuthentication = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
          child: Text(
            "My Life Flow",
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold
            ),
          ),
        )
    );
  }
}
