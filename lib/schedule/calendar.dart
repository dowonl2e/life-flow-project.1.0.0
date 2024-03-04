import 'package:auto_route/annotations.dart';
import 'package:day_night_time_picker/lib/constants.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylifeflow_app/schedule/repository/schedule_repository.dart';
import 'package:table_calendar/table_calendar.dart';

import '../common/common_toast.dart';
import '../common/enum/schedule_enum.dart';
import 'model/schedulemodel.dart';

@RoutePage()
class CalenderSchedulePage extends StatefulWidget {
  const CalenderSchedulePage({super.key});

  @override
  State<CalenderSchedulePage> createState() => _CalenderSchedulePageState();
}

class _CalenderSchedulePageState extends State<CalenderSchedulePage> {
  final scheduleRepository = ScheduleRepository();
  Map<DateTime, List<ScheduleModel>> _scheduleMap = {};
  List<ScheduleModel> _schedules = [];
  List<ScheduleModel> _selectedSchedules = [];
  bool _isLoading = false, _isCalendarLoading = false;
  ScheduleModel _schedule = ScheduleModel.init();

  DateTime _selectedDay = DateTime.now(), _today = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<ScheduleEnum> _schedulesTypeEnums = ScheduleEnum.values;

  BuildContext? dialogContext;

  late TextEditingController typeTextEditController;
  late TextEditingController startDateTextEditController;
  late TextEditingController startTimeTextEditController;
  late TextEditingController endDateTextEditController;
  late TextEditingController endTimeTextEditController;
  late TextEditingController descTextEditController;

  List<ScheduleModel> _getSchedulesForDay(DateTime day) {
    return _scheduleMap[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _calendarMonthSchedulesLoad();
  }

  Future _calendarMonthSchedulesLoad() async {
    setState(() {
      _isCalendarLoading = true;
    });

    try {
      final scheduleModels = await scheduleRepository.fetchMonthSchedules(
          DateFormat('yyyy-MM-dd').format(_selectedDay));
      for (var item in scheduleModels) {
        item.scheduleIconData = ScheduleEnum
            .getByCode(item.scheduleType)
            .displayIcon;
      }
      _schedules = scheduleModels;

      DateTime monthFirstDate = DateTime(
          _selectedDay.year, _selectedDay.month, 1);
      DateTime monthLastDate = DateTime(
          _selectedDay.year, _selectedDay.month + 1, 0);
      final differenceDay = monthLastDate.difference(monthFirstDate);
      for (int i = 0; i <= differenceDay.inDays; i++) {
        DateTime calendarDate = monthFirstDate.add(Duration(days: i));
        List<ScheduleModel> items = [];
        for (var schedule in _schedules) {
          DateTime scheduleStart = DateTime.parse(schedule.startDate);
          if (isSameDay(calendarDate, scheduleStart)) {
            items.add(schedule);
          }
        }
        _scheduleMap[calendarDate] = items;
        items = [];
      }
      _selectedSchedules = _scheduleMap[DateTime(
          _selectedDay.year, _selectedDay.month, _selectedDay.day)]!;
    } on DioException catch(e){
      if(e.type == DioExceptionType.connectionError){
        showResponseToast("네트워크 연결에 실패했습니다.");
      }
      else if(e.type == DioExceptionType.connectionTimeout){
        showResponseToast("요청이 지연되었습니다.");
      }
      else if(e.type == DioExceptionType.receiveTimeout){
        showResponseToast("응답이 지연되었습니다.");
      }
      else {
        showResponseToast("요청에 실패했습니다.");
      }
    }

    setState(() {
      _isCalendarLoading = false;
    });
  }

  void _refreshDaySchedules(){
    setState(() {
      _selectedSchedules.add(_schedule);
      _selectedSchedules.sort((a, b) => DateTime.parse(b.startDate).compareTo(DateTime.parse(a.startDate)));
      _scheduleMap[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] = _selectedSchedules;
    });
  }

  void removeScheduleAt(int index){
    setState(() {
      _selectedSchedules.removeAt(index);
      _scheduleMap[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] = _selectedSchedules;
    });
  }

  void dismissDialog(){
    if(dialogContext != null){
      Navigator.pop(dialogContext!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _calendarMonthSchedulesLoad,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
              child: TableCalendar(
                focusedDay: _selectedDay,
                firstDay: DateTime(2023, 1, 1),
                lastDay: DateTime(DateTime.now().year+2, 1, 0),
                calendarFormat: _calendarFormat,
                rangeSelectionMode: RangeSelectionMode.toggledOff,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                pageJumpingEnabled: true,
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _selectedSchedules = _getSchedulesForDay(selectedDay);
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _selectedDay = (
                        _today.year == focusedDay.year
                            && _today.month == focusedDay.month
                    ) ? _today : focusedDay;
                  });
                  _calendarMonthSchedulesLoad();
                },
                pageAnimationEnabled: true,
                eventLoader: (day) {
                  return _getSchedulesForDay(day);
                },
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    if (day.weekday == DateTime.sunday) {
                      final text = DateFormat.E().format(day);
                      return Center(
                        child: Text(
                          text,
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    else if (day.weekday == DateTime.saturday){
                      final text = DateFormat.E().format(day);
                      return Center(
                        child: Text(
                          text,
                          style: TextStyle(color: Colors.blue),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              ): Stack(
                children: [
                  ListView.builder(
                    itemCount: _selectedSchedules.length,
                    itemBuilder: (context, index) =>
                      Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10
                        ),
                        child: ListTile(
                          leading: Icon(_selectedSchedules[index].scheduleIconData),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedSchedules[index].scheduleTypeName.toString(),
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5
                                ),
                                child: Text(
                                  _selectedSchedules[index].startDate.substring(0, 16)
                                      .toString(),
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            ],
                          ),
                          subtitle: Text(
                            _schedules[index].scheduleDesc.toString()),
                          onTap: () {
                            _showScheduleDialog(false, context, index);
                          },
                        )
                      )
                  ),
                  Positioned(
                      bottom: 30,
                      right: 30,
                      child: IconButton.filled(
                          onPressed: (){
                            _showScheduleDialog(true, context, null);
                          },
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.blueAccent
                          ),
                          icon: Icon(
                            Icons.add_circle_outline,
                          )
                      )
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScheduleDialog(bool insertable, BuildContext ctx, int? index) {
    switch (insertable) {
      case true:
        _showScheduleAddDialog(ctx);
        break;
      case false:
        _showScheduleModifyDialog(ctx, index!);
        break;
    }
  }

  void _showScheduleAddDialog(BuildContext ctx) {
    try {
      _schedule = ScheduleModel.init();
      typeTextEditController = TextEditingController(text: "");
      String selectedDayStr = DateFormat('yyyy-MM-dd').format(DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));
      String today = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      startDateTextEditController =
          TextEditingController(text: selectedDayStr);
      startTimeTextEditController =
          TextEditingController(text: today.substring(11, 16));
      endDateTextEditController = TextEditingController(text: "");
      endTimeTextEditController = TextEditingController(text: "");
      descTextEditController = TextEditingController(text: "");

      Time startTime = Time(hour: int.parse(today.substring(11, 13)),
          minute: int.parse(today.substring(14, 16)));
      Time endTime = Time(hour: 00, minute: 00);

      showDialog(
          context: ctx,
          useSafeArea: true,
          builder: (ctx) {
            dialogContext = ctx;
            final dialogWidth = MediaQuery
                .of(ctx)
                .size
                .width * 0.8;
            final dialogHeight = MediaQuery
                .of(ctx)
                .size
                .height * 0.7;
            return Dialog(
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        spacing: 2.5,
                        // 좌우 간격
                        runSpacing: 2.5,
                        // 상하 간격
                        children: [
                          for(var scheduleEnum in _schedulesTypeEnums)
                            if(scheduleEnum.code != 'EMPTY')
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 2.5, right: 2.5
                                ),
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() {
                                        _schedule.scheduleType =
                                            scheduleEnum.code;
                                        _schedule.scheduleTypeName =
                                            scheduleEnum.name;
                                        typeTextEditController.text =
                                            scheduleEnum.name;
                                      }),
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(color: Colors.blueAccent)
                                  ),
                                  child: Text(
                                      '#${scheduleEnum.name}',
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ),
                              ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 20, right: 2.5, bottom: 10
                          ),
                          child: TextField(
                            controller: typeTextEditController,
                            showCursor: false,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 2, color: Colors.blueAccent),
                              ),
                              labelText: '일정',
                              hintText: '일정을 입력해주세요.',
                            ),
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 10, right: 2.5, bottom: 10
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: dialogWidth * 0.55 - 37.5,
                                child: TextField(
                                  controller: startDateTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        startDateTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '시작일',
                                    hintText: '시작일을 선택해주세요.',
                                  ),
                                  onTap: () async {
                                    final DateTime? dateTime = await showDatePicker(
                                        context: ctx,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(3000)
                                    );
                                    if (dateTime != null) {
                                      String formattedDate = DateFormat(
                                          'yyyy-MM-dd').format(dateTime);
                                      setState(() {
                                        startDateTextEditController.text =
                                            formattedDate;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20,),
                              SizedBox(
                                width: dialogWidth * 0.45 - 37.5,
                                child: TextField(
                                  controller: startTimeTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        startTimeTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '시작시간',
                                    hintText: '시작시간을 선택해주세요.',
                                  ),
                                  onTap: () {
                                    Navigator.of(dialogContext!).push(
                                      showPicker(
                                        showSecondSelector: false,
                                        context: ctx,
                                        value: startTime,
                                        onChange: (Time newTime) {
                                          setState(() {
                                            startTime = Time(hour: newTime.hour,
                                                minute: newTime.minute);
                                            String startHour = startTime.hour < 10
                                                ? "0${startTime.hour}"
                                                : "${startTime.hour}";
                                            String startMinute = startTime
                                                .minute < 10 ? "0${startTime
                                                .minute}" : "${startTime.minute}";
                                            startTimeTextEditController.text =
                                            "$startHour:$startMinute";
                                          });
                                        },
                                        is24HrFormat: true,
                                        minuteInterval: TimePickerInterval.ONE,
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 10, right: 2.5, bottom: 10
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: dialogWidth * 0.55 - 37.5,
                                child: TextField(
                                  controller: endDateTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        endDateTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '종료일',
                                    hintText: '종료일을 선택해주세요.',
                                  ),
                                  onTap: () async {
                                    final DateTime? dateTime = await showDatePicker(
                                        context: ctx,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(3000)
                                    );
                                    if (dateTime != null) {
                                      String formattedDate = DateFormat(
                                          'yyyy-MM-dd').format(dateTime);
                                      setState(() {
                                        endDateTextEditController.text =
                                            formattedDate;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20,),
                              SizedBox(
                                width: dialogWidth * 0.45 - 37.5,
                                child: TextField(
                                  controller: endTimeTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        endTimeTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '종료시간',
                                    hintText: '종료시간을 선택해주세요.',
                                  ),
                                  onTap: () async {
                                    Navigator.of(dialogContext!).push(
                                      showPicker(
                                        showSecondSelector: false,
                                        context: ctx,
                                        value: endTime,
                                        onChange: (Time newTime) {
                                          setState(() {
                                            endTime = Time(hour: newTime.hour,
                                                minute: newTime.minute);
                                            String endHour = endTime.hour < 10
                                                ? "0${endTime.hour}"
                                                : "${endTime.hour}";
                                            String endMinute = endTime.minute < 10
                                                ? "0${endTime.minute}"
                                                : "${endTime.minute}";
                                            endTimeTextEditController.text =
                                            "$endHour:$endMinute";
                                          });
                                        },
                                        is24HrFormat: true,
                                        minuteInterval: TimePickerInterval.ONE,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 10, right: 2.5, bottom: 10
                          ),
                          child: TextField(
                            controller: descTextEditController,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 2, color: Colors.blueAccent),
                              ),
                              labelText: '상세내용',
                              hintText: '상세내용을 입력해주세요.',
                            ),
                          )
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () async {
                                if (typeTextEditController.text.isEmpty) {
                                  showValidToast("일정 정보를 선택해주세요.");
                                }
                                else
                                if (startDateTextEditController.text.isEmpty) {
                                  showValidToast("일정 시작일을 선택해주세요.");
                                }
                                else {
                                  _schedule.startDate =
                                  "${startDateTextEditController
                                      .text} ${startTimeTextEditController.text}";
                                  String scheduleEndDate = endDateTextEditController
                                      .text;
                                  if (scheduleEndDate.isNotEmpty) {
                                    scheduleEndDate +=
                                    " ${endTimeTextEditController.text}";
                                  }
                                  _schedule.endDate = scheduleEndDate;
                                  _schedule.scheduleDesc =
                                      descTextEditController.text;
                                  final response = await scheduleRepository
                                      .postSchedule(_schedule);
                                  showValidToast(response.message.toString());
                                  switch (response.status) {
                                    case 201:
                                      dismissDialog();
                                      _schedule.scheduleIconData = ScheduleEnum.getByCode(_schedule.scheduleType).displayIcon;
                                      _refreshDaySchedules();
                                      break;
                                    default:
                                      break;
                                  }
                                }
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blueAccent
                              ),
                              child: Text(
                                "등록",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 5, right: 5)
                            ),
                            FilledButton(
                              onPressed: () {
                                dismissDialog();
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black54
                              ),
                              child: Text(
                                "취소",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      );
    } on DioException catch(e){
      if(e.type == DioExceptionType.connectionError){
        showResponseToast("연결에 실패했습니다.");
      }
      else if(e.type == DioExceptionType.connectionTimeout){
        showResponseToast("요청이 지연되었습니다.");
      }
      else if(e.type == DioExceptionType.receiveTimeout){
        showResponseToast("응답이 지연되었습니다.");
      }
      else {
        showResponseToast("요청에 실패했습니다.");
      }
    }
  }

  void _showScheduleModifyDialog(BuildContext ctx, int index) async {
    try {
      _schedule = (await scheduleRepository.fetchSchedule(_schedules[index].scheduleNo))!;
      if (_schedule.scheduleNo == -1) {
        showResponseToast("일정 정보가 없습니다.");
        removeScheduleAt(index);
        return;
      }

      String? startDateTime = _schedule.startDate, endDateTime = _schedule.endDate;

      typeTextEditController = TextEditingController(text: _schedule.scheduleTypeName.toString());
      String startDateStr = startDateTime.toString().length < 10 ? "" : startDateTime.toString().substring(0,10);
      startDateTextEditController = TextEditingController(text: startDateStr);
      String startTimeStr = startDateTime.toString().length < 16 ? "" : startDateTime.toString().substring(11,16);
      startTimeTextEditController = TextEditingController(text: startTimeStr);
      String? endDateStr = endDateTime == null || endDateTime.toString().length < 10 ? "" : endDateTime.toString().substring(0,10);
      endDateTextEditController = TextEditingController(text: endDateStr);
      String? endTimeStr = endDateTime == null || endDateTime.toString().length < 16 ? "" : endDateTime.toString().substring(11,16);
      endTimeTextEditController = TextEditingController(text: endTimeStr);
      descTextEditController = TextEditingController(text: _schedule.scheduleDesc.toString());

      String? startHour = startTimeStr == "" ? "00" : startTimeStr.substring(0,2);
      String? startMinute = startTimeStr == "" ? "00" : startTimeStr.substring(3,5);
      String? endHour = endTimeStr == "" ? "00" : endTimeStr.substring(0,2);
      String? endMinute = endTimeStr == "" ? "00" : endTimeStr.substring(3,5);

      Time startTime = Time(hour: int.parse(startHour), minute: int.parse(startMinute));
      Time endTime = Time(hour: int.parse(endHour), minute: int.parse(endMinute));

      if(ctx.mounted) {
        showDialog(
          context: ctx,
          useSafeArea: true,
          builder: (ctx) {
            dialogContext = ctx;
            final dialogWidth = MediaQuery
                .of(ctx)
                .size
                .width * 0.8;
            final dialogHeight = MediaQuery
                .of(ctx)
                .size
                .height * 0.7;
            return Dialog(
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                alignment: Alignment.topLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        spacing: 2.5,
                        // 좌우 간격
                        runSpacing: 2.5,
                        // 상하 간격
                        children: [
                          for(var scheduleEnum in _schedulesTypeEnums)
                            if(scheduleEnum.code != 'EMPTY')
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 2.5, right: 2.5
                                ),
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() {
                                        _schedule.scheduleType = scheduleEnum.code;
                                        _schedule.scheduleTypeName =
                                            scheduleEnum.name;
                                        typeTextEditController.text =
                                            scheduleEnum.name;
                                      }),
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: _schedule.scheduleType == scheduleEnum.code ? Colors.blueAccent : Colors.white,
                                      side: BorderSide(
                                          color: Colors.blueAccent
                                      )
                                  ),
                                  child: Text(
                                      '#${scheduleEnum.name}',
                                      style: TextStyle(
                                          color: _schedule.scheduleType == scheduleEnum.code ? Colors.white : Colors.blueAccent,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ),
                              ),
                        ],
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 20, right: 2.5, bottom: 10
                          ),
                          child: TextField(
                            controller: typeTextEditController,
                            showCursor: false,
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 2, color: Colors.blueAccent),
                              ),
                              labelText: '일정',
                              hintText: '일정을 입력해주세요.',
                            ),
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 10, right: 2.5, bottom: 10
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: dialogWidth*0.55-37.5,
                                child: TextField(
                                  controller: startDateTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        startDateTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '시작일',
                                    hintText: '시작일을 선택해주세요.',
                                  ),
                                  onTap: () async {
                                    final DateTime? dateTime = await showDatePicker(
                                        context: ctx,
                                        initialDate: DateTime.parse(startDateStr),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(3000)
                                    );
                                    if (dateTime != null) {
                                      String formattedDate = DateFormat('yyyy-MM-dd')
                                          .format(dateTime);
                                      setState(() {
                                        startDateTextEditController.text = formattedDate;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20,),
                              SizedBox(
                                width: dialogWidth*0.45-37.5,
                                child: TextField(
                                  controller: startTimeTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration:InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        startTimeTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '시작시간',
                                    hintText: '시작시간을 선택해주세요.',
                                  ),
                                  onTap: () {
                                    Navigator.of(dialogContext!).push(
                                      showPicker(
                                        showSecondSelector: false,
                                        context: ctx,
                                        value: startTime,
                                        onChange: (Time newTime){
                                          setState(() {
                                            startTime = Time(hour: newTime.hour, minute: newTime.minute);
                                            String startHour = startTime.hour < 10 ? "0${startTime.hour}" : "${startTime.hour}";
                                            String startMinute = startTime.minute < 10 ? "0${startTime.minute}" : "${startTime.minute}";
                                            startTimeTextEditController.text = "$startHour:$startMinute";
                                          });
                                        },
                                        is24HrFormat: true,
                                        minuteInterval: TimePickerInterval.ONE,
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 10, right: 2.5, bottom: 10
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: dialogWidth*0.55-37.5,
                                child: TextField(
                                  controller: endDateTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      borderSide: BorderSide(
                                          width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        endDateTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '종료일',
                                    hintText: '종료일을 선택해주세요.',
                                  ),
                                  onTap: () async {
                                    final DateTime? dateTime = await showDatePicker(
                                        context: ctx,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(3000)
                                    );
                                    if (dateTime != null) {
                                      String formattedDate = DateFormat('yyyy-MM-dd')
                                          .format(dateTime);
                                      setState(() {
                                        endDateTextEditController.text = formattedDate;
                                      });
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20,),
                              SizedBox(
                                width: dialogWidth*0.45-37.5,
                                child: TextField(
                                  controller: endTimeTextEditController,
                                  showCursor: false,
                                  readOnly: true,
                                  decoration:InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(width: 1, color: Colors.blueAccent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      borderSide: BorderSide(width: 2, color: Colors.blueAccent),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: (){
                                        endTimeTextEditController.text = "";
                                      },
                                      icon: Icon(Icons.clear),
                                    ),
                                    labelText: '종료시간',
                                    hintText: '종료시간을 선택해주세요.',
                                  ),
                                  onTap: () async {
                                    Navigator.of(dialogContext!).push(
                                      showPicker(
                                        showSecondSelector: false,
                                        context: ctx,
                                        value: endTime,
                                        onChange: (Time newTime){
                                          setState(() {
                                            endTime = Time(hour: newTime.hour, minute: newTime.minute);
                                            String endHour = endTime.hour < 10 ? "0${endTime.hour}" : "${endTime.hour}";
                                            String endMinute = endTime.minute < 10 ? "0${endTime.minute}" : "${endTime.minute}";
                                            endTimeTextEditController.text = "$endHour:$endMinute";
                                          });
                                        },
                                        is24HrFormat: true,
                                        minuteInterval: TimePickerInterval.ONE,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              left: 2.5, top: 10, right: 2.5, bottom: 10
                          ),
                          child: TextField(
                            controller: descTextEditController,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 1, color: Colors.blueAccent),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(8.0)),
                                borderSide: BorderSide(
                                    width: 2, color: Colors.blueAccent),
                              ),
                              labelText: '상세내용',
                              hintText: '상세내용을 입력해주세요.',
                            ),
                          )
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              onPressed: () async {
                                if(typeTextEditController.text.isEmpty){
                                  showValidToast("일정 정보를 선택해주세요.");
                                }
                                else if(startDateTextEditController.text.isEmpty){
                                  showValidToast("일정 시작일을 선택해주세요.");
                                }
                                else {
                                  _schedule.startDate = "${startDateTextEditController.text} ${startTimeTextEditController.text}";
                                  String scheduleEndDate = endDateTextEditController.text;
                                  if(scheduleEndDate.isNotEmpty){
                                    scheduleEndDate += " ${endTimeTextEditController.text}";
                                  }
                                  _schedule.endDate = scheduleEndDate;
                                  _schedule.scheduleDesc =
                                      descTextEditController.text;
                                  final response = await scheduleRepository
                                      .patchSchedule(_schedule);
                                  showResponseToast(response.message.toString());
                                  switch (response.status) {
                                    case 201:
                                      setState(() {
                                        _schedules[index].scheduleIconData = ScheduleEnum.getByCode(_schedule.scheduleType).displayIcon;
                                        _schedules[index].scheduleType = _schedule.scheduleType;
                                        _schedules[index].scheduleTypeName = _schedule.scheduleTypeName;
                                        _schedules[index].startDate = _schedule.startDate;
                                        _schedules[index].endDate = _schedule.endDate;
                                        _schedules[index].scheduleDesc = _schedule.scheduleDesc;
                                      });
                                      dismissDialog();
                                      break;
                                    default:
                                      break;
                                  }
                                }
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blueAccent
                              ),
                              child: Text(
                                "수정",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 5, right: 5
                                )
                            ),
                            FilledButton(
                              onPressed: () => showDialog<String>(
                                context: context,
                                builder: (BuildContext alertContext) => AlertDialog(
                                  title: const Text('일정 삭제'),
                                  content: const Text('삭제하시겠습니까?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.pop(alertContext, '아니오'),
                                      child: const Text('아니오'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          final response = await scheduleRepository
                                              .deleteSchedule(
                                              _schedules[index].scheduleNo);
                                          showResponseToast(
                                              response.message.toString());
                                          if (alertContext.mounted) {
                                            switch (response.status) {
                                              case 201:
                                                dismissDialog();
                                                Navigator.pop(
                                                    alertContext, '예');
                                                _calendarMonthSchedulesLoad();
                                                break;
                                              default:
                                                break;
                                            }
                                          }
                                        } on DioException catch(e){
                                          if(e.type == DioExceptionType.connectionError){
                                            showResponseToast("연결에 실패했습니다.");
                                          }
                                          else if(e.type == DioExceptionType.connectionTimeout){
                                            showResponseToast("요청이 지연되었습니다.");
                                          }
                                          else if(e.type == DioExceptionType.receiveTimeout){
                                            showResponseToast("응답이 지연되었습니다.");
                                          }
                                          else {
                                            showResponseToast("요청에 실패했습니다.");
                                          }
                                        }
                                      },
                                      child: const Text('예'),
                                    ),
                                  ],
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.redAccent
                              ),
                              child: Text(
                                "삭제",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 5, right: 5
                                )
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(dialogContext!);
                              },
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.black54
                              ),
                              child: Text(
                                "취소",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    } on DioException catch(e){
      if(e.type == DioExceptionType.connectionError){
        showResponseToast("연결에 실패했습니다.");
      }
      else if(e.type == DioExceptionType.connectionTimeout){
        showResponseToast("요청이 지연되었습니다.");
      }
      else if(e.type == DioExceptionType.receiveTimeout){
        showResponseToast("응답이 지연되었습니다.");
      }
      else {
        showResponseToast("요청에 실패했습니다.");
      }
    }
  }
}