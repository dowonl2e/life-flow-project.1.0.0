import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mylifeflow_app/user/model/token_model.dart';
import 'package:mylifeflow_app/user/repository/auth_repository.dart';

import '../../common/values/const.dart';

class CustomInterceptor extends Interceptor {
  final storage = FlutterSecureStorage();
  final authRepository = AuthRepository();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print('REQUEST[${options.method}] - ${DateTime.now()} => PATH: ${options.path} | HEADER : ${options.headers} | PARAMS : ${options.queryParameters}');

    final token = await storage.read(key: accessTokenKey);
    options.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] - ${DateTime.now()} => PATH: ${response.requestOptions.path} | PARAMS : ${response.requestOptions.queryParameters}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] - ${DateTime.now()} => PATH: ${err.requestOptions.path} | PARAMS : ${err.requestOptions.queryParameters}',
    );
    super.onError(err, handler);
  }

}