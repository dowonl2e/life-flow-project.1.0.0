import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mylifeflow_app/common/values/const.dart';
import 'package:mylifeflow_app/router/app_router.gr.dart';

@RoutePage()
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final storage = FlutterSecureStorage();
  String? _userName, _userEmail, _userPlatform;

  @override
  void initState(){
    super.initState();
    _loadInit();
  }

  void _loadInit() async {
    String? userName = await storage.read(key: userNameKey) ?? '';
    String? userEmail = await storage.read(key: userEmailKey) ?? '';
    String? userPlatform = await storage.read(key: userPlatformKey) ?? '';
    setState(() {
      _userName = userName;
      _userEmail = userEmail;
      _userPlatform = userPlatform;
    });
  }

  void _logout() async {
    await storage.delete(key: userNameKey);
    await storage.delete(key: userEmailKey);
    await storage.delete(key: userPlatformKey);
    await storage.delete(key: accessTokenKey);
    await storage.delete(key: accessTokenExpioresKey);
    await storage.delete(key: refreshTokenKey);
    await storage.delete(key: refreshTokenExpioresKey);
    _goSignInPage();
  }

  void _goSignInPage(){
    context.router.popAndPush(const SignInRoute());
  }

  Widget _settingText(String text){
    return Text(
      text,
      style: TextStyle(
        fontSize: 17
      )
    );
  }

  Widget _settingItem(IconData icon, String text, GestureTapCallback? callback){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: callback,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.logout_outlined,
            color: Colors.blueAccent,
            size: 40,
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 10, right: 10
            ),
            child: _settingText('Logout')
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 15, right: 25, bottom: 15
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.account_box_outlined,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10
                    ),
                    child: _settingText('$_userName ($_userEmail)')
                  )
                ],
              )
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 25, top: 15, right: 25, bottom: 15
              ),
              child: _settingItem(Icons.logout_outlined, 'Logout', _logout),
            )
          ],
        )
    );
  }

}