import 'dart:convert';

StatisticsModel fromJson(String str) => StatisticsModel.fromJson(json.decode(str));

class StatisticsModel {
  StatisticsModel({
    required this.scheduleMonth,
    required this.scheduleType,
    required this.scheduleTypeCount,
  });

  StatisticsModel.init();

  int scheduleMonth = 0;
  String scheduleType = "";
  int scheduleTypeCount = 0;

  factory StatisticsModel.fromJson(Map<String, dynamic>? json) => StatisticsModel(
    scheduleMonth: json?["scheduleMonth"] ?? -1,
    scheduleType: json?["scheduleType"] ?? "",
    scheduleTypeCount: json?["scheduleTypeCount"] ?? 0,
  );

  @override
  String toString() {
    return 'StatisticsModel{scheduleMonth: $scheduleMonth, scheduleType: $scheduleType, scheduleTypeCount: $scheduleTypeCount}';
  }
}