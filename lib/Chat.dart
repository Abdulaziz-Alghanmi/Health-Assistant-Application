import 'dart:io';
import 'dart:math';
import 'package:healthassistant/sqldb.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => ChatState();
}

const languages = const [
  const Languages('English', 'en_US'),
];

class Languages {
  final String name;
  final String code;
  const Languages(this.name, this.code);
}

class ChatState extends State<Chat> {
  final FlutterTts flutterTts = FlutterTts(); //for speach
  final TextEditingController textEditingController =
      TextEditingController(); //for speachToText
  List<dynamic> response; //SQL list
  SqlDb sqlDb = SqlDb(); //sql class
  var habox = Hive.box('mybox');
  String userName;
  bool diabetes = false;
  bool obesity = false;
  bool asthma = false;
//
  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  String transcription = '';
  String _currentLocale = 'en_US';
  Languages selectedLang = languages.first;

  @override
  initState() {
    super.initState();
    activateSpeechRecognizer();
  }

  void activateSpeechRecognizer() {
    print('_ChatState.activateSpeechRecognizer... ');
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('en_US').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  void _selectLangHandler(Languages lang) {
    setState(() => selectedLang = lang);
  }

  void start() => _speech.activate(selectedLang.code).then((_) {
        return _speech.listen().then((result) {
          print('_ChatState.start => result $result');
          setState(() {
            _isListening = result;
          });
        });
      });

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_ChatState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  void onRecognitionResult(String text) {
    print('_ChatState.onRecognitionResult... $text');
    setState(() => transcription = text);
  }

  void onRecognitionComplete(String text) {
    print('_ChatState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  void errorHandler() => activateSpeechRecognizer();

  void botResponse(String query) async {
    //where the response happen
    AuthGoogle authGoogle = await AuthGoogle(
            fileJson: "assets/health-assistant-qcmw-c10c92ae16c9.json")
        .build();
    Dialogflow dialogflow =
        Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse aiResponse = await dialogflow.detectIntent(query);

    setState(() {
      messsages.insert(0, {
        "data": 0,
        "message": aiResponse.getListMessage()[0]["text"]["text"][0].toString()
      });
      speak(aiResponse.getListMessage()[0]["text"]["text"][0].toString());
    });
  }

//speak the response
  void speak(String words) async {
    //print(habox.get("tts"));
    if (habox.get("tts") == true) {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.setVolume(1.0);
      await flutterTts.speak(words);
    }
  }

  final messageInsert = TextEditingController();
  List<Map> messsages = List();

  int randomInt(int i) {
    var random = new Random();
    var number = random.nextInt(i) + 1;
    return number;
  }

  int i = 0;
  void firstcall() async {
    String date = DateFormat.d().format(DateTime.now()).toString().trim();
    if (habox.get("today") == null) {
      habox.put("today", date);
    }
    if (i == 0) {
      setState(() {
        messsages.insert(0, {
          "data": 0,
          "message": "You can visit Health Assistant website from setting"
        });
      });
      i++;
    }
    await initSql();
    String send;
    if (habox.get("today").toString().trim() != date) {
      switch (randomInt(3)) {
        case 1:
          switch (randomInt(5)) {
            case 1: //water advices
              send =
                  ("Hi $userName, Don't forget to drink the amount your body need from water because water helps to improve metabolism, helps to improve sleep and helps to improve overall physical and mental well-being.");
              break;
            case 2:
              send =
                  ("Hi $userName, Don't forget to drink the amount your body need from water because water lubricates joints, keeps respiratory system healthy and Helps to prevent constipation.");
              break;
            case 3:
              send =
                  ("Hi $userName, Don't forget to drink the amount your body need from water because water helps to prevent urinary tract infections, helps to prevent kidney stones and helps to prevent dry mouth and bad breath.");
              break;
            case 4:
              send =
                  ("Hi $userName, Don't forget to drink the amount your body need from water because water helps to support the immune system, helps to prevent heat stroke and helps to regulate blood pressure.");
              break;
            case 5:
              send =
                  ("Hi $userName, Don't forget to drink the amount your body need from water because water helps to prevent cramps and sprains, aids in digestion and flushes out toxins from the body.");
              break;
          }
          break;
        case 2:
          switch (randomInt(1)) {
            case 1: //walking
              send =
                  ("Hi $userName, Did you walk today ?\nwalking improves cardiovascular health, helps to lower blood pressure and helps to lower cholesterol levels.");
              break;
            case 2:
              send =
                  ("Hi $userName, Did you walk today ?\nwalking helps to control diabetes, helps to prevent or manage heart disease and helps to improve circulation.");
              break;
            case 3:
              send =
                  ("Hi $userName, Did you walk today ?\nwalking helps to strengthen bones, helps to improve balance and coordination and helps to reduce stress.");
              break;
            case 4:
              send =
                  ("Hi $userName, Did you walk today ?\nwalking helps to improve lung function, helps to improve flexibility and range of motion and helps to reduce risk of falls in older adults.");
              break;
            case 5:
              send =
                  ("Hi $userName, Did you walk today ?\nwalking helps to improve sleep, helps to increase energy levels and helps to boost immune system.");
              break;
          }
          break;
        case 3:
          bool stop = true;
          for (int i = 0; i < 10; i++) {
            switch (randomInt(4)) {
              case 1:
                if (diabetes == true) {
                  switch (randomInt(4)) {
                    case 1:
                      send =
                          ("Hi $userName, diabetes will change your lifestyle so if you didn't take your medicine or monitor your blood sugar levels regularly you might get heart disease, nerve damage and more. So you better, avoid foods high in sugar and saturated fats, control your portion sizes to maintain healthy weight and be physically active for at least 30 minutes each day.");
                      break;
                    case 2:
                      send =
                          ("Hi $userName, diabetes will change your lifestyle so if you didn't take your medicine or monitor your blood sugar levels regularly you might get heart disease, nerve damage and more. So you better, follow a healthy and balanced diet, with emphasis on fruits, vegetables, whole grains, and lean proteins, stop smoking, if you do and educate yourself about diabetes and how to manage it.");
                      break;
                    case 3:
                      send =
                          ("Hi $userName, diabetes will change your lifestyle so if you didn't take your medicine or monitor your blood sugar levels regularly you might get heart disease, nerve damage and more. So you better, work with your healthcare provider to establish blood sugar targets, learn how to adjust your insulin doses based on your blood sugar levels and learn how to recognize the symptoms of low blood sugar.");
                      break;
                    case 4:
                      send =
                          ("Hi $userName, diabetes will change your lifestyle so if you didn't take your medicine or monitor your blood sugar levels regularly you might get heart disease, nerve damage and more. So you better, take steps to prevent or manage diabetes-related complications and take care of your mental health");
                      break;
                  }
                  stop = false;
                  break;
                }
                break;
              case 2:
                if (obesity == true) {
                  switch (randomInt(5)) {
                    case 1:
                      send =
                          ("Hi $userName, obesity is a serious health concern that can lead to a variety of health issues such as heart disease and high blood pressure, so you need to set realistic weight loss goals, create a calorie deficit by consuming fewer calories than you burn and limit processed and high-calorie foods.");
                      break;
                    case 2:
                      send =
                          ("Hi $userName, obesity is a serious health concern that can lead to a variety of health issues such as heart disease and high blood pressure, so you need to set realistic weight loss goals, create a calorie deficit by consuming fewer calories than you burn and limit processed and high-calorie foods.");
                      break;
                    case 3:
                      send =
                          ("Hi $userName, obesity is a serious health concern that can lead to a variety of health issues such as heart disease and high blood pressure, so you need to set realistic weight loss goals, create a calorie deficit by consuming fewer calories than you burn and limit processed and high-calorie foods.");
                      break;
                    case 4:
                      send =
                          ("Hi $userName, obesity is a serious health concern that can lead to a variety of health issues such as heart disease and high blood pressure, so you need to practice mindful eating and avoid eating when you are not hungry, keep a food diary to track progress and find healthy ways to manage stress.");
                      break;
                    case 5:
                      send =
                          ("Hi $userName, obesity is a serious health concern that can lead to a variety of health issues such as heart disease and high blood pressure, so you need to practice mindful eating and avoid eating when you are not hungry, keep a food diary to track progress and find healthy ways to manage stress.");
                      break;
                  }
                  stop = false;
                  break;
                }
                break;
              case 3:
                if (asthma == true) {
                  switch (randomInt(5)) {
                    case 1:
                      send =
                          ("Hi $userName, asthma affects the airways and makes it difficult to breathe, so you better work with a healthcare professional to develop an asthma action plan, take medication as prescribed by your healthcare provider and monitor your symptoms and keep track of how often you use your rescue inhaler.");
                      break;
                    case 2:
                      send =
                          ("Hi $userName, asthma affects the airways and makes it difficult to breathe, so you better learn how to manage symptoms when they occur, such as using a rescue inhaler, vacuum and dust frequently and use air conditioning to filter out pollutants.");
                      break;
                    case 3:
                      send =
                          ("Hi $userName, asthma affects the airways and makes it difficult to breathe, so you better have a written asthma action plan that includes emergency contact information, keep indoor humidity low and avoid smoking and secondhand smoke.");
                      break;
                    case 4:
                      send =
                          ("Hi $userName, asthma affects the airways and makes it difficult to breathe, so you better avoid exposure to pets and other animals and avoid exposure to cockroaches and other pests, if they trigger your symptoms.");
                      break;
                    case 5:
                      send =
                          ("Hi $userName, asthma affects the airways and makes it difficult to breathe, so you better learn how to recognize the early warning signs of an asthma attack, schedule regular check-ups with your healthcare provider and schedule regular lung function tests.");
                      break;
                  }
                  stop = false;
                  break;
                }
                break;
              case 4:
                send = "Hi $userName, i hope you feel good";
                stop = false;
                break;
            }
          }
          break;
      }
      setState(() {
        messsages.insert(0, {"data": 0, "message": send});
        speak(send);
      });
    }
    habox.put("today", date);
  }

  void initSql() async {
    response = await sqlDb.readData("SELECT * FROM 'profile'");
    try {
      if (response[0]["diseases"].toString().contains("Diabetes")) {
        diabetes = true;
      }
      if (response[0]["diseases"].toString().contains("Obesity")) {
        obesity = true;
      }
      if (response[0]["diseases"].toString().contains("Asthma")) {
        asthma = true;
      }
      userName = response[0]["name"].toString();
    } catch (e) {
      print(e); //Unhandled Exception
    }
  }

  @override
  Widget build(BuildContext context) {
    double heightphone = MediaQuery.of(context).size.height;
    firstcall();
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        height: heightphone * 0.7369,
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                reverse: true, //new massages come from the bottom
                itemCount:
                    messsages.length, //the number of massages showd be shown
                itemBuilder: (context, index) =>
                    chat(messsages[index]["message"], messsages[index]["data"]),
              ), //add massages
            ),
            SizedBox(
              height: 2, //destince from bottom to listview
            ),
            Container(
              color: Color.fromARGB(255, 66, 92, 131), //Low bar color
              child: ListTile(
                  leading: IconButton(
                    padding: EdgeInsets.all(0),
                    iconSize: 30.0,
                    icon: Icon(
                      _speechRecognitionAvailable && !_isListening
                          ? Icons.mic_off
                          : Icons.mic,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: () {
                      start();
                    },
                  ),
                  //microphone icon
                  title: Container(
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 255, 255, 255),
                    ), //writing box style
                    padding: EdgeInsets.only(left: 10),
                    //
                    child: TextField(
                      controller: messageInsert
                        ..text = transcription, //the written text

                      decoration: InputDecoration(
                        hintText: "Enter a Message...",
                        hintStyle: TextStyle(color: Colors.black26),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      onChanged: (text) {},
                    ),
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 30.0,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ), //icon send style
                      onPressed: () {
                        if (messageInsert.text.isEmpty) {
                          print("empty message");
                        } else {
                          setState(() {
                            messsages.insert(
                                0, {"data": 1, "message": messageInsert.text});
                            transcription = "";
                          });
                          botResponse(messageInsert.text);
                          messageInsert.clear();
                          messageInsert.selection;
                        }
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          // currentFocus.unfocus();
                        }
                      })),
            ),
            SizedBox(
              height: 0.0,
            ),
          ],
        ),
      ),
    );
  }

///////////////
//Chat widget//
//Chat widget//
//Chat widget//
//Chat widget//
//Chat widget//
//Chat widget//
//Chat widget//
///////////////
  Widget chat(String message, int data) {
    if (message == null) {
      return null;
    } //if chat field is empty don't send anything.

    return Container(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Row(
        mainAxisAlignment:
            data == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          data == 0 //the Bot massage style
              ? Container(
                  height: 60,
                  width: 60,
                )
              : Container(),
          Padding(
            padding:
                EdgeInsets.all(5.0), //distence between avatar and the massage
            child: Bubble(
              radius: Radius.circular(5.0), //massage edge radius
              color: data == 0
                  ? Color.fromARGB(255, 112, 161, 226) //bot massage color
                  : Color.fromARGB(255, 66, 129, 115),
              nip: data == 0
                  ? BubbleNip.rightTop
                  : BubbleNip.leftTop, //user massage color
              elevation: 5.0, //shadow of the messages
              //
              child: Padding(
                padding: EdgeInsets.all(2.0), //massgae box padding
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: 200), //max massgae box width
                        child: Text(
                          message,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              //
            ),
          ),
          data == 1 // the user massage style
              ? Container(
                  height: 60,
                  width: 60,
                )
              : Container(),
        ],
      ),
    );
  }
}
