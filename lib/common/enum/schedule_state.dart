import 'package:flutter/material.dart';

enum ScheduleStateEnum {
  none('NONE', '', Colors.black),
  wait('WAIT', '대기', Colors.black),
  progress('PROGRESS', '진행중', Colors.blueAccent),
  over('OVER', '종료', Colors.redAccent);

  const ScheduleStateEnum(this.code, this.name, this.color);
  final String code;
  final String name;
  final Color color;

  factory ScheduleStateEnum.getByCode(String code){
    return ScheduleStateEnum.values.firstWhere((value) => value.code == code,
        orElse: () => ScheduleStateEnum.none);
  }

}