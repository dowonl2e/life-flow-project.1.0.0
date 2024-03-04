import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mylifeflow_app/user/enum/sign_in_platform.dart';
import 'package:mylifeflow_app/user/model/token_model.dart';
import 'package:mylifeflow_app/user/repository/auth_repository.dart';

import '../common/common_toast.dart';
import '../common/values/const.dart';
import '../router/app_router.gr.dart';

@RoutePage()
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPage();

}

class _SignInPage extends State<SignInPage> {

  final storage = FlutterSecureStorage();
  final authRepository = AuthRepository();
  bool _isLoading = false;

  void signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

    if (googleSignInAccount != null) {
      String userEmail = googleSignInAccount.email;
      setState(() {
        _isLoading = true;
      });

      try {
        TokenModel? model = await authRepository.postIssueToken(userEmail);
        if(model != null) {
          await storage.write(key: userEmailKey, value: userEmail);
          await storage.write(key: userNameKey, value: '이도원');
          // await storage.write(key: userEmailKey, value: googleSignInAccount.email);
          // await storage.write(key: userNameKey, value: googleSignInAccount.displayName);
          await storage.write(key: userPlatformKey, value: SignInPlatform.google.name);

          await storage.write(key: accessTokenKey, value: model?.accessToken);
          await storage.write(key: accessTokenExpioresKey, value: model?.accessTokenExpioresIn.toString());
          await storage.write(key: refreshTokenKey, value: model?.refreshToken);
          await storage.write(key: refreshTokenExpioresKey, value: model?.refreshTokeExpioresIn.toString());
          goScheduleMain();
        }
      } on DioException catch(e){
        if(e.type == DioExceptionType.connectionError){
          showResponseToast("네트워크 연결에 실패했습니다.");
        }
        else if(e.type == DioExceptionType.connectionTimeout){
          showResponseToast("요청이 만료되었습니다.");
        }
        else if(e.type == DioExceptionType.receiveTimeout){
          showResponseToast("응답에 실패했습니다.");
        }
        else {
          showResponseToast("요청에 실패했습니다.");
        }
      } catch (e){
        showResponseToast("요청에 실패했습니다.");
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  void goScheduleMain(){
    context.router.popAndPush(const ScheduleMainRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading ? CircularProgressIndicator()
                : _signInButton(
                  'google_logo',
                  signInWithGoogle,
                )
          ],
        )
      ),
    );
  }

  Widget _signInButton(String path, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.all(5),
      elevation: 5.0,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: Ink.image(
        image: AssetImage('assets/images/$path.png'),
        width: 60,
        height: 60,
        child: InkWell(
          borderRadius: const BorderRadius.all(
            Radius.circular(35.0),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
