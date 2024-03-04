import 'dart:math';

import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mylifeflow_app/schedule/statistics/repository/statictics_repository.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../common/enum/schedule_enum.dart';
import 'model/statisticsmodel.dart';

@RoutePage()
class ScheduleTypePage extends StatefulWidget {
  const ScheduleTypePage({super.key});

  @override
  State<ScheduleTypePage> createState() => _ScheduleTypePageState();
}

class _ScheduleTypePageState extends State<ScheduleTypePage> {
  final statisticsRepository = StatisticsRepository();
  List<StatisticsModel> _typesData = [];

  bool _isLoading = false;
  List<String> _years = [];
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());

  List<_LineChartData> _lineChartData = [];
  List<_PieChartData> _pieChartData = [];


  @override
  void initState() {
    super.initState();
    _initSearchValue();
    _initLoad();
  }

  Future _initLoad() async {
    setState(() {
      _isLoading = true;
    });

    _typesData = await statisticsRepository.fetchMonthlyScheduleType(_selectedYear);
    _loadLineChartData();
    _settingPieChartData();

    setState(() {
      _isLoading = false;
    });
  }

  void _loadLineChartData(){
    _lineChartData = [];
    for(var type in ScheduleEnum.values){
      String typeCode = type.code;
      if(typeCode != ScheduleEnum.empty.code) {
        List<_LineChartChildData> lineChartChildData = [];
        for (int month = monthlyTypeMinMonth; month <=
            monthlyTypeMaxMonth; month++) {
          if(_typesData.isNotEmpty) {
            int count = _typesData
                .firstWhere(
                    (element) =>
                (typeCode == element.scheduleType &&
                    month == element.scheduleMonth),
                orElse: () => StatisticsModel.init()
            )
                .scheduleTypeCount;
            lineChartChildData.add(_LineChartChildData(month, count));
          }
        }

        _lineChartData.add(
            _LineChartData(
                ScheduleEnum
                    .getByCode(typeCode)
                    .name,
                lineChartChildData
            )
        );
      }
    }
  }

  void _settingPieChartData(){
    _pieChartData = [];
    for(var type in ScheduleEnum.values){
      String typeCode = type.code;
      if(typeCode != ScheduleEnum.empty.code) {
        int totalCount = 0;
        int typeCount = 0;
        if(_typesData.isNotEmpty) {
          for (var element in _typesData) {
            totalCount += element.scheduleTypeCount;
          }

          for (var element in _typesData) {
            if (typeCode == element.scheduleType) {
              typeCount += element.scheduleTypeCount;
            }
          }
        }
        _pieChartData.add(
            _PieChartData(
                type.name,
                totalCount == 0 || typeCount == 0 ? 0 : (typeCount/totalCount*100).ceilToDouble()
            )
        );
      }
    }
  }
  int get monthlyTypeMaxCount {
    int maxCount = 10;
    if(_typesData.isNotEmpty) {
      for (var monthlyType in _typesData) {
        maxCount = max(monthlyType.scheduleTypeCount, maxCount);
      }
    }
    return maxCount;
  }

  int get monthlyTypeMaxMonth {
    int maxMonth = DateTime.now().month;
    if(_typesData.isNotEmpty) {
      for (var monthlyType in _typesData) {
        maxMonth = max(monthlyType.scheduleMonth, maxMonth);
      }
    }
    return maxMonth;
  }

  int get monthlyTypeMinMonth {
    int minMonth = 1;
    if(_typesData.isNotEmpty) {
      for (var monthlyType in _typesData) {
        minMonth = min(monthlyType.scheduleMonth, minMonth);
      }
    }
    return minMonth;
  }

  void _initSearchValue() {
    for(int val = DateTime.now().year ; val >= 2023 ; val--){
      _years.add(val.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final chartHeight = width*0.5;
    final height = MediaQuery.of(context).size.height;
    final childHeight = height-(height*0.07)-94;
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: height*0.07,
              padding: const EdgeInsets.all(5),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for(var val in _years)
                      Container(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedYear = val;
                              _initLoad();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedYear == val ? Colors.blueAccent : Colors.white,
                            side: BorderSide(color:Colors.blueAccent)
                          ),
                          child: Text(
                            val,
                            style: TextStyle(
                              color: _selectedYear == val ? Colors.white : Colors.blueAccent,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _initLoad
                ,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.all(0),
                    height: childHeight,
                    child:  _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.only(
                            left: 15, top: 5, right: 15, bottom: 5
                          ),
                          child: SizedBox(
                            height: chartHeight,
                            child: SfCartesianChart(
                                enableAxisAnimation: true,
                                plotAreaBorderWidth: 0,
                                primaryXAxis: CategoryAxis(
                                  majorGridLines: MajorGridLines(width: 0),
                                  axisLine: AxisLine(width: 0),
                                ),
                                title: ChartTitle(text: '월별 일정현황'),
                                // Enable legend
                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom
                                ),
                                primaryYAxis: NumericAxis(
                                  axisLine: AxisLine(width: 0),
                                  labelFormat: '{value}',
                                  majorTickLines: MajorTickLines(size: 0),
                                  minimum: 0,
                                  interval: 5,
                                  maximum: monthlyTypeMaxCount%5 > 0 ? (monthlyTypeMaxCount+5).toDouble() : monthlyTypeMaxCount.toDouble(),
                                ),
                                // Enable tooltip
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CartesianSeries<_LineChartChildData, String>>[
                                  for(var lineChartData in _lineChartData)
                                    LineSeries<_LineChartChildData, String>(
                                      dataSource: lineChartData.chartChildData,
                                      xValueMapper: (_LineChartChildData data, index) => "${data.month}월",
                                      yValueMapper: (_LineChartChildData data, _) => data.count,
                                      name: lineChartData.scheduleTypeName,
                                      // Enable data label
                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                      animationDelay: 300,
                                      animationDuration: 500,
                                    )
                                ],
                            ),
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(
                              left: 15, top: 10, right: 15, bottom: 10
                          ),
                          child: SizedBox(
                            height: chartHeight,
                            child: SfCircularChart(
                                title: ChartTitle(text: '일정별 비율(%)'),
                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom
                                ),
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CircularSeries>[
                                  // Render pie chart
                                  PieSeries<_PieChartData, String>(
                                    dataSource: _pieChartData,
                                    xValueMapper: (_PieChartData data, _) => data.x,
                                    yValueMapper: (_PieChartData data, _) => data.y,
                                    radius: '50%',
                                    explode: true,
                                    animationDelay: 300,
                                    animationDuration: 500,
                                  )
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _LineChartData {
  _LineChartData(
    this.scheduleTypeName,
    this.chartChildData,
  );

  final String scheduleTypeName;
  final List<_LineChartChildData> chartChildData;
}
class _LineChartChildData{
  _LineChartChildData(
    this.month,
    this.count,
  );

  final int month;
  final int count;
}

class _PieChartData{
  _PieChartData(this.x, this.y);
  final String x;
  final double y;
}