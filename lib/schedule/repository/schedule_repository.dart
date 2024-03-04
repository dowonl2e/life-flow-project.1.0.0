import 'package:dio/dio.dart';
import 'package:mylifeflow_app/common/model/response_model.dart';
import 'package:mylifeflow_app/common/values/api_values.dart';
import 'package:mylifeflow_app/config/interceptor/custom_interceptor.dart';
import 'package:mylifeflow_app/schedule/model/schedulemodel.dart';

import '../../common/filter/pagination_filter.dart';

class ScheduleRepository {
  final dio = Dio(BaseOptions(
    baseUrl: ApiValues.requestUrl,
    connectTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 3),
  ))..interceptors.add(CustomInterceptor());

  Future<List<ScheduleModel>> fetchCurrentSchedules(PaginationFilter filter, List<String> searchScheduleTypes) {
    try {
      return dio.get(
          "${ApiValues.requestUrl}/schedule/api/items",
          queryParameters: {
            'searchScheduleTypes': searchScheduleTypes,
            'currentPage': filter.page,
            'pageSize': filter.limit
          }
        ).then((response) {
          switch(response.statusCode){
            case 200:
              Map<String, dynamic> responseMap = response.data;
              Map<String, dynamic> itemsMap = responseMap['data'];
              List<dynamic> items = itemsMap['items'];
              return items.map((e) => ScheduleModel.fromJson(e)).toList();
            default:
              return [];
          }
        }
      );
    } on DioException catch (e){
      throw Exception(e);
    }
  }

  Future<ScheduleModel?> fetchSchedule(int scheduleNo) {
    try {
      return dio.get("${ApiValues.requestUrl}/schedule/api/item/$scheduleNo").then((response) {
        if(response.statusCode! >= 200 && response.statusCode! < 300){
          Map<String, dynamic> responseMap = response.data ?? {};
          Map<String, dynamic> itemsMap = responseMap['data'] ?? {};
          dynamic item = itemsMap['item'];
          return ScheduleModel.fromJson(item);
        }
        else {
          return Future(() => null);
        }
      });
    } catch(e){
      print("에러 : ${e.toString()}");
      throw Exception(e);
    }
  }

  Future<ResponseModel> postSchedule(ScheduleModel scheduleModel){
    try {
      return dio.post(
          "${ApiValues.requestUrl}/schedule/api/item",
          queryParameters: scheduleModel.toJson()
      ).then((response) {
        Map<String, dynamic> responseMap = response.data;
        return ResponseModel(
            timestamp: responseMap['timestamp'],
            status: response.statusCode,
            message: responseMap['message'],
        );
      });
    }
    catch(e){
      print("에러 : ${e.toString()}");
      throw Exception();
    }
  }

  Future<ResponseModel> patchSchedule(ScheduleModel scheduleModel){
    try {
      return dio.patch(
          "${ApiValues.requestUrl}/schedule/api/item",
          queryParameters: scheduleModel.toJson(),
      ).then((response) {
        Map<String, dynamic> responseMap = response.data;
        return ResponseModel(
          timestamp: responseMap['timestamp'],
          status: response.statusCode,
          message: responseMap['message'],
        );
      });
    }
    catch(e){
      print("에러 : ${e.toString()}");
      throw Exception();
    }
  }

  Future<ResponseModel> patchScheduleFinish(int scheduleNo, String endTime){
    try {
      return dio.patch(
        "${ApiValues.requestUrl}/schedule/api/finish",
        queryParameters: {
          'scheduleNo': scheduleNo,
          'endTime' : endTime
        },
      ).then((response) {
        Map<String, dynamic> responseMap = response.data;
        return ResponseModel(
          timestamp: responseMap['timestamp'],
          status: response.statusCode,
          message: responseMap['message'],
        );
      });
    }
    catch(e){
      print("에러 : ${e.toString()}");
      throw Exception();
    }
  }

  Future<ResponseModel> deleteSchedule(int scheduleNo){
    try {
      return dio.delete(
        "${ApiValues.requestUrl}/schedule/api/item/$scheduleNo",
      ).then((response) {
        Map<String, dynamic> responseMap = response.data;
        return ResponseModel(
          timestamp: responseMap['timestamp'],
          status: response.statusCode,
          message: responseMap['message'],
        );
      });
    }
    catch(e){
      print("에러 : ${e.toString()}");
      throw Exception();
    }
  }

  Future<List<ScheduleModel>> fetchAfterSchedules(PaginationFilter filter, List<String> searchScheduleTypes, String searchStartDate) {
    try {
      return dio.get(
          "${ApiValues.requestUrl}/schedule/api/items",
          queryParameters: {
            'searchScheduleTypes': searchScheduleTypes,
            'searchStartDate': searchStartDate,
            'currentPage': filter.page,
            'pageSize': filter.limit
          }
      ).then((response) {
        switch(response.statusCode){
          case 200:
            Map<String, dynamic> responseMap = response.data;
            Map<String, dynamic> itemsMap = responseMap['data'];
            List<dynamic> items = itemsMap['items'];
            return items.map((e) => ScheduleModel.fromJson(e)).toList();
          default:
            return [];
        }
      });
    } catch (e) {
      print("에러 : ${e.toString()}");
      throw Exception();
    }
  }

  Future<List<ScheduleModel>> fetchMonthSchedules(String searchYearMonth) {
    try {
      return dio.get(
          "${ApiValues.requestUrl}/schedule/api/month/items",
          queryParameters: {
            'searchYearMonth': searchYearMonth,
          }
      ).then((response) {
        switch(response.statusCode){
          case 200:
            Map<String, dynamic> responseMap = response.data;
            Map<String, dynamic> itemsMap = responseMap['data'];
            List<dynamic> items = itemsMap['items'];
            return items.map((e) => ScheduleModel.fromJson(e)).toList();
          default:
            return [];
        }
      });
    } catch (e) {
      print("에러 : ${e.toString()}");
      throw Exception();
    }
  }

}