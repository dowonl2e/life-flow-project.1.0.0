import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mylifeflow_app/common/enum/schedule_enum.dart';
import 'package:mylifeflow_app/common/enum/schedule_state.dart';

ScheduleModel fromJson(String str) => ScheduleModel.fromJson(json.decode(str));

String postToJson(ScheduleModel data) => json.encode(data.toJson());

class ScheduleModel {
  ScheduleModel({
    required this.scheduleIconData,
    required this.scheduleNo,
    required this.scheduleType,
    required this.scheduleTypeName,
    required this.userEmail,
    required this.startDate,
    required this.endDate,
    required this.scheduleTitleColor,
    required this.scheduleState,
    required this.scheduleStateName,
    required this.scheduleDesc,
  });

  ScheduleModel.init();

  IconData? scheduleIconData = Icons.circle_outlined;
  int scheduleNo = -1;
  String scheduleType = ScheduleEnum.empty.code;
  String? scheduleTypeName = ScheduleEnum.empty.name;
  String? userEmail = "";
  String startDate = "";
  String? endDate = "";
  Color? scheduleTitleColor = Colors.black;
  String scheduleState = ScheduleStateEnum.none.code;
  String scheduleStateName = ScheduleStateEnum.none.name;
  String? scheduleDesc = "";

  factory ScheduleModel.fromJson(Map<String, dynamic>? json) => ScheduleModel(
    scheduleIconData: json?["iconData"] ?? Icons.circle_outlined,
    scheduleNo: json?["scheduleNo"] ?? -1,
    scheduleType: json?["scheduleType"] ?? "",
    scheduleTypeName: json?["scheduleTypeName"] ?? "",
    userEmail: json?["userEmail"] ?? "",
    startDate: json?["startDate"] ?? "",
    endDate: json?["endDate"] ?? "",
    scheduleTitleColor: json?["scheduleTitleColor"] ?? Colors.black,
    scheduleState: json?["scheduleState"] ?? "",
    scheduleStateName: json?["scheduleStateName"] ?? "",
    scheduleDesc: json?["scheduleDesc"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "scheduleNo": scheduleNo,
    "scheduleType": scheduleType,
    "scheduleTypeName": scheduleTypeName,
    "userEmail": userEmail,
    "startDate": startDate,
    "endDate": endDate,
    "scheduleDesc": scheduleDesc,
  };

  @override
  String toString() {
    return 'ScheduleModel{scheduleNo: $scheduleNo, scheduleType: $scheduleType, scheduleTypeName: $scheduleTypeName, userEmail: $userEmail, startDate: $startDate, endDate: $endDate, scheduleDesc: $scheduleDesc}';
  }

}