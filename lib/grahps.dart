import 'dart:developer';

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:healthassistant/sqldb.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:healthassistant/PdfParagraphApi.dart';

class grahps extends StatefulWidget {
  List<dynamic> readings;
  String dataType;
  grahps(this.readings, this.dataType);
  @override
  _grahpsState createState() => _grahpsState(readings, dataType);
}

class _grahpsState extends State<grahps> {
  List<dynamic> readings;
  List<dynamic> profile;
  List<_ChartData> data = [];
  String dataType;
  int normalCount = 0;
  int highCount = 0;
  int lowCount = 0;
  String lastCondition;
  PageController _pageController;
  int _currentPage = 0;
  SqlDb sqlDb = SqlDb();
  _grahpsState(this.readings, this.dataType);
  bool diabetes = false;

  //diabetes range
  int minBloodSugar = 69;
  int maxBloodSugar = 100;
  //diabetes range

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

  void initList(String type) async {
    readings =
        await sqlDb.readData("Select * FROM 'vitalSigns' WHERE type = '$type'");
    profile = await sqlDb.readData("Select * FROM 'profile'");
    if (profile[0]['diseases'].toString().contains("Diabetes")) {
      diabetes = true;
      minBloodSugar = 79;
      maxBloodSugar = 131;
    }
  }

  void sortingData() async {
    normalCount = 0;
    highCount = 0;
    lowCount = 0;
    String vitalS;
    String vitalD;
    data = [];
    switch (dataType) {
      case 'Temperature':
        for (int i = 0; i < readings.length; i++) {
          if (35 < readings[i]['recored'] && readings[i]['recored'] < 38) {
            data.add(_ChartData('Normal Temp', ++normalCount));
          } else if (readings[i]['recored'] > 37) {
            data.add(_ChartData('Over Temp', ++highCount));
          } else if (readings[i]['recored'] < 36) {
            data.add(_ChartData('Under Temp', ++lowCount));
          }
        }

        if (35 < readings[readings.length - 1]['recored'] &&
            readings[readings.length - 1]['recored'] < 38) {
          lastCondition = "normal";
        } else if (readings[readings.length - 1]['recored'] > 37) {
          lastCondition = "high";
        } else if (readings[readings.length - 1]['recored'] < 36) {
          lastCondition = "low";
        }

        break;
      case 'Blood sugar':
        for (int i = 0; i < readings.length; i++) {
          if (minBloodSugar < readings[i]['recored'] &&
              readings[i]['recored'] < maxBloodSugar) {
            data.add(_ChartData('Normal level', ++normalCount));
          } else if (readings[i]['recored'] >= maxBloodSugar) {
            data.add(_ChartData('Over level', ++highCount));
          } else if (readings[i]['recored'] <= minBloodSugar) {
            data.add(_ChartData('Under level', ++lowCount));
          }
        }

        if (minBloodSugar < readings[readings.length - 1]['recored'] &&
            readings[readings.length - 1]['recored'] < maxBloodSugar) {
          lastCondition = "normal";
        } else if (readings[readings.length - 1]['recored'] >= maxBloodSugar) {
          lastCondition = "high";
        } else if (readings[readings.length - 1]['recored'] <= minBloodSugar) {
          lastCondition = "low";
        }

        break;
      case 'Heart beat':
        for (int i = 0; i < readings.length; i++) {
          if (60 <= readings[i]['recored'] && readings[i]['recored'] <= 100) {
            data.add(_ChartData('Normal Heart Beat', ++normalCount));
          } else if (readings[i]['recored'] > 100) {
            data.add(_ChartData('High Heart Beat', ++highCount));
          } else if (readings[i]['recored'] < 60) {
            data.add(_ChartData('Low Heart Beat', ++lowCount));
          }
        }

        if (60 <= readings[readings.length - 1]['recored'] &&
            readings[readings.length - 1]['recored'] <= 100) {
          lastCondition = "normal";
        } else if (readings[readings.length - 1]['recored'] > 100) {
          lastCondition = "high";
        } else if (readings[readings.length - 1]['recored'] < 60) {
          lastCondition = "low";
        }

        break;
      case 'pressure':
        for (int i = 0; i < readings.length; i++) {
          if (90 <= readings[i]['SystolicRecored'] &&
              readings[i]['SystolicRecored'] <= 120 &&
              60 <= readings[i]['DiastolicRecored'] &&
              readings[i]['DiastolicRecored'] <= 80) {
            data.add(_ChartData('Normal', ++normalCount));
          } else if (readings[i]['SystolicRecored'] > 120 &&
              readings[i]['DiastolicRecored'] > 80) {
            data.add(_ChartData('High', ++highCount));
          } else if (readings[i]['SystolicRecored'] < 90 &&
              readings[i]['DiastolicRecored'] < 60) {
            data.add(_ChartData('Low', ++lowCount));
          }
          if (90 < readings[readings.length - 1]['SystolicRecored'] &&
              readings[readings.length - 1]['SystolicRecored'] < 130 &&
              60 < readings[readings.length - 1]['DiastolicRecored'] &&
              readings[readings.length - 1]['DiastolicRecored'] < 90) {
            lastCondition = "normal";
          } else if (readings[readings.length - 1]['SystolicRecored'] > 129 &&
              readings[readings.length - 1]['DiastolicRecored'] > 89) {
            lastCondition = "high";
          } else if (readings[readings.length - 1]['SystolicRecored'] < 91 &&
              readings[readings.length - 1]['DiastolicRecored'] < 61) {
            lastCondition = "low";
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    initList(dataType);
    sortingData();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 73, 81, 124),
        actions: [
          IconButton(
            onPressed: () {
              PdfParagraphApi(readings, dataType);
            },
            icon: Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 40, 44, 68),
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

          readings.length == 7
              ? Container(child: report())
              : AlertDialog(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  content: Text(
                    "You dont have enough records, you need 7 records",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  )),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 73, 81, 124),
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
            icon: Icon(
              Icons.graphic_eq,
              color: Colors.white,
            ),
            label: 'Graphs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grading_sharp, color: Colors.white),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: 'Report',
          ),
        ],
      ),
    );
  }

  Widget viewGraph() {
    print(ColumnSeries);
    return Container(
      height: 300,
      //color: Color.fromARGB(255, 1, 0, 61),
      width: double.infinity,
      child: SfCartesianChart(
          primaryXAxis:
              CategoryAxis(labelStyle: TextStyle(color: Colors.white)),
          plotAreaBorderColor: Color.fromARGB(255, 255, 255, 255),
          primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 7,
              interval: 1,
              labelStyle: TextStyle(color: Colors.white)),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<_ChartData, String>>[
            ColumnSeries<_ChartData, String>(
                dataSource: data,
                xValueMapper: (_ChartData data, _) => data.time_x,
                yValueMapper: (_ChartData data, _) => data.readings_y,
                color: Color.fromARGB(255, 255, 255, 255))
          ]),
    );
  }

  Widget report() {
    String strr =
        reportStr(normalCount, highCount, lowCount, dataType, lastCondition);
    print(strr);
    return Text(
      strr,
      style: TextStyle(color: Colors.white),
    );
  }

  List<Widget> generateCards() {
    String cheked;
    List<Widget> cards = [];
    for (int i = 0; i < readings.length; i++) {
      cards.add(Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          color: checker(i, dataType) == 'normal'
              ? Color.fromARGB(255, 44, 158, 59)
              : checker(i, dataType) == 'high'
                  ? Color.fromARGB(255, 163, 38, 38)
                  : Color.fromARGB(255, 51, 145, 161),
          child: ListTile(
            title: dataType == "pressure"
                ? Text(
                    'Record : ' +
                        readings[i]['SystolicRecored']
                            .toString()
                            .replaceAll(".0", "") +
                        '/' +
                        readings[i]['DiastolicRecored']
                            .toString()
                            .replaceAll(".0", ""),
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20),
                  )
                : Text('Record : ' + readings[i]['recored'].toString(),
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 20)), //record
            subtitle: Text(readings[i]['date'],
                style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold)), //history
            trailing: Container(
              width: 48,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        //print(readings[i]);
                        int id = readings[i]['id'];
                        await sqlDb.deleteData(
                            "DELETE FROM 'vitalSigns' WHERE id='$id'");
                        initList(dataType);
                        data.removeAt(i);
                        setState(() {});
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

  String checker(int i, String type) {
    switch (type) {
      case 'Temperature':
        if (35 < readings[i]['recored'] && readings[i]['recored'] < 38) {
          return "normal";
        } else if (readings[i]['recored'] > 37) {
          return "high";
        } else if (readings[i]['recored'] < 36) {
          return "low";
        }

        break;
      case 'Blood sugar':
        if (minBloodSugar < readings[i]['recored'] &&
            readings[i]['recored'] < maxBloodSugar) {
          return "normal";
        } else if (readings[i]['recored'] >= maxBloodSugar) {
          return "high";
        } else if (readings[i]['recored'] <= minBloodSugar) {
          return "low";
        }

        break;
      case 'Heart beat':
        if (60 <= readings[i]['recored'] && readings[i]['recored'] <= 100) {
          return "normal";
        } else if (readings[i]['recored'] > 100) {
          return "high";
        } else if (readings[i]['recored'] < 60) {
          return "low";
        }

        break;
      case 'pressure':
        if (90 <= readings[i]['SystolicRecored'] &&
            readings[i]['SystolicRecored'] <= 120 &&
            60 <= readings[i]['DiastolicRecored'] &&
            readings[i]['DiastolicRecored'] <= 80) {
          return "normal";
        } else if (readings[i]['SystolicRecored'] > 120 &&
            readings[i]['DiastolicRecored'] > 80) {
          return "high";
        } else if (readings[i]['SystolicRecored'] < 90 &&
            readings[i]['DiastolicRecored'] < 60) {
          return "low";
        }

        break;
    }
  }

  String reportStr(
      int normal, int high, int low, String type, String lastCondition) {
    if (low == 0 && high == 0) {
      return 'Your readings have been stable and your health are good.\nEat healthy food and exercise every day for a healthy life.';
    } else if (normal == 0 && low == 0) {
      return 'All readings are High you should see the doctor';
    } else if (normal == 0 && high == 0) {
      return 'All readings are low you should see the doctor';
    } else if (high > normal && high > low) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are high, your blood sugar is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\n- It\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are high. ' +
              '. Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are higher,' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are high. Adopting healthy lifestyle habits such as not smoking, exercising and eating a healthy diet can help prevent and treat high blood pressure. Decreasing salt in your diet, ' +
              'losing weight if necessary, stopping smoking, cutting down on alcohol use, and regular exercise. because high blood pressure is a long-lasting medical condition that often has little or no symptoms, remembering to take your medications can be a challenge.' +
              ' Combination medicines, long-acting or once-a-day medications, may be used to decrease the burden of taking numerous medications and help ensure medications regularly. Once started, the medication should be used until your doctor tells you to stop.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' records have been unstable. Most of the records indicate that your ' +
              type +
              ' level were high ' +
              'But recent readings indicate that you start to recover and your blood sugar levels are getting normal.' +
              '\n\n What You Need To?' +
              '\nHere are a few things you can do' +
              '\n- Monitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nContinue a healthy diet: Eating a diet low in sugar and carbohydrates, and high in fiber and healthy fats can help maintain normal blood sugar levels.' +
              '\nExercise regularly: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood sugar levels, it is important to contact your doctor for further evaluation and advice.' +
              '\nAvoid triggers: Identify and avoid foods, drinks, or activities that may trigger high blood sugar level, such as eating too much sugar or carbohydrates, skipping meals, or not exercising regularly.' +
              '\nGet Regular checkup: Regularly monitoring your blood sugar levels and seeing your doctor for check-ups are important for controlling diabetes and preventing complications.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' readings were high ' +
              'But recent readings indicate that your body temperature has returned to a normal range after being high, it is important to continue to take care of yourself to help prevent future fevers.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              'Rest: Continue to get plenty of rest to help your body recover from the underlying condition that caused the fever.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nTake care of the underlying condition: Follow your doctor\'s instructions for treating the underlying condition that caused the fever. This may include taking medication, undergoing further testing or follow-up visits.' +
              '\nFollow a healthy lifestyle: Eating a healthy diet, exercising regularly, and not smoking can help boost your immune system and improve your overall health.' +
              '\nGet enough sleep: Make sure you are getting enough sleep each night to help your body recover and stay healthy.' +
              '\nPractice good hygiene: Wash your hands regularly and keep your living space clean to help prevent the spread of germs and infection.' +
              '\nConsult your doctor: If you are experiencing recurring fevers or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate were high ' +
              'But recent readings indicate that your heart rate has returned to a normal range after being high, it is important to continue with healthy habits to help prevent future episodes of tachycardia. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nIdentify triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nPractice relaxation techniques: Try to reduce stress and anxiety with techniques such as deep breathing, yoga, or meditation.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nContinue with your medications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\nIt is important to note that high heart rate could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your high heart rate and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of tachycardia.';
        } else if (type == "pressure") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high ' +
              'But recent readings indicate that your blood pressure has returned to a normal range after being high, it is important to continue with healthy habits to help maintain normal blood pressure and prevent future episodes of hypertension. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\n Monitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nTake your medication: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of high blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              'level were high. But recent readings indicate that your blood sugar level has dropped from high to low, also known as hypoglycemia, it is important to take steps to raise it back to a healthy level. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nEat or drink something sweet: Consume a small amount of a quick-acting carbohydrate such as fruit juice, a regular soft drink, glucose gel or candy to raise your blood sugar level quickly.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nFollow a consistent meal plan: Eat regular, consistent meals and snacks to help prevent low blood sugar levels.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAvoid triggers: Identify and avoid foods, drinks, or activities that may trigger low blood sugar level, such as skipping meals, exercising heavily or taking more insulin than needed.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that if your blood sugar level drops too low and you are experiencing symptoms such as confusion, difficulty speaking, or unconsciousness, seek immediate medical attention. If you have recurrent episodes of hypoglycemia,' +
              ' it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high. But recent readings indicate that your body temperature has dropped from high to low, also known as hypothermia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nGet out of cold environment: If you\'re outside in cold weather, get indoors or to a warm shelter as soon as possible.' +
              '\nDress warmly: Put on warm clothing, including a hat and gloves to help your body retain heat.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble raising your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition that can occur when the body loses heat faster than it can produce heat, and if left untreated it can lead to serious complications, even death. It is crucial to seek medical attention if you suspect hypothermia, and to take preventive measures when in cold environments.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high. But recent readings indicate that  your heart rate has dropped from high to low, also known as bradycardia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as fatigue, lightheadedness, or fainting, or if you are having trouble raising your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause bradycardia, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If bradycardia is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nLifestyle changes: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that bradycardia could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your low heart rate and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of bradycardia.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              'were high. But recent readings indicate that your blood pressure has dropped from high to low, also known as hypotension, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nSit down or lie down: If you feel lightheaded or dizzy, sit down or lie down to raise your blood pressure.' +
              '\nDrink fluids: Drink fluids, especially water, to help raise your blood pressure.' +
              '\nEat a small snack: Eating a small snack, such as a piece of fruit or crackers, can help raise your blood pressure.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or fatigue, or if you are having trouble raising your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause hypotension, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that hypotension could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your low blood pressure and receive appropriate treatment.';
        }
      }
    } else if (high > normal && low == 0) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are high, your blood sugar is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\n- It\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are high. ' +
              '. Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are higher,' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are high. Adopting healthy lifestyle habits such as not smoking, exercising and eating a healthy diet can help prevent and treat high blood pressure. Decreasing salt in your diet, ' +
              'losing weight if necessary, stopping smoking, cutting down on alcohol use, and regular exercise. because high blood pressure is a long-lasting medical condition that often has little or no symptoms, remembering to take your medications can be a challenge.' +
              ' Combination medicines, long-acting or once-a-day medications, may be used to decrease the burden of taking numerous medications and help ensure medications regularly. Once started, the medication should be used until your doctor tells you to stop.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' records have been unstable. Most of the records indicate that your ' +
              type +
              ' level were high ' +
              'But recent readings indicate that you start to recover and your blood sugar levels are getting normal.' +
              '\n\n What You Need To?' +
              '\nHere are a few things you can do' +
              '\n- Monitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nContinue a healthy diet: Eating a diet low in sugar and carbohydrates, and high in fiber and healthy fats can help maintain normal blood sugar levels.' +
              '\nExercise regularly: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood sugar levels, it is important to contact your doctor for further evaluation and advice.' +
              '\nAvoid triggers: Identify and avoid foods, drinks, or activities that may trigger high blood sugar level, such as eating too much sugar or carbohydrates, skipping meals, or not exercising regularly.' +
              '\nGet Regular checkup: Regularly monitoring your blood sugar levels and seeing your doctor for check-ups are important for controlling diabetes and preventing complications.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' readings were high ' +
              'But recent readings indicate that your body temperature has returned to a normal range after being high, it is important to continue to take care of yourself to help prevent future fevers.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              'Rest: Continue to get plenty of rest to help your body recover from the underlying condition that caused the fever.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nTake care of the underlying condition: Follow your doctor\'s instructions for treating the underlying condition that caused the fever. This may include taking medication, undergoing further testing or follow-up visits.' +
              '\nFollow a healthy lifestyle: Eating a healthy diet, exercising regularly, and not smoking can help boost your immune system and improve your overall health.' +
              '\nGet enough sleep: Make sure you are getting enough sleep each night to help your body recover and stay healthy.' +
              '\nPractice good hygiene: Wash your hands regularly and keep your living space clean to help prevent the spread of germs and infection.' +
              '\nConsult your doctor: If you are experiencing recurring fevers or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate were high ' +
              'But recent readings indicate that your heart rate has returned to a normal range after being high, it is important to continue with healthy habits to help prevent future episodes of tachycardia. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nIdentify triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nPractice relaxation techniques: Try to reduce stress and anxiety with techniques such as deep breathing, yoga, or meditation.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nContinue with your medications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\nIt is important to note that high heart rate could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your high heart rate and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of tachycardia.';
        } else if (type == "pressure") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high ' +
              'But recent readings indicate that your blood pressure has returned to a normal range after being high, it is important to continue with healthy habits to help maintain normal blood pressure and prevent future episodes of hypertension. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\n Monitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nTake your medication: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of high blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      }
    } else if (high > low && normal == 0) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are high, your blood sugar is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\nIt\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are high. ' +
              '. Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are higher,' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are high. Adopting healthy lifestyle habits such as not smoking, exercising and eating a healthy diet can help prevent and treat high blood pressure. Decreasing salt in your diet, ' +
              'losing weight if necessary, stopping smoking, cutting down on alcohol use, and regular exercise. because high blood pressure is a long-lasting medical condition that often has little or no symptoms, remembering to take your medications can be a challenge.' +
              ' Combination medicines, long-acting or once-a-day medications, may be used to decrease the burden of taking numerous medications and help ensure medications regularly. Once started, the medication should be used until your doctor tells you to stop.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              'level were high. But recent readings indicate that your blood sugar level has dropped from high to low, also known as hypoglycemia, it is important to take steps to raise it back to a healthy level. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nEat or drink something sweet: Consume a small amount of a quick-acting carbohydrate such as fruit juice, a regular soft drink, glucose gel or candy to raise your blood sugar level quickly.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nFollow a consistent meal plan: Eat regular, consistent meals and snacks to help prevent low blood sugar levels.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAvoid triggers: Identify and avoid foods, drinks, or activities that may trigger low blood sugar level, such as skipping meals, exercising heavily or taking more insulin than needed.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that if your blood sugar level drops too low and you are experiencing symptoms such as confusion, difficulty speaking, or unconsciousness, seek immediate medical attention. If you have recurrent episodes of hypoglycemia,' +
              ' it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high. But recent readings indicate that your body temperature has dropped from high to low, also known as hypothermia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nGet out of cold environment: If you\'re outside in cold weather, get indoors or to a warm shelter as soon as possible.' +
              '\nDress warmly: Put on warm clothing, including a hat and gloves to help your body retain heat.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble raising your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition that can occur when the body loses heat faster than it can produce heat, and if left untreated it can lead to serious complications, even death. It is crucial to seek medical attention if you suspect hypothermia, and to take preventive measures when in cold environments.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high. But recent readings indicate that  your heart rate has dropped from high to low, also known as bradycardia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as fatigue, lightheadedness, or fainting, or if you are having trouble raising your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause bradycardia, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If bradycardia is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nLifestyle changes: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that bradycardia could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your low heart rate and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of bradycardia.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              'were high. But recent readings indicate that your blood pressure has dropped from high to low, also known as hypotension, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nSit down or lie down: If you feel lightheaded or dizzy, sit down or lie down to raise your blood pressure.' +
              '\nDrink fluids: Drink fluids, especially water, to help raise your blood pressure.' +
              '\nEat a small snack: Eating a small snack, such as a piece of fruit or crackers, can help raise your blood pressure.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or fatigue, or if you are having trouble raising your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause hypotension, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that hypotension could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your low blood pressure and receive appropriate treatment.';
        }
      }
    } else if (low > high && normal == 0) {
      if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood sugar level is low, also known as hypoglycemia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do.' +
              '\nEat a small snack: Eat a small snack that contains carbohydrates, such as fruit, crackers, or juice.' +
              '\nDrink a glass of juice or eat a piece of fruit: Eating a small snack that is high in sugar such as a candy bar, glucose gel, or a glass of fruit juice can help raise your blood sugar level quickly.' +
              '\nCheck your blood sugar level: After eating, check your blood sugar level after 15-20 minutes and if it\'s still low, repeat the previous step' +
              '\nConsult your doctor: If you are experiencing symptoms of hypoglycemia, such as shakiness, dizziness, sweating, or confusion, or if you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nFollow your treatment plan: If you have diabetes or another condition that causes low blood sugar, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypoglycemia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. It\'s also important to carry with you, at all times, a form of glucose such as fruit juice, glucose gel or a candy, which can be used in case of an episode of low blood sugar.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature is low, also known as hypothermia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, including a hat and gloves, to help your body retain heat.' +
              '\nStay indoors: Stay indoors in a warm environment, if possible.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypothermia can be caused by underlying conditions such as anemia or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition and can be life-threatening if left untreated, so it is important to seek medical attention as soon as possible if you suspect you have hypothermia. You should also be mindful of the weather and dress appropriately when going outside during cold weather to prevent hypothermia.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your heart rate is low, also known as bradycardia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nMaintain a healthy lifestyle: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that bradycardia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of bradycardia, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure is low, also known as hypotension, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nStand up slowly: When you stand up, do it slowly to avoid feeling lightheaded or dizzy.' +
              '\nDrink more fluids: Drinking fluids, especially water, can help increase blood volume and raise blood pressure.' +
              '\nEat a healthy diet: Eating a diet rich in fruits, vegetables, and whole grains can help increase blood pressure.' +
              '\nExercise regularly: Regular exercise can help increase blood pressure and improve cardiovascular health.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypotension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of hypotension, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        }
      } else if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high. But recent readings indicate that your blood sugar level has risen from low to high, it is important to take steps to bring it back to a healthy level.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood sugar level: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks to help prevent high blood sugar levels.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: High blood sugar can be caused by underlying conditions such as stress, infection, or changes in your medications, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that high blood sugar level can be a symptom of an underlying condition, such as diabetes, so it is important to consult your doctor to determine the cause of your high blood sugar level and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of high blood sugar level.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature has risen from low to high, it\'s important to take steps to bring it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              'Dress warmly: Put on warm clothing, including a hat and gloves to help your body retain heat.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that low or high body temperature can be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your temperature changes and receive appropriate treatment. If your temperature goes from low to high, it may be indicating a fever, which is a symptom of an infection or illness, and if it goes from high to normal, it may indicate that the body is fighting off the infection or illness and returning to a healthy state.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that If your heart rate has risen from low to high, it\'s important to take steps to bring it back to a normal range..' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low or high heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Low or high heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nLifestyle changes: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that low or high heart rate could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your heart rate changes and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure has risen from low to high, it\'s important to take steps to bring it back to a normal range. High blood pressure, also known as hypertension, is a serious condition that can lead to heart disease, stroke, and other health problems' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt, getting regular exercise, maintaining a healthy weight, and not smoking can help lower your blood pressure and improve your overall health.' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypertension or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nAddress underlying conditions: High blood pressure can be caused by underlying conditions such as kidney disease or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypertension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If your blood pressure goes from low to high, it is important to consult your doctor to determine the cause of this change.';
        }
      }
    } else if (low > normal && low > high) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood sugar level has risen from low to high, it is important to take steps to bring it back to a healthy level.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood sugar level: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks to help prevent high blood sugar levels.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: High blood sugar can be caused by underlying conditions such as stress, infection, or changes in your medications, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that high blood sugar level can be a symptom of an underlying condition, such as diabetes, so it is important to consult your doctor to determine the cause of your high blood sugar level and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of high blood sugar level.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature has risen from low to high, it\'s important to take steps to bring it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              'Dress warmly: Put on warm clothing, including a hat and gloves to help your body retain heat.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that low or high body temperature can be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your temperature changes and receive appropriate treatment. If your temperature goes from low to high, it may be indicating a fever, which is a symptom of an infection or illness, and if it goes from high to normal, it may indicate that the body is fighting off the infection or illness and returning to a healthy state.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that If your heart rate has risen from low to high, it\'s important to take steps to bring it back to a normal range..' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low or high heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Low or high heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nLifestyle changes: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that low or high heart rate could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your heart rate changes and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure has risen from low to high, it\'s important to take steps to bring it back to a normal range. High blood pressure, also known as hypertension, is a serious condition that can lead to heart disease, stroke, and other health problems' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt, getting regular exercise, maintaining a healthy weight, and not smoking can help lower your blood pressure and improve your overall health.' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypertension or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nAddress underlying conditions: High blood pressure can be caused by underlying conditions such as kidney disease or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypertension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If your blood pressure goes from low to high, it is important to consult your doctor to determine the cause of this change.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood sugar level is low, also known as hypoglycemia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do.' +
              '\nEat a small snack: Eat a small snack that contains carbohydrates, such as fruit, crackers, or juice.' +
              '\nDrink a glass of juice or eat a piece of fruit: Eating a small snack that is high in sugar such as a candy bar, glucose gel, or a glass of fruit juice can help raise your blood sugar level quickly.' +
              '\nCheck your blood sugar level: After eating, check your blood sugar level after 15-20 minutes and if it\'s still low, repeat the previous step' +
              '\nConsult your doctor: If you are experiencing symptoms of hypoglycemia, such as shakiness, dizziness, sweating, or confusion, or if you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nFollow your treatment plan: If you have diabetes or another condition that causes low blood sugar, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypoglycemia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. It\'s also important to carry with you, at all times, a form of glucose such as fruit juice, glucose gel or a candy, which can be used in case of an episode of low blood sugar.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature is low, also known as hypothermia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, including a hat and gloves, to help your body retain heat.' +
              '\nStay indoors: Stay indoors in a warm environment, if possible.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypothermia can be caused by underlying conditions such as anemia or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition and can be life-threatening if left untreated, so it is important to seek medical attention as soon as possible if you suspect you have hypothermia. You should also be mindful of the weather and dress appropriately when going outside during cold weather to prevent hypothermia.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your heart rate is low, also known as bradycardia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nMaintain a healthy lifestyle: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that bradycardia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of bradycardia, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure is low, also known as hypotension, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nStand up slowly: When you stand up, do it slowly to avoid feeling lightheaded or dizzy.' +
              '\nDrink more fluids: Drinking fluids, especially water, can help increase blood volume and raise blood pressure.' +
              '\nEat a healthy diet: Eating a diet rich in fruits, vegetables, and whole grains can help increase blood pressure.' +
              '\nExercise regularly: Regular exercise can help increase blood pressure and improve cardiovascular health.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypotension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of hypotension, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        }
      } else if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature has risen from low to normal, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate your heart rate has risen from low to normal, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      }
    } else if (low > normal && high == 0) {
      if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature has risen from low to normal, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate your heart rate has risen from low to normal, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood sugar level is low, also known as hypoglycemia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do.' +
              '\nEat a small snack: Eat a small snack that contains carbohydrates, such as fruit, crackers, or juice.' +
              '\nDrink a glass of juice or eat a piece of fruit: Eating a small snack that is high in sugar such as a candy bar, glucose gel, or a glass of fruit juice can help raise your blood sugar level quickly.' +
              '\nCheck your blood sugar level: After eating, check your blood sugar level after 15-20 minutes and if it\'s still low, repeat the previous step' +
              '\nConsult your doctor: If you are experiencing symptoms of hypoglycemia, such as shakiness, dizziness, sweating, or confusion, or if you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nFollow your treatment plan: If you have diabetes or another condition that causes low blood sugar, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypoglycemia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. It\'s also important to carry with you, at all times, a form of glucose such as fruit juice, glucose gel or a candy, which can be used in case of an episode of low blood sugar.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your body temperature is low, also known as hypothermia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, including a hat and gloves, to help your body retain heat.' +
              '\nStay indoors: Stay indoors in a warm environment, if possible.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypothermia can be caused by underlying conditions such as anemia or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition and can be life-threatening if left untreated, so it is important to seek medical attention as soon as possible if you suspect you have hypothermia. You should also be mindful of the weather and dress appropriately when going outside during cold weather to prevent hypothermia.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your heart rate is low, also known as bradycardia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nMaintain a healthy lifestyle: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that bradycardia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of bradycardia, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low. But recent readings indicate that your blood pressure is low, also known as hypotension, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nStand up slowly: When you stand up, do it slowly to avoid feeling lightheaded or dizzy.' +
              '\nDrink more fluids: Drinking fluids, especially water, can help increase blood volume and raise blood pressure.' +
              '\nEat a healthy diet: Eating a diet rich in fruits, vegetables, and whole grains can help increase blood pressure.' +
              '\nExercise regularly: Regular exercise can help increase blood pressure and improve cardiovascular health.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypotension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of hypotension, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        }
      }
    } else if (normal > high && low == 0) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are high, your blood sugar is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\n- It\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are high. ' +
              '. Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are higher,' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are high. Adopting healthy lifestyle habits such as not smoking, exercising and eating a healthy diet can help prevent and treat high blood pressure. Decreasing salt in your diet, ' +
              'losing weight if necessary, stopping smoking, cutting down on alcohol use, and regular exercise. because high blood pressure is a long-lasting medical condition that often has little or no symptoms, remembering to take your medications can be a challenge.' +
              ' Combination medicines, long-acting or once-a-day medications, may be used to decrease the burden of taking numerous medications and help ensure medications regularly. Once started, the medication should be used until your doctor tells you to stop.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "normal") {
        return 'Your readings have been stable and your health are good.\nEat healthy food and exercise every day for a healthy life.';
      }
    } else if (normal > low && high == 0) {
      if (lastCondition == "normal") {
        return 'Your readings have been stable and your health are good.\nEat healthy food and exercise every day for a healthy life.';
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate that your body temperature went from normal to low, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate your heart rate went from normal to low, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate that your blood pressure went from normal to low, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      }
    } else if (normal > high && normal > low) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are normal. But recent readings indicate that your blood sugar is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\n- It\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are normal. ' +
              'But recent readings indicate that Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are normal. But recent readings indicate that your heart beat rate are getting higher' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are normal. But recent readings indicate that your blood pressure are getting higher.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate that your body temperature went from normal to low, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate your heart rate went from normal to low, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal. But recent readings indicate that your blood pressure went from normal to low, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      } else if (lastCondition == "normal") {
        return 'Your readings have been stable and your health are good.\nEat healthy food and exercise every day for a healthy life.';
      }
    } else if (normal == high && low == 1) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are high and normal, also the recent record is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\n- It\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are high and normal. ' +
              '. Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are higher and normal,' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are high and normal. Adopting healthy lifestyle habits such as not smoking, exercising and eating a healthy diet can help prevent and treat high blood pressure. Decreasing salt in your diet, ' +
              'losing weight if necessary, stopping smoking, cutting down on alcohol use, and regular exercise. because high blood pressure is a long-lasting medical condition that often has little or no symptoms, remembering to take your medications can be a challenge.' +
              ' Combination medicines, long-acting or once-a-day medications, may be used to decrease the burden of taking numerous medications and help ensure medications regularly. Once started, the medication should be used until your doctor tells you to stop.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' records have been unstable. Most of the records indicate that your ' +
              type +
              ' level were high and normal ' +
              'But recent readings indicate that you start to recover and your blood sugar levels are getting normal.' +
              '\n\n What You Need To?' +
              '\nHere are a few things you can do' +
              '\n- Monitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nContinue a healthy diet: Eating a diet low in sugar and carbohydrates, and high in fiber and healthy fats can help maintain normal blood sugar levels.' +
              '\nExercise regularly: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood sugar levels, it is important to contact your doctor for further evaluation and advice.' +
              '\nAvoid triggers: Identify and avoid foods, drinks, or activities that may trigger high blood sugar level, such as eating too much sugar or carbohydrates, skipping meals, or not exercising regularly.' +
              '\nGet Regular checkup: Regularly monitoring your blood sugar levels and seeing your doctor for check-ups are important for controlling diabetes and preventing complications.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' readings were high and normal ' +
              'But recent readings indicate that your body temperature has returned to a normal range after being high, it is important to continue to take care of yourself to help prevent future fevers.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              'Rest: Continue to get plenty of rest to help your body recover from the underlying condition that caused the fever.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nTake care of the underlying condition: Follow your doctor\'s instructions for treating the underlying condition that caused the fever. This may include taking medication, undergoing further testing or follow-up visits.' +
              '\nFollow a healthy lifestyle: Eating a healthy diet, exercising regularly, and not smoking can help boost your immune system and improve your overall health.' +
              '\nGet enough sleep: Make sure you are getting enough sleep each night to help your body recover and stay healthy.' +
              '\nPractice good hygiene: Wash your hands regularly and keep your living space clean to help prevent the spread of germs and infection.' +
              '\nConsult your doctor: If you are experiencing recurring fevers or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate were high and normal ' +
              'But recent readings indicate that your heart rate has returned to a normal range after being high, it is important to continue with healthy habits to help prevent future episodes of tachycardia. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nIdentify triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nPractice relaxation techniques: Try to reduce stress and anxiety with techniques such as deep breathing, yoga, or meditation.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nContinue with your medications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\nIt is important to note that high heart rate could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your high heart rate and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of tachycardia.';
        } else if (type == "pressure") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and normal ' +
              'But recent readings indicate that your blood pressure has returned to a normal range after being high, it is important to continue with healthy habits to help maintain normal blood pressure and prevent future episodes of hypertension. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\n Monitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nTake your medication: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of high blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              'level were high and normal. But recent readings indicate that your blood sugar level has dropped from high to low, also known as hypoglycemia, it is important to take steps to raise it back to a healthy level. ' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nEat or drink something sweet: Consume a small amount of a quick-acting carbohydrate such as fruit juice, a regular soft drink, glucose gel or candy to raise your blood sugar level quickly.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nFollow a consistent meal plan: Eat regular, consistent meals and snacks to help prevent low blood sugar levels.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAvoid triggers: Identify and avoid foods, drinks, or activities that may trigger low blood sugar level, such as skipping meals, exercising heavily or taking more insulin than needed.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that if your blood sugar level drops too low and you are experiencing symptoms such as confusion, difficulty speaking, or unconsciousness, seek immediate medical attention. If you have recurrent episodes of hypoglycemia,' +
              ' it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and normal. But recent readings indicate that your body temperature has dropped from high to low, also known as hypothermia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nGet out of cold environment: If you\'re outside in cold weather, get indoors or to a warm shelter as soon as possible.' +
              '\nDress warmly: Put on warm clothing, including a hat and gloves to help your body retain heat.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble raising your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition that can occur when the body loses heat faster than it can produce heat, and if left untreated it can lead to serious complications, even death. It is crucial to seek medical attention if you suspect hypothermia, and to take preventive measures when in cold environments.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and normal. But recent readings indicate that  your heart rate has dropped from high to low, also known as bradycardia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as fatigue, lightheadedness, or fainting, or if you are having trouble raising your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause bradycardia, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If bradycardia is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nLifestyle changes: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that bradycardia could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your low heart rate and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of bradycardia.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              'were high and normal. But recent readings indicate that your blood pressure has dropped from high to low, also known as hypotension, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nSit down or lie down: If you feel lightheaded or dizzy, sit down or lie down to raise your blood pressure.' +
              '\nDrink fluids: Drink fluids, especially water, to help raise your blood pressure.' +
              '\nEat a small snack: Eating a small snack, such as a piece of fruit or crackers, can help raise your blood pressure.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or fatigue, or if you are having trouble raising your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause hypotension, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that hypotension could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your low blood pressure and receive appropriate treatment.';
        }
      }
    } else if (low == high && normal == 1) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that your blood sugar level has risen from low to high, it is important to take steps to bring it back to a healthy level.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood sugar level: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks to help prevent high blood sugar levels.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: High blood sugar can be caused by underlying conditions such as stress, infection, or changes in your medications, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that high blood sugar level can be a symptom of an underlying condition, such as diabetes, so it is important to consult your doctor to determine the cause of your high blood sugar level and receive appropriate treatment. Maintaining a healthy lifestyle and following your doctor\'s instructions will help you to prevent future episodes of high blood sugar level.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that your body temperature has risen from low to high, it\'s important to take steps to bring it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              'Dress warmly: Put on warm clothing, including a hat and gloves to help your body retain heat.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that low or high body temperature can be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your temperature changes and receive appropriate treatment. If your temperature goes from low to high, it may be indicating a fever, which is a symptom of an infection or illness, and if it goes from high to normal, it may indicate that the body is fighting off the infection or illness and returning to a healthy state.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that If your heart rate has risen from low to high, it\'s important to take steps to bring it back to a normal range..' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low or high heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Low or high heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nLifestyle changes: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate, and follow your doctor\'s instructions.' +
              '\n\nIt is important to note that low or high heart rate could be a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your heart rate changes and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that your blood pressure has risen from low to high, it\'s important to take steps to bring it back to a normal range. High blood pressure, also known as hypertension, is a serious condition that can lead to heart disease, stroke, and other health problems' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt, getting regular exercise, maintaining a healthy weight, and not smoking can help lower your blood pressure and improve your overall health.' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypertension or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nAddress underlying conditions: High blood pressure can be caused by underlying conditions such as kidney disease or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypertension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If your blood pressure goes from low to high, it is important to consult your doctor to determine the cause of this change.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and low. But recent readings indicate that your blood sugar level is low, also known as hypoglycemia, it is important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do.' +
              '\nEat a small snack: Eat a small snack that contains carbohydrates, such as fruit, crackers, or juice.' +
              '\nDrink a glass of juice or eat a piece of fruit: Eating a small snack that is high in sugar such as a candy bar, glucose gel, or a glass of fruit juice can help raise your blood sugar level quickly.' +
              '\nCheck your blood sugar level: After eating, check your blood sugar level after 15-20 minutes and if it\'s still low, repeat the previous step' +
              '\nConsult your doctor: If you are experiencing symptoms of hypoglycemia, such as shakiness, dizziness, sweating, or confusion, or if you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nFollow your treatment plan: If you have diabetes or another condition that causes low blood sugar, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypoglycemia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. It\'s also important to carry with you, at all times, a form of glucose such as fruit juice, glucose gel or a candy, which can be used in case of an episode of low blood sugar.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and low. But recent readings indicate that your body temperature is low, also known as hypothermia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, including a hat and gloves, to help your body retain heat.' +
              '\nStay indoors: Stay indoors in a warm environment, if possible.' +
              '\nUse a heating pad or take a warm bath: Apply a heating pad or take a warm bath to help raise your body temperature.' +
              '\nDrink warm fluids: Drink warm fluids such as soup, tea or coffee to help warm your body from the inside.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypothermia, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypothermia can be caused by underlying conditions such as anemia or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that hypothermia is a serious condition and can be life-threatening if left untreated, so it is important to seek medical attention as soon as possible if you suspect you have hypothermia. You should also be mindful of the weather and dress appropriately when going outside during cold weather to prevent hypothermia.';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and low. But recent readings indicate that your heart rate is low, also known as bradycardia, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nConsult your doctor: If you are experiencing symptoms of bradycardia, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nReview your medications: Some medications can cause low heart rate, so it is important to review all medications you are taking with your doctor and make sure you are taking them as prescribed.' +
              '\nAddress underlying conditions: Bradycardia can be caused by underlying conditions such as heart disease or hypothyroidism, so it\'s important to address these conditions as well.' +
              '\nUse a pacemaker: If your low heart rate is caused by an abnormal conduction of the electrical signals in your heart, your doctor may suggest a pacemaker, a small device that\'s implanted under the skin of your chest to help regulate your heartbeat.' +
              '\nMaintain a healthy lifestyle: Maintaining a healthy lifestyle, eating a healthy diet, exercising regularly, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that bradycardia requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of bradycardia, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were high and low. But recent readings indicate that your blood pressure is low, also known as hypotension, it\'s important to take steps to raise it back to a normal range.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nStand up slowly: When you stand up, do it slowly to avoid feeling lightheaded or dizzy.' +
              '\nDrink more fluids: Drinking fluids, especially water, can help increase blood volume and raise blood pressure.' +
              '\nEat a healthy diet: Eating a diet rich in fruits, vegetables, and whole grains can help increase blood pressure.' +
              '\nExercise regularly: Regular exercise can help increase blood pressure and improve cardiovascular health.' +
              '\nConsult your doctor: If you are experiencing symptoms of hypotension, such as lightheadedness, fainting, or chest pain, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Hypotension can be caused by underlying conditions such as anemia or diabetes, so it\'s important to address these conditions as well.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that hypotension requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan. If you have symptoms of hypotension, it\'s important to consult your doctor to determine the cause and receive appropriate treatment.';
        }
      } else if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that your body temperature has risen from low to normal, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate your heart rate has risen from low to normal, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and high. But recent readings indicate that your blood pressure has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      }
    } else if (normal == low && high == 1) {
      if (lastCondition == "high") {
        if (type == "Blood sugar") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' are normal and low. But recent readings indicate that your blood sugar is high, it is important to take steps to bring it down to a healthy level. ' +
              '\n What You Need To Do?' +
              '\nHere are a few things you can do:' +
              '\nCall the emergency 998 or visit your healthcare provider for an immediate act' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nAdjust your diet: Eating a diet low in sugar and carbohydrates can help lower blood sugar levels. Additionally, eating more fiber and healthy fats can also help.' +
              '\nExercise: Physical activity helps to lower blood sugar levels by increasing insulin sensitivity and helping your body to use glucose more effectively.' +
              '\nMedication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor. If your blood sugar remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult with your doctor: If you are experiencing symptoms of high blood sugar, such as frequent urination or blurred vision, or if you are having trouble controlling your blood sugar, it is important to contact your doctor for further evaluation and advice.' +
              '\nDrink water: Drinking water can help flush out excess glucose in the body.' +
              '\n\n- It\'s important to note that if your blood sugar level is very high and you are experiencing symptoms such as confusion, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "Temperature") {
          return 'Your ' +
              type +
              ' recocds have been unstable. Most of the records indicate that your body ' +
              type +
              ' are normal and low. ' +
              'But recent readings indicate that Your body temperature start rising in the recent record. It could be caused by fever' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Your body needs energy to fight off an infection or illness, so it\'s important to get plenty of rest.' +
              '\nStay hydrated: Drink plenty of water, juice, or clear broths to help keep your fluids up.' +
              '\nDress lightly: Wear lightweight, breathable clothing to help keep your body cool.' +
              '\nUse a cool compress: Placing a cool, damp cloth on your forehead or other pulse points can help lower your body temperature.' +
              '\nStay in a cool place: Try to stay in a room with air conditioning or a fan to help keep your body temperature down.' +
              '\nIf your fever is high, and you have difficulty breathing, chest pain, or you are feeling confused, seek medical attention right away.' +
              '\n\nIt\'s important to note that a fever is a symptom of an underlying condition, so it is important to consult your doctor to determine the cause of your fever and receive appropriate treatment.';
        } else if (type == "Heart beat") {
          return 'Your ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' rate are normal and low. But recent readings indicate that your heart beat rate are getting higher' +
              'An increased heart rate isn\'t always a problem. It\'s normal for your heart rate to increase during exercise or in response to stress.\n' +
              '\n\n What You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nRest: Sit or lie down and take deep breaths to calm yourself.' +
              '\nTry to relax: Practice deep breathing, yoga, or meditation to help reduce stress and anxiety.' +
              '\nStay hydrated: Drink plenty of water and avoid caffeine and alcohol, which can increase heart rate.' +
              '\nAvoid triggers: Identify and avoid any triggers that may cause your heart rate to increase, such as smoking, physical or emotional stress.' +
              '\nMedications: If you are taking medication for a heart condition, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are experiencing symptoms of high heart rate, such as chest pain, shortness of breath, or lightheadedness, or if you are having trouble controlling your heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\n\nIf your heart rate is very high and you are experiencing symptoms such as chest pain, difficulty breathing, or unconsciousness, seek immediate medical attention.';
        } else if (type == "pressure") {
          return 'Your Blood ' +
              type +
              'recocds have been unstable. Most of the records indicate that your ' +
              type +
              ' level are normal and low. But recent readings indicate that your blood pressure are getting higher.' +
              '\n\n What You Need To Do? ' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMake lifestyle changes: Eating a healthy diet low in salt and saturated fat, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure.' +
              '\nReduce stress: Chronic stress can contribute to high blood pressure, so try to find ways to manage stress, such as practicing relaxation techniques like yoga or meditation.' +
              '\nMedications: If you are taking medication for hypertension, make sure you are taking it as prescribed by your doctor. If your blood pressure remains high despite making lifestyle changes, you may need to adjust your medication regimen.' +
              '\nConsult your doctor: If you are experiencing symptoms of high blood pressure, such as headaches, or if you are having trouble controlling your blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is high, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\n\nIt\'s important to note that if your blood pressure is very high and you are experiencing symptoms such as severe headache, blurred vision, nausea or vomiting, seek immediate medical attention.';
        }
      } else if (lastCondition == "low") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal and low. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal and low. But recent readings indicate that your body temperature went from normal to low, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal and low. But recent readings indicate your heart rate went from normal to low, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were normal and low. But recent readings indicate that your blood pressure went from normal to low, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      } else if (lastCondition == "normal") {
        if (type == "Blood sugar") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and normal. But recent readings indicate that your blood sugar level has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood sugar levels and prevent future episodes of hypoglycemia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nFollow a consistent meal plan: Eating regular, consistent meals and snacks can help prevent low blood sugar levels.' +
              '\nMonitor your blood sugar: Keep track of your blood sugar levels to see how they are changing over time.' +
              '\nTake your medication: If you are taking medication for diabetes, make sure you are taking it as prescribed by your doctor.' +
              '\nConsult your doctor: If you are having trouble controlling your blood sugar level, it is important to contact your doctor for further evaluation and advice.' +
              '\nAddress underlying conditions: Low blood sugar can be caused by underlying conditions such as diabetes, so it\'s important to address these conditions as well.' +
              '\nMake lifestyle changes: Eating a healthy diet, exercising regularly, and not smoking can help lower your risk of diabetes and improve your overall health.' +
              '\nKeep monitoring: Keep monitoring your blood sugar levels and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood sugar levels requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "Temperature") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and normal. But recent readings indicate that your body temperature has risen from low to normal, it is important to maintain healthy habits to help maintain normal body temperature and prevent future episodes of hypothermia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nDress warmly: Wear warm clothing, especially in cold weather, to help your body retain heat.' +
              '\nStay hydrated: Drinking fluids, especially water, can help regulate body temperature.' +
              '\nAvoid cold environments: Avoid spending too much time in cold environments, such as air conditioning, cold water, and cold weather.' +
              '\nConsult your doctor: If you are experiencing symptoms of low or high body temperature, such as shivering, drowsiness, confusion or slow breathing, or if you are having trouble controlling your body temperature, it is important to contact your doctor for further evaluation and advice.' +
              '\nKeep Monitoring: Keep monitoring your body temperature to detect any further changes in temperature and seek medical attention if your temperature does not return to normal or if you have other symptoms such as numbness, blue lips or skin, or difficulty breathing.' +
              '\n\nIt\'s important to note that maintaining normal body temperature requires a combination of healthy habits and addressing underlying conditions, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.' +
              ' for your health you better visit your health care provider or call the emergency 998.\n';
        } else if (type == "Heart beat") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and normal. But recent readings indicate your heart rate has risen from low to normal, it is important to maintain healthy habits to help maintain normal heart rate and prevent future episodes of bradycardia.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nExercise regularly: Regular physical activity can help increase your heart rate and improve cardiovascular health.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, maintaining a healthy weight, and not smoking can help lower your risk of heart disease and improve your overall health.' +
              '\nAddress underlying conditions: Low heart rate can be caused by underlying conditions such as heart disease, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal heart rate or if you are experiencing symptoms of low heart rate, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your heart rate is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your heart rate to detect any further changes in heart rate levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal heart rate requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        } else if (type == "pressure") {
          return 'Your last ' +
              type +
              ' readings have been unstable. Most of the records indicate that your ' +
              type +
              ' were low and normal. But recent readings indicate that your blood pressure has risen from low to normal, it is important to maintain healthy habits to help maintain normal blood pressure levels and prevent future episodes of hypotension.' +
              '\n\nWhat You Need To Do?' +
              '\nHere are a few things you can do' +
              '\nMonitor your blood pressure: Keep track of your blood pressure readings to see how they are changing over time.' +
              '\nMaintain a healthy lifestyle: Eating a healthy diet, getting regular exercise, maintaining a healthy weight, and not smoking can help lower blood pressure and maintain normal levels.' +
              '\nAddress underlying conditions: Low blood pressure can be caused by underlying conditions such as anemia, so it\'s important to address these conditions as well.' +
              '\nConsult your doctor: If you are having trouble maintaining normal blood pressure or if you are experiencing symptoms of low blood pressure, it is important to contact your doctor for further evaluation and advice.' +
              '\nFollow your treatment plan: If your blood pressure is low, it is important to follow your doctor\'s treatment plan, which may include lifestyle changes and medications.' +
              '\nKeep monitoring: Keep monitoring your blood pressure to detect any further changes in blood pressure levels, and follow your doctor\'s instructions.' +
              '\n\nIt\'s important to note that maintaining normal blood pressure requires a combination of lifestyle changes and medications, so it is important to work closely with your healthcare provider to develop an appropriate treatment plan.';
        }
      }
    }
  }
}

// model for the column chart
class _ChartData {
  _ChartData(this.time_x, this.readings_y);
  final String time_x;
  final int readings_y;
}
