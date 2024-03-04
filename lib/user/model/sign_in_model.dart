import 'dart:convert';

SignInModel fromJson(String str) => SignInModel.fromJson(json.decode(str));

String postToJson(SignInModel data) => json.encode(data.toJson());


class SignInModel {
  SignInModel({
    required this.token,
  });

  SignInModel.init();

  String? token;
  String? userEmail;

  factory SignInModel.fromJson(Map<String, dynamic>? json) => SignInModel(
    token: json?["token"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };

}