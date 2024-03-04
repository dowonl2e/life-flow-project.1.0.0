enum SignInPlatform {
  google('GOOGLE', 'assets/images/google_logo.png'),
  kakao('KAKAO', ''),
  facebook('FACEBOOK', ''),
  naver('NAVER', ''),
  none('NONE', '');

  const SignInPlatform(this.name, this.logoPath);

  final String name;
  final String logoPath;

  factory SignInPlatform.getByName(String name){
    return SignInPlatform.values.firstWhere((value) => value.name == name,
        orElse: () => SignInPlatform.none);
  }
}