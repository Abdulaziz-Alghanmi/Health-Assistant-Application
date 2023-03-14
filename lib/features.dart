import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:healthassistant/Chat.dart';
import 'package:healthassistant/profile.dart';
import 'package:healthassistant/grahps.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthassistant/sqldb.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:healthassistant/PdfParagraphApi.dart';
import 'package:url_launcher/url_launcher.dart';

class features extends StatefulWidget {
  @override
  State<features> createState() => _featuresState();
}

class _featuresState extends State<features> {
  String profile = "assets/prof.png";
  String bmi = "assets/bmi.png";
  String BS = "assets/bs.png";
  String BP = "assets/bp.png";
  String water = "assets/LW.png";
  String walk = "assets/km.png";
  String HB = "assets/hb.png";
  String temp = "assets/temp.png";
  String set = "assets/set.png";
  String yn = "assets/YN.png";
  String pl = "assets/pl.png";
  String sl = "assets/sleep.png";

  List<String> scrol = [
    "assets/temp.png",
    "assets/hb.png",
    "assets/bs.png",
    "assets/bp.png",
    "assets/YN.png",
    "assets/prof.png",
    "assets/set.png",
  ];
  List<String> scrol1 = [
    "assets/temp.png",
    "assets/hb.png",
    "assets/bs.png",
    "assets/bp.png",
    "assets/YN.png",
    "assets/prof.png",
    "assets/set.png",
  ];
  List<String> scrol2 = [
    "assets/pl.png",
    "assets/km.png",
    "assets/LW.png",
    "assets/bmi.png",
    "assets/sleep.png",
    "assets/prof.png",
    "assets/set.png",
  ];

  DatabaseReference tempRef = FirebaseDatabase.instance.ref().child('temp');
  DatabaseReference hbRef = FirebaseDatabase.instance.ref().child('hb');
  DatabaseReference idRef = FirebaseDatabase.instance.ref().child('id');

  var habox = Hive.box('mybox');

//List for saving the values of each type or readings and then send it to graphs Class for viewing te grahps
  //here is the var that will save the current value and add it to its corrosponding List
  String tempCurrData = "0";
  String hbCurrData = "0";
  String idFromFireBase = "0";
  SqlDb sqlDb = SqlDb();
  List<dynamic> response;
  List<dynamic> list;
  int id;
  String switcher = "first";
  ChatState chat = ChatState();

  void initProfile() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    response = await sqlDb.readData("SELECT * FROM 'profile'");
  }

  //Method for fetching the temp and hb from Firebase
  String fetchTemp() {
    tempRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      tempCurrData = data.toString();
    });
    return tempCurrData;
  }

  String fetchHeartBeat() {
    hbRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      hbCurrData = data.toString();
    });
    return hbCurrData;
  }

  String fetchId() {
    idRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      idFromFireBase = data.toString();
    });
    return idFromFireBase;
  }

  // For using speak method
  void firstInit() async {
    await initProfile();
  }

  @override
  Widget build(BuildContext context) {
    firstInit();
    fetchTemp();
    fetchHeartBeat();
    fetchId();
    final _idController = TextEditingController(
        text: habox.get("id").toString() == "100000000"
            ? ""
            : habox.get("id").toString()); // The device id in the setting
    //final _formKey = GlobalKey<FormState>();
    bool isSwitched;
    if (habox.get("tts") == null) {
      isSwitched = true;
      habox.put("tts", true);
    } else {
      isSwitched = habox.get("tts");
      print(isSwitched);
    }

    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
      height: 170,
      width: double.infinity,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...(scrol
              .map((e) => Container(
                    width: 150,
                    child: InkWell(
                      onTap: () {
                        int age;
                        double height;
                        double weight;
                        try {
                          age = response[0]['age'];
                          height = response[0]['height'] / 100;
                          weight = response[0]['weight'];
                        } catch (e) {
                          print(e);
                        }
                        /**navegate to profile interface */
                        if (e == profile) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PersonalInfoForm()));
                          /**calculate the bmi */
                        } else if (e == set) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  backgroundColor:
                                      Color.fromARGB(255, 224, 224, 224),
                                  title: const Text('Settings',
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0))),
                                  content: StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return Container(
                                      color: Color.fromARGB(255, 224, 224, 224),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              2.5,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            "ID",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 25),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 200,
                                            height: 40,
                                            child: TextFormField(
                                              decoration: InputDecoration(
                                                hintText: 'Device ID',
                                                hintStyle: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 231, 231, 231),
                                                    fontSize: 15),
                                                filled: true,
                                                fillColor: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    width: 5.0,
                                                  ),
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: _idController,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                              onSaved: (value) =>
                                                  id = int.parse(value),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text("TextToSpeech",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 25)),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Switch(
                                            value: isSwitched,
                                            onChanged: (value) {
                                              setState(() {
                                                isSwitched = value;
                                                print(isSwitched);
                                              });
                                            },
                                            activeTrackColor: Color.fromARGB(
                                                255, 62, 79, 136),
                                            activeColor:
                                                Color.fromARGB(255, 0, 34, 146),
                                            inactiveTrackColor: Colors.grey,
                                            inactiveThumbColor: Colors.grey,
                                          ),
                                          TextButton(
                                            child: Text(
                                                "Health Assistant website"),
                                            onPressed: () {
                                              launch(
                                                  "https://health-assistant1.github.io/Web-Site/");
                                            },
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (_idController.text
                                                      .toString()
                                                      .trim() ==
                                                  "") {
                                                id = 100000000;
                                              } else {
                                                id = int.parse(_idController
                                                    .text
                                                    .toString()
                                                    .trim());
                                              }
                                              setState(
                                                () {
                                                  habox.put("id", id);
                                                  habox.put("tts", isSwitched);
                                                  sqlDb.updateData(
                                                      "UPDATE profile SET 'id' = '$id'");
                                                  Navigator.of(context).pop();
                                                  initProfile();
                                                },
                                              );
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }));
                            },
                          );
                        } else if (e == yn) {
                          setState(() {
                            scrol = scrol2;
                          });
                        } else if (e == temp) {
                          Recoreds('Temperature');
                        } else if (e == HB) {
                          Recoreds('Heart beat');
                        } else if (e == BS) {
                          Recoreds('Blood sugar');
                        } else if (e == BP) {
                          Recoreds('pressure');
                        } else if (e == bmi) {
                          double result = weight / (height * height);
                          String category = "";
                          if (result < 18.5) {
                            category = "Underweight";
                          }
                          if (result > 18.5 && result < 25.9) {
                            category = "Normal";
                          }
                          if (result > 25.0 && result < 39.9) {
                            category = "Overweight";
                          }
                          if (result > 40.0) {
                            category = "Obese";
                          }
                          String massage = "Your BMI is " +
                              result.toStringAsFixed(2) +
                              " and it's " +
                              category;
                          featuresDialog(massage);
                        } else if (e == walk) {
                          String message = "";
                          if (age <= 30) {
                            message =
                                "You need to walk 1.5km in 18 minutes and 45 seconds, \nor walk 3km in 37 minutes 30 seconds, or 5km in 1 hour";
                          } else if (age > 30 && age <= 49) {
                            message =
                                "You need to walk 1.5km in 20 minutes, or walk 3km in 40 minutes or 5km in 1 hour and 10 minutes";
                          } else if (age > 49 && age <= 59) {
                            message =
                                "You need to walk 1.5km in 21 minutes, or walk 3km in 41 minutes or 5km in 1 hour and 10 minutes";
                          } else if (age > 59 && age <= 65) {
                            message =
                                "You need to walk 1.5km in 22 minutes, or walk 3km in 42 minutes or 5km in 1 hour and 11 minutes";
                          } else if (age > 65) {
                            message =
                                "You need to walk 1.5km in 27 minutes, or walk 3km in 53 minutes or 5km in 1 hour and 30 minutes";
                          }
                          featuresDialog(message);
                        } else if (e == water) {
                          String message = "";
                          if (age > 3 && age <= 8) {
                            message =
                                "You need to Drink 1 Liter of water per day, to stay hydrated";
                          } else if (age > 8 && age <= 13) {
                            message =
                                "You need to Drink 1.6 to 1.9 Liter of water per day, to stay hydrated";
                          } else if (age > 13 && age <= 18) {
                            message =
                                "You need to Drink 1.9 to 2.5 Liter of water per day, to stay hydrated";
                          } else if (age >= 18) {
                            message =
                                "You need to Drink 2.5 to 3 Liter of water per day, to stay hydrated";
                          }

                          featuresDialog(message);
                        } else if (e == pl) {
                          setState(() {
                            scrol = scrol1;
                          });
                        } else if (e == sl) {
                          String message = "";
                          if (age > 2 && age <= 5) {
                            message =
                                "You need to sleep 10 to 13 hours for good health and well-being.";
                          } else if (age > 5 && age <= 12) {
                            message =
                                "You need to sleep 9 to 12 hours for good health and well-being.";
                          } else if (age > 12 && age <= 18) {
                            message =
                                "You need sleep 8 to 10 hours for good health and well-being.";
                          } else if (age > 18 && age <= 60) {
                            message =
                                "You need sleep 7 or more hours per night hours for good health and well-being.";
                          } else if (age > 60 && age <= 64) {
                            message =
                                "You need sleep 7 to 9 hours for good health and well-being.";
                          } else if (age > 64) {
                            message =
                                "You need sleep 7 to 8 hours for good health and well-being.";
                          }

                          featuresDialog(message);
                        }
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Color.fromARGB(255, 165, 165, 165),
                                spreadRadius: 0,
                                blurRadius: 5)
                          ],
                          //border: Border.all(),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Image.asset(e),
                      ),
                    ),
                  ))
              .toList())
        ],
      ),
    );
  }

  void initList(String type) async {
    list =
        await sqlDb.readData("Select * FROM 'vitalSigns' WHERE type = '$type'");
    print(list.length);
  }

  Widget featuresDialog(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              backgroundColor: Color.fromARGB(255, 66, 92, 131),
              content: Text(
                message,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ));
        });
    chat.speak(message);
  }

  Widget Recoreds(String type) {
    initList(type);
    String vital = "";
    TextEditingController Svital = TextEditingController();
    TextEditingController Dvital = TextEditingController();
    try {
      switch (type) {
        case 'Temperature':
          if (response[0]['id'].toString() == fetchId()) {
            vital = fetchTemp();
          } //Temp value
          break;
        case 'Heart beat':
          if (response[0]['id'].toString() == fetchId()) {
            vital = fetchHeartBeat();
          } //HB value
          break;
      }
    } catch (e) {
      print(e);
    }
    TextEditingController value = TextEditingController(); //Text field value.
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => SingleChildScrollView(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: type == "pressure"
              ? MediaQuery.of(context).size.height * 0.40
              : MediaQuery.of(context).size.height * 0.25,
          color: Color.fromARGB(255, 66, 92, 131),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                type == "pressure"
                    ? Container(
                        padding: EdgeInsets.only(top: 20),
                        width: 350,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Systolic blood pressure',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 196, 196, 196)),
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              controller: Svital..text = vital,
                              style:
                                  TextStyle(fontSize: 30, color: Colors.black),
                            ),
                            Text(
                              "/",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Diastolic blood pressure',
                                hintStyle: TextStyle(
                                    color: Color.fromARGB(255, 196, 196, 196)),
                                filled: true,
                                fillColor: Color.fromARGB(255, 255, 255, 255),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              controller: Dvital..text = vital,
                              style:
                                  TextStyle(fontSize: 30, color: Colors.black),
                            )
                          ],
                        ))
                    : Container(
                        padding: EdgeInsets.only(top: 20),
                        width: 350,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'example: 50',
                            hintStyle: TextStyle(
                                color: Color.fromARGB(255, 231, 231, 231)),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 255, 255, 255),
                                width: 1.0,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: value..text = vital.toString(),
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        ),
                      ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    type == "pressure"
                        ? ElevatedButton(
                            onPressed: () {
                              if (Svital.text.isEmpty || Dvital.text.isEmpty) {
                                errDialog('EmptyType', list, type);
                              } else if (list.length < 7) {
                                double Sval = double.parse(Svital.text.trim());
                                double Dval = double.parse(Dvital.text.trim());
                                String date = DateFormat.yMEd()
                                    .add_jm()
                                    .format(DateTime.now())
                                    .toString();
                                if (validPressure(Sval, Dval) == "valid") {
                                  sqlDb.insertData(
                                      "INSERT INTO 'vitalSigns' ('SystolicRecored','DiastolicRecored','date','type') VALUES ('$Sval','$Dval','$date','$type') ");
                                  initList(type);
                                  Svital.clear();
                                  Dvital.clear();
                                } else {
                                  Svital.clear();
                                  Dvital.clear();
                                  errDialog('notValid', list, type);
                                }
                              } else {
                                errDialog('newRecord', list, type);
                              }
                            },
                            child: Text('Save Record'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 94, 130, 185),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              if (value.text.isEmpty) {
                                errDialog('EmptyType', list, type);
                              } else if (list.length < 7) {
                                try {
                                  double val = double.parse(value.text.trim());
                                  String date = DateFormat.yMEd()
                                      .add_jm()
                                      .format(DateTime.now())
                                      .toString();
                                  sqlDb.insertData(
                                      "INSERT INTO 'vitalSigns' ('recored','date','type') VALUES ('$val','$date','$type') ");
                                  initList(type);
                                  value.clear();
                                } on FormatException catch (e) {
                                  errDialog('notValid', list, type);
                                }
                              } else {
                                errDialog('newRecord', list, type);
                              }
                            },
                            child: Text('Save Record'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 94, 130, 185),
                            ),
                          ),
                    // Right button
                    ElevatedButton(
                        onPressed: () {
                          initList(type);
                          if (!list.isEmpty) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return grahps(list, type);
                            }));
                          } else {
                            errDialog('listEmpty', list, type);
                          }
                        },
                        child: Text('Show Record'),
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            backgroundColor: Color.fromARGB(255, 85, 118, 167),
                            minimumSize: Size(140, 40),
                            elevation: 10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (habox.get("show") == null) {
      habox.put("show", false);
    }
    if (habox.get("show") != true) {
      if (type == "Blood sugar") {
        SugarAdviceDialog();
      }
    }
  }

  String validPressure(double Sval, double Dval) {
    for (int i = 0; i < 3; i++) {
      if (90 <= Sval && Sval <= 120 && 60 <= Dval && Dval <= 80) {
        return "valid";
      } else if (Sval > 120 && Dval > 80) {
        return "valid";
      } else if (Sval < 90 && Dval < 60) {
        return "valid";
      } else {
        return "notValid";
      }
    }
  }

  void SugarAdviceDialog() async {
    bool show = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Color.fromARGB(255, 224, 224, 224),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                color: Color.fromARGB(255, 224, 224, 224),
                height: MediaQuery.of(context).size.height / 5.5,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "It is preferable to fast for 8 to 12 hour before blood sugar analysis for accurate result.",
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Don't show again?",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 73, 81, 124),
                          ),
                        ),
                        Checkbox(
                          visualDensity: VisualDensity(
                              horizontal: VisualDensity.maximumDensity),
                          value: show,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          activeColor: Color.fromARGB(255, 73, 81, 124),
                          checkColor: Color.fromARGB(255, 255, 255, 255),
                          side: BorderSide(
                            color: Color.fromARGB(255, 73, 81, 124),
                            width: 1,
                          ),
                          onChanged: (bool value) {
                            setState(() {
                              if (show == false) {
                                show = true;
                                habox.put("show", true);
                              } else {
                                show = false;
                                habox.put("show", false);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }));
      },
    );
  }

  void errDialog(String errType, List<dynamic> list, String type) {
    String err = "Please insert a value";
    String lock = "noLock";
    switch (errType) {
      case 'newRecord':
        err =
            "You reached the maximum number of readings per Record if you want to create new Record Press Yes.\nYou can save your recored before pressing yes";
        lock = "lock";
        break;
      case 'notValid':
        err = "The records you entered are not valid";
        break;
      case 'listEmpty':
        err = "You dont have any record yet to show";
        break;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(
            err,
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          actions: [
            ElevatedButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            lock == "lock"
                ? ElevatedButton(
                    child: Text("SavePDF"),
                    onPressed: () {
                      PdfParagraphApi(list, type);
                    },
                  )
                : ElevatedButton(
                    child: Text("SavePDF"),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 160, 160, 160), // background (button) color
                      foregroundColor: Color.fromARGB(
                          255, 82, 82, 82), // foreground (text) color
                    ),
                  ),
            lock == "lock"
                ? ElevatedButton(
                    child: Text("Yes"),
                    onPressed: () {
                      initList(type);
                      setState(() {
                        String type = list[0]['type'];
                        sqlDb.deleteData(
                            "DELETE FROM 'vitalSigns' WHERE type='$type'");
                        //list.clear();
                        Navigator.of(context).pop();
                        initList(type);
                      });
                    },
                  )
                : ElevatedButton(
                    child: Text("Yes"),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(
                          255, 160, 160, 160), // background (button) color
                      foregroundColor: Color.fromARGB(
                          255, 82, 82, 82), // foreground (text) color
                    )),
          ],
        );
      },
    );
  }
}
