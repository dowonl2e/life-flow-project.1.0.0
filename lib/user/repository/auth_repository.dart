import 'package:dio/dio.dart';
import 'package:mylifeflow_app/user/model/token_model.dart';

import '../../common/values/api_values.dart';
import '../../config/interceptor/custom_auth_interceptor.dart';

class AuthRepository {

  final dio = Dio(BaseOptions(
    baseUrl: ApiValues.requestUrl,
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ))..interceptors.add(CustomAuthInterceptor());

  Future<TokenModel?> postIssueToken(String userEmail) {
    try {
      return dio.post(
        "${ApiValues.requestUrl}/auth/api/issue",
        queryParameters: {
          'userEmail': userEmail
        }
      ).then((response) {
        print(response.statusCode);
        if(response.statusCode! >= 200 && response.statusCode! < 300){
          Map<String, dynamic> responseMap = response.data ?? {};
          print(responseMap.toString());
          Map<String, dynamic> itemsMap = responseMap['data'] ?? {};
          print(itemsMap.toString());
          return TokenModel.fromJson(responseMap);
        }
        else {
          return Future(() => null);
        }
      });
    } on DioException catch(e){
      throw Exception(e);
    } catch(e){
      throw Exception(e);
    }
  }

  Future<TokenModel?> postReIssueToken() {
    try {
      return dio.post(
        "${ApiValues.requestUrl}/auth/api/reissue",
      ).then((response) {
        print("체크: ${response.statusCode}");
        if(response.statusCode! >= 200 && response.statusCode! < 300){
          Map<String, dynamic> responseMap = response.data ?? {};
          return TokenModel.fromJson(responseMap);
        }
        else {
          return Future(() => null);
        }
      });
    } on DioException catch(e){
      throw Exception(e);
    }
    catch(e){
      throw Exception(e);
    }
  }

}