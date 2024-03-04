import 'package:auto_route/annotations.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylifeflow_app/common/common_toast.dart';
import 'package:mylifeflow_app/common/enum/schedule_enum.dart';
import 'package:mylifeflow_app/common/enum/schedule_state.dart';
import 'package:mylifeflow_app/common/filter/pagination_filter.dart';
import 'package:mylifeflow_app/schedule/repository/schedule_repository.dart';

import 'model/schedulemodel.dart';

@RoutePage()
class CurrentSchedulePage extends StatefulWidget {
  const CurrentSchedulePage({super.key});

  @override
  State<CurrentSchedulePage> createState() => _CurrentSchedulePageState();
}

class _CurrentSchedulePageState extends State<CurrentSchedulePage> {
  late ScrollController _scrollController;

  final scheduleRepository = ScheduleRepository();
  late PaginationFilter paginationFilter;

  bool _isFirstLoading = false, _isLoadMoreLoading = false;
  List<String> _searchScheduleTypes = [];

  List<ScheduleModel> _schedules = [];
  late ScheduleModel _schedule = ScheduleModel.init();

  List<ScheduleEnum> _schedulesTypeEnums = ScheduleEnum.values;

  BuildContext? dialogContext;

  late TextEditingController typeTextEditController;
  late TextEditingController startDateTextEditController;
  late TextEditingController startTimeTextEditController;
  late TextEditingController endDateTextEditController;
  late TextEditingController endTimeTextEditController;
  late TextEditingController descTextEditController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_nextLoad);
    _initLoad();
  }

  Future _initLoad() async {
    setState(() {
      _isFirstLoading = true;
    });

    try {
      paginationFilter = PaginationFilter(page: 1);
      final scheduleModels = await scheduleRepository.fetchCurrentSchedules(
          paginationFilter, _searchScheduleTypes
      );
      if (scheduleModels.isEmpty) {
        paginationFilter.hasNext = false;
      }
      arrangeMaterialData(scheduleModels);
      _schedules = scheduleModels;
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

    setState(() {
      _isFirstLoading = false;
    });
  }

  void _nextLoad() async {
    if (paginationFilter.hasNext
        && !_isFirstLoading
        && !_isLoadMoreLoading
        && _scrollController.position.extentAfter < 100
    ) {
      setState(() {
        _isLoadMoreLoading = true;
      });

      try {
        paginationFilter.page += 1;
        final scheduleModels = await scheduleRepository.fetchCurrentSchedules(
            paginationFilter, _searchScheduleTypes
        );
        if (scheduleModels.isEmpty) {
          paginationFilter.hasNext = false;
        }
        else {
          setState(() {
            arrangeMaterialData(scheduleModels);
            _schedules.addAll(scheduleModels);
          });
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

      setState(() {
        _isLoadMoreLoading = false;
      });
    }
  }

  void arrangeMaterialData(List<ScheduleModel> items) {
    for (var item in items) {
      item.scheduleIconData = ScheduleEnum
          .getByCode(item.scheduleType)
          .displayIcon;
      item.scheduleTitleColor = ScheduleStateEnum
          .getByCode(item.scheduleState)
          .color;
    }
  }

  void _toggleSearch(String type) {
    if (_searchScheduleTypes.isEmpty
        || !_searchScheduleTypes.contains(type)
    ) {
      _searchScheduleTypes.add(type);
    }
    else {
      _searchScheduleTypes.removeWhere((element) =>
        element == type
      );
    }
  }

  void _arrangeSchedule(int index){
    setState(() {
      _schedules[index].scheduleIconData = ScheduleEnum.getByCode(_schedule.scheduleType).displayIcon;
      _schedules[index].scheduleType = _schedule.scheduleType;
      _schedules[index].scheduleTypeName = _schedule.scheduleTypeName;
      _schedules[index].startDate = _schedule.startDate;
      _schedules[index].endDate = _schedule.endDate;
      _schedules[index].scheduleDesc = _schedule.scheduleDesc;

      String scheduleState = ScheduleStateEnum.none.code;
      String scheduleStateName = ScheduleStateEnum.none.name;

      DateTime startDate = DateTime.parse(_schedule.startDate);
      DateTime now = DateTime.now();

      bool isWait = startDate.isAfter(now);
      if(isWait){
        scheduleState = ScheduleStateEnum.wait.code;
        scheduleStateName = ScheduleStateEnum.wait.name;
      }
      else {
        if (_schedule.endDate == null || _schedule.endDate == '') {
          scheduleState = ScheduleStateEnum.progress.code;
          scheduleStateName = ScheduleStateEnum.progress.name;
        }
        else {
          DateTime endDate = DateTime.parse(_schedule.endDate!);
          bool isOver = endDate.isBefore(now);
          if(isOver){
            scheduleState = ScheduleStateEnum.over.code;
            scheduleStateName = ScheduleStateEnum.over.name;
          }
          else {
            scheduleState = ScheduleStateEnum.progress.code;
            scheduleStateName = ScheduleStateEnum.progress.name;
          }
        }
      }
      _schedules[index].scheduleState = scheduleState;
      _schedules[index].scheduleStateName = scheduleStateName;
    });
  }

  void removeScheduleAt(int index){
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void dismissDialog(){
    if(dialogContext != null){
      Navigator.pop(dialogContext!);
    }
  }

  void _finishSchedule(int index) {
    showDialog<String>(
      context: context,
      builder: (BuildContext alertContext) => AlertDialog(
        title: const Text('일정 종료'),
        content: const Text('종료하시겠습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(alertContext, '아니오'),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () async {
              try {
                int scheduleNo = _schedules[index].scheduleNo;
                String endTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
                final response = await scheduleRepository.patchScheduleFinish(scheduleNo, endTime);
                showResponseToast(response.message.toString());
                switch (response.status) {
                  case 201:
                    setState(() {
                      _schedules[index].scheduleState = ScheduleStateEnum.over.code;
                      _schedules[index].scheduleStateName = ScheduleStateEnum.over.name;
                      _schedules[index].endDate = endTime;
                      Navigator.pop(alertContext, '예');
                    });
                    break;
                  default:
                    break;
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
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_nextLoad);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final headHeight = height*0.07;
    final childHeight = height - headHeight - 94;
    return SafeArea(
      child: _isFirstLoading
          ? const Center(
        child: CircularProgressIndicator()
      )
          : Column(
        children: [
          Container(
            height: headHeight,
            padding: const EdgeInsets.all(5),
            child: _searchHeadBar(),
          ),
          if(!_isFirstLoading
              && !_isLoadMoreLoading
              && _schedules.isEmpty)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _initLoad,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    height: childHeight,
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.center,
                    child: Text('등록된 일정이 없습니다.'),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: _initLoad,
                child: _scheduleListView()
              ),
            ),
          if(_isFirstLoading)
            Container(
              padding: const EdgeInsets.all(30),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  Widget _searchHeadBar(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          for(var scheduleEnum in _schedulesTypeEnums)
            if(scheduleEnum.code != 'EMPTY')
              Container(
                padding: const EdgeInsets.only(
                    left: 5, right: 5
                ),
                child: OutlinedButton(
                  onPressed: () {
                    _toggleSearch(scheduleEnum.code);
                    _initLoad();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _searchScheduleTypes.contains(scheduleEnum.code) ? Colors.blueAccent : Colors.white,
                      side: BorderSide(color:Colors.blueAccent)
                  ),

                  child: Text(
                    '#${scheduleEnum.name}',
                    style: TextStyle(
                        color: _searchScheduleTypes.contains(
                            scheduleEnum.code) ? Colors.white : Colors
                            .blueAccent,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _scheduleListView(){
    return Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _schedules.length,
            itemBuilder: (context, index) =>
                Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 10
                  ),
                  child: ListTile(
                    leading: Icon(_schedules[index].scheduleIconData, size: 35,),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '${_schedules[index].scheduleTypeName.toString()} (${_schedules[index].scheduleStateName})',
                          style: TextStyle(
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Text(
                              '시작 ${_schedules[index].startDate.substring(0, 16)}'
                          ),
                          if(_schedules[index].endDate == "")
                            Text('')
                          else
                            Text(
                                '종료 ${_schedules[index].endDate?.substring(0, 16)}',
                            ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.access_time_outlined),
                      onPressed: () => _finishSchedule(index),
                    ),
                    onTap: () {
                      _showScheduleDialog(false, context, index);
                    },
                  ),
                ),
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
        ]
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
      String today = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      startDateTextEditController =
          TextEditingController(text: today.substring(0, 10));
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
                                    _initLoad();
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
                                      _arrangeSchedule(index);
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
                                                _initLoad();
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
  }
}
