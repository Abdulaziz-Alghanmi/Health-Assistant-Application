import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class grahps extends StatefulWidget {
  List<dynamic> readings;
  List<dynamic> readingshis;
  String dataType;
  grahps(this.readings, this.readingshis, this.dataType);
  @override
  _grahpsState createState() => _grahpsState(readings, readingshis, dataType);
}

class _grahpsState extends State<grahps> {
  var habox = Hive.box('mybox');
  List<dynamic> readings;
  List<dynamic> readingshis;
  List<_ChartData> data = [];
  String dataType;
  int normalCount = 0;
  int highCount = 0;
  int lowCount = 0;
  PageController _pageController;
  int _currentPage = 0;

  _grahpsState(this.readings, this.readingshis, this.dataType);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void sortingData() {
    switch (dataType) {
      case 'Temperature':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i] && readings[i] < 38) {
            data.add(_ChartData('Normal Temp', ++normalCount));
          } else if (readings[i] > 37) {
            data.add(_ChartData('Over Temp', ++highCount));
          } else if (readings[i] < 36) {
            data.add(_ChartData('Under Temp', ++lowCount));
          }
        }
        break;
      case 'Blood sugar':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i] && readings[i] < 38) {
            data.add(_ChartData('Normal level', ++normalCount));
          } else if (readings[i] >= 38) {
            data.add(_ChartData('Over level', ++highCount));
          } else if (readings[i] <= 35) {
            data.add(_ChartData('Under level', ++lowCount));
          }
        }
        break;
      case 'Heart beat':
        for (int i = 0; i < readings.length; i++) {
          if (60 <= readings[i] && readings[i] <= 100) {
            data.add(_ChartData('Normal Heart Beat', ++normalCount));
          } else if (readings[i] > 100) {
            data.add(_ChartData('High Heart Beat', ++highCount));
          } else if (readings[i] < 60) {
            data.add(_ChartData('Low Heart Beat', ++lowCount));
          }
        }
        break;
      case 'pressure':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i] && readings[i] < 38) {
            data.add(_ChartData('Normal', ++normalCount));
          } else if (readings[i] >= 38) {
            data.add(_ChartData('High', ++highCount));
          } else if (readings[i] <= 35) {
            data.add(_ChartData('Low', ++lowCount));
          }
        }
        break;
    }
  }

  bool methodCalled = false;
  //DateFormat.yMd().add_jm().format(DateTime.now()).toString();

  @override
  Widget build(BuildContext context) {
    if (!methodCalled) {
      methodCalled = true;
      sortingData();
    }
    return Scaffold(
      appBar: AppBar(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: <Widget>[
          //pages of History and Grahps and Reports are shown here
          Container(
            height: 300,
            child: viewGraph(),
          ),
          ListView(
            children: generateCards(),
          ),
          readings.length == 10
              ? Container(child: report())
              : AlertDialog(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  content: Text(
                    "You dont have enough records",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 75, 75, 75),
        currentIndex: _currentPage,
        onTap: (int index) {
          setState(() {
            _currentPage = index;
          });
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.ease);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.graphic_eq),
            label: 'Graphs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grading_sharp),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Report',
          ),
        ],
      ),
    );
  }

  Widget viewGraph() {
    return Container(
      height: 300,
      //color: Color.fromARGB(255, 1, 0, 61),
      width: double.infinity,
      child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(minimum: 0, maximum: 10, interval: 1),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<_ChartData, String>>[
            ColumnSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (_ChartData data, _) => data.time_x,
                yValueMapper: (_ChartData data, _) => data.readings_y,
                color: Color.fromARGB(255, 177, 177, 177))
          ]),
    );
  }

  Widget report() {
    normalCount = 0;
    highCount = 0;
    lowCount = 0;
    String reportType = dataType;
    String condition;
    switch (dataType) {
      case 'Temperature':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i] && readings[i] < 38) {
            ++normalCount;
          } else if (readings[i] > 37) {
            ++highCount;
          } else if (readings[i] < 36) {
            ++lowCount;
          }
        }
        if (35 < readings[6] && readings[6] < 38) {
          condition = "Normal";
        } else if (readings[6] > 37) {
          condition = "High";
        } else if (readings[6] < 36) {
          condition = "Low";
        }
        break;
      case 'Blood sugar':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i] && readings[i] < 38) {
            ++normalCount;
          } else if (readings[i] >= 38) {
            ++highCount;
          } else if (readings[i] <= 35) {
            ++lowCount;
          }
        }
        if (35 < readings[6] && readings[6] < 38) {
          condition = "Normal";
        } else if (readings[6] >= 38) {
          condition = "High";
        } else if (readings[6] <= 35) {
          condition = "Low";
        }
        break;
      case 'Heart beat':
        for (int i = 0; i < readings.length; i++) {
          if (60 <= readings[i] && readings[i] <= 100) {
            ++normalCount;
          } else if (readings[i] > 100) {
            ++highCount;
          } else if (readings[i] < 60) {
            ++lowCount;
          }
        }
        if (60 <= readings[6] && readings[6] <= 100) {
          condition = "Normal";
        } else if (readings[6] > 100) {
          condition = "High";
        } else if (readings[6] < 60) {
          condition = "Low";
        }
        break;
      case 'pressure':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i] && readings[i] < 38) {
            ++normalCount;
          } else if (readings[i] >= 38) {
            ++highCount;
          } else if (readings[i] <= 35) {
            ++lowCount;
          }
        }
        if (35 < readings[6] && readings[6] < 38) {
          condition = "Normal";
        } else if (readings[6] >= 38) {
          condition = "High";
        } else if (readings[6] <= 35) {
          condition = "Low";
        }
        break;
    }

    print('normal: $normalCount');
    print('low: $lowCount');
    print('high: $highCount');

    String strr =
        reportStr(normalCount, lowCount, highCount, reportType, condition);
    return Text(strr);
  }

  List<Widget> generateCards() {
    List<Widget> cards = [];
    for (int i = 0; i < readings.length; i++) {
      cards.add(Card(
        child: Container(
          color: Color.fromARGB(255, 95, 95, 95),
          child: ListTile(
            title: Text('Record : ' + readings[i].toString()),
            subtitle: Text(readingshis[i]),
            trailing: Container(
              width: 48,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          readings.removeAt(i);
                          readingshis.removeAt(i);
                          data.removeAt(i);

                          switch (dataType) {
                            case 'Temperature':
                              habox.put("tempReadings", readings);
                              habox.put("tempHis", readingshis);
                              readings = habox.get("tempReadings");
                              readingshis = habox.get("tempHis");
                              break;
                            case 'Blood sugar':
                              habox.put("sugarReadings", readings);
                              habox.put("sugarHis", readingshis);
                              readings = habox.get("sugarReadings");
                              readingshis = habox.get("sugarHis");
                              break;
                            case 'Heart beat':
                              habox.put("hbReadings", readings);
                              habox.put("hbHis", readingshis);
                              readings = habox.get("hbReadings");
                              readingshis = habox.get("hbHis");
                              break;
                            case 'pressure':
                              habox.put("pressureReadings", readings);
                              habox.put("pressureHis", readingshis);
                              readings = habox.get("pressureReadings");
                              readingshis = habox.get("pressureHis");
                              break;
                          }

                          viewGraph();
                        });
                      },
                      icon: Icon(Icons.delete_rounded))
                ],
              ),
            ),
          ),
        ),
      ));
    }
    return cards;
  }

  String reportStr(
      int normal, int high, int low, String type, String lastCondition) {
    if (low == 0 && high == 0) {
      return 'All readings are good';
    } else if (normal == 0 && low == 0) {
      return 'All readings are High you should see the doctor';
    } else if (normal == 0 && high == 0) {
      return 'All readings are low you should see the doctor';
    } else if (normal > high) {}
  }
}

// model for the column chart
class _ChartData {
  _ChartData(this.time_x, this.readings_y);

  final String time_x;
  final int readings_y;
}
