import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mylifeflow_app/common/values/const.dart';
import 'package:mylifeflow_app/router/app_router.gr.dart';
import 'package:mylifeflow_app/user/repository/auth_repository.dart';

import '../common/common_toast.dart';
import '../user/model/token_model.dart';

class AuthGuard extends AutoRouteGuard {

  final storage = FlutterSecureStorage();
  final authRepository = AuthRepository();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    print('onNavigation: ${resolver.route.name}');

    String? userEmail = await storage.read(key: userEmailKey);
    String? accessToken = await storage.read(key: accessTokenKey);
    final accessTokenExpires = await storage.read(key: accessTokenExpioresKey);
    int expiredTime = int.parse(accessTokenExpires!);
    final nowTime = DateTime.now().microsecondsSinceEpoch/1000;
    bool isExpired = (expiredTime - nowTime) > (1000*60*3) ? false : true;
    if(userEmail != null && accessToken != null && !isExpired){
      resolver.next(true);
    }
    else {
      try {
        TokenModel? tokenModel = await authRepository.postReIssueToken();
        print('체크: $tokenModel');
        if(tokenModel == null) {
          showValidToast('로그인 후 이용해주세요.');
          router.popAndPush(const SignInRoute());
        }
        else {
          await storage.write(key: accessTokenKey, value: tokenModel?.accessToken);
          await storage.write(key: accessTokenExpioresKey, value: tokenModel?.accessTokenExpioresIn.toString());
          await storage.write(key: refreshTokenKey, value: tokenModel?.refreshToken);
          await storage.write(key: refreshTokenExpioresKey, value: tokenModel?.refreshTokeExpioresIn.toString());
          resolver.next(true);
        }
      } on DioException catch(e){
        print('DioException: ${e.toString()}');
        showValidToast('로그인 후 이용해주세요.');
        router.popAndPush(const SignInRoute());
      }
    }
  }
}