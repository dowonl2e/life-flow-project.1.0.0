import 'dart:convert';

TokenModel fromJson(String str) => TokenModel.fromJson(json.decode(str));

class TokenModel {
  TokenModel({
    required this.grantType,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpioresIn,
    required this.refreshTokeExpioresIn,
  });

  TokenModel.init();

  String? grantType;
  String? accessToken;
  String? refreshToken;
  int? accessTokenExpioresIn;
  int? refreshTokeExpioresIn;

  factory TokenModel.fromJson(Map<String, dynamic>? json) => TokenModel(
    grantType: json?["grantType"] ?? "",
    accessToken: json?["accessToken"] ?? "",
    refreshToken: json?["refreshToken"] ?? "",
    accessTokenExpioresIn: json?["accessTokenExpioresIn"] ?? "",
    refreshTokeExpioresIn: json?["refreshTokeExpioresIn"] ?? "",
  );
}