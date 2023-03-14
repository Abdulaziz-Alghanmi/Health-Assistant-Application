import 'package:flutter/material.dart';
import 'package:healthassistant/Chat.dart';
import 'package:healthassistant/sqldb.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features.dart';
import 'profile.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await Hive.initFlutter();
  var habox = await Hive.openBox('mybox');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'healthassistant',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'healthassistant Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title}) : super();
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var habox = Hive.box('mybox');
    String id = habox.get("id").toString();
    return Scaffold(
      body: id == "null"
          ? PersonalInfoForm()
          : Container(
              color: Color.fromARGB(255, 255, 255, 255), //app color
              child: ListView(children: [
                features(),
                Chat(),
              ]),
            ),
    );
  }
}
