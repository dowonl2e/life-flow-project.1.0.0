import 'package:flutter/material.dart';

enum ScheduleEnum {
  empty('EMPTY', '',  Icons.circle_outlined),
  study("STUDY", '스터디', Icons.note),
  appointment("APPOINTMENT", '약속', Icons.lock_clock),
  project("PROJECT", '프로젝트', Icons.document_scanner),
  health("HEALTH", '운동', Icons.health_and_safety),
  travel("TRAVEL", '여행', Icons.travel_explore),
  etc("ETC", '기타', Icons.travel_explore);

  const ScheduleEnum(this.code, this.name, this.displayIcon);
  final String code;
  final String name;
  final IconData displayIcon;

  factory ScheduleEnum.getByCode(String code){
    return ScheduleEnum.values.firstWhere((value) => value.code == code,
        orElse: () => ScheduleEnum.empty);
  }
}