import 'dart:io';
import 'dart:ui';
import 'package:healthassistant/main.dart';
import 'package:healthassistant/sqldb.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PersonalInfoForm extends StatefulWidget {
  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final _formKey = GlobalKey<FormState>();
  var habox = Hive.box('mybox');
  SqlDb sqlDb = SqlDb();
  String name;
  int age;
  double height;
  double weight;
  String Diseases;
  List<String> _diseases = [
    'Diabetes',
    'Obesity',
    'Asthma'
  ]; // List of options to be shown in the dropdown menu
  List<String> _selectedOptionsForDiseases = []; // List of selected options
  List<dynamic> response;

  void addUpdate() async {
    int response =
        await sqlDb // the response 0 means no profile in the database
            .updateData('''UPDATE profile SET 'name' = '$name', 'age'='$age',
           'height'='$height','weight'='$weight','diseases'='$_selectedOptionsForDiseases' ''');
    if (response == 0) {
      int response = await sqlDb.insertData(
          '''INSERT INTO 'profile' ('name','age','height','weight','diseases')
                       VALUES ('$name','$age','$height','$weight','$_selectedOptionsForDiseases')''');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (habox.get('dia') != null) {
      _selectedOptionsForDiseases = habox.get('dia');
    }
    return Scaffold(body: SingleChildScrollView(child: setProfile()));
  }

  Widget setProfile() {
    return Container(
      color: Color.fromARGB(255, 66, 92, 131),
      height: 800,
      child: Column(children: [
        SizedBox(
          height: 25,
        ), //margin top
        Container(
          padding: EdgeInsets.only(top: 5, right: 10, left: 10, bottom: 15),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color.fromARGB(255, 255, 255, 255),
          ), //Personal information background color
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("Personal information",
                    style: TextStyle(
                        fontSize: 24,
                        color: Color.fromARGB(255, 73, 81, 124),
                        fontWeight:
                            FontWeight.bold)), //Personal information text style
                TextFormField(
                  initialValue: habox.get('name') == null
                      ? ""
                      : habox.get('name').toString(),
                  style: TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 73, 81, 124)),
                    ),
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value,
                ), //name textfield
                TextFormField(
                  initialValue: habox.get('age').toString() == "null"
                      ? ""
                      : habox.get('age').toString(),
                  style: TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 73, 81, 124)),
                    ),
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                    labelText: 'Age',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your age';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => age = int.parse(value),
                ), //age textfield
                TextFormField(
                  initialValue: habox.get('h').toString() == "null"
                      ? ""
                      : habox.get('h').toString(),
                  style: TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 73, 81, 124)),
                      ),
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                      labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your height';
                    }

                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) < 40) {
                      return 'the hight is not valid';
                    }
                    return null;
                  },
                  onSaved: (value) => height = double.parse(value),
                ), //height textfield
                TextFormField(
                  initialValue: habox.get('w').toString() == "null"
                      ? ""
                      : habox.get('w').toString(),
                  style: TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 73, 81, 124)),
                      ),
                      labelStyle:
                          TextStyle(color: Color.fromARGB(255, 73, 81, 124)),
                      labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) < 5) {
                      return 'the weight is not valid';
                    }
                    return null;
                  },
                  onSaved: (value) => weight = double.parse(value),
                ), //weight textfield
              ],
            ),
          ),
        ),
        //end of personal information container
        Container(
          padding: EdgeInsets.only(top: 5, right: 10, left: 10, bottom: 5),
          margin: EdgeInsets.all(10),
          //width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: Column(
            children: [
              Text(
                "Medical history",
                style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 73, 81, 124),
                    fontWeight: FontWeight.bold),
              ), //Medical history text style
              SizedBox(
                height: 20,
              ),
              Text("Diseases",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 73, 81, 124),
                  )),
              Container(
                  width: double.infinity,
                  child:
                      _dropdownButton(_diseases, _selectedOptionsForDiseases)),
              Container(
                  child: _selectedOptionsWidget(_selectedOptionsForDiseases)),
            ],
          ),
        ),
        SizedBox(
          height: 30,
        ),
        SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                setState(() {
                  addUpdate();
                  if (habox.get("id") == null) {
                    habox.put("id", "3");
                  }
                  habox.put("name", name);
                  habox.put("age", age);
                  habox.put("h", height);
                  habox.put("w", weight);
                  habox.put("dia", _selectedOptionsForDiseases);
                });

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
                // Save the personal info to storage or send it to a server
              }
            },
            child: Text('Save',
                style: TextStyle(
                    fontSize: 15,
                    color: Color.fromARGB(255, 73, 81, 124),
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  // Dropdown menu widget
  DropdownButton<String> _dropdownButton(
      List<String> op, List<String> selectedOpts) {
    return DropdownButton<String>(
      dropdownColor: Color.fromARGB(255, 231, 231, 231),
      hint: Text(
        "Select from here..",
        style: TextStyle(color: Color.fromARGB(255, 139, 139, 139)),
      ),
      items: op.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: TextStyle(
              color: Color.fromARGB(255, 73, 81, 124),
            ),
          ),
        );
      }).toList(),
      onChanged: (String newOption) {
        if (!selectedOpts.contains(newOption)) {
          setState(() {
            // Add the new option to the list of selected options
            selectedOpts.add(newOption);
          });
        }
      },
      //value: null,
    );
  }

  Widget _selectedOptionsWidget(List<String> selectedOpts) {
    return Column(
      children: selectedOpts.map((String option) {
        return Container(
          margin: const EdgeInsets.only(top: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromARGB(255, 66, 92, 131),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                option,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),

              // Checkbox that allows the user to unselect an option
              Checkbox(
                visualDensity:
                    VisualDensity(horizontal: VisualDensity.maximumDensity),
                value: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                activeColor: Color.fromARGB(255, 255, 255, 255),
                checkColor: Color.fromARGB(255, 73, 81, 124),
                onChanged: (bool value) {
                  setState(() {
                    // Remove the option from the list of selected options
                    selectedOpts.remove(option);
                  });
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
