import 'package:dio/dio.dart';
import 'package:mylifeflow_app/common/values/api_values.dart';
import 'package:mylifeflow_app/config/interceptor/custom_interceptor.dart';
import 'package:mylifeflow_app/schedule/statistics/model/statisticsmodel.dart';


class StatisticsRepository {
  final dio = Dio(BaseOptions(
    baseUrl: ApiValues.requestUrl,
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ))..interceptors.add(CustomInterceptor());

  Future<List<StatisticsModel>> fetchMonthlyScheduleType(String searchYear) {
    try {
      return dio.get(
          "${ApiValues.requestUrl}/statistics/api/monthly/scheduletypes",
          queryParameters: {
            'searchYear': searchYear
          }
      ).then((response) {
        switch(response.statusCode){
          case 200:
            Map<String, dynamic> responseMap = response.data;
            Map<String, dynamic> itemsMap = responseMap['data'];
            List<dynamic> items = itemsMap['items'];
            return items.map((e) => StatisticsModel.fromJson(e)).toList();
          default:
            return [];
        }
      }
      );
    } on DioException catch (e){
      throw Exception(e);
    }
  }
}