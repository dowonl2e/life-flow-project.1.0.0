import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../common/values/const.dart';

class CustomAuthInterceptor extends Interceptor {
  final storage = FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.path.endsWith('/reissue')){
      final token = await storage.read(key: accessTokenKey);
      final refreshToken = await storage.read(key: refreshTokenKey);
      options.headers.addAll({
        'access-token': 'Bearer $token',
        'refresh-token': 'Bearer $refreshToken',
      });
    }
    print('REQUEST[${options.method}] - ${DateTime.now()} => PATH: ${options.path} | HEADER : ${options.headers} | PARAMS : ${options.queryParameters}');

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
