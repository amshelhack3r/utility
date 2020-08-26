import 'dart:collection';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mutall_water/State/ListProvider.dart';
import 'package:mutall_water/models/Input.dart';
import 'package:mutall_water/util/fetch.dart';
import 'package:provider/provider.dart';
import '../models/Meter.dart';

class ReadingInputState extends StatelessWidget {
  final Meter meter;
  ReadingInputState(@required this.meter);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.purple[50],
        appBar: AppBar(
          centerTitle: true,
          title: Text("ENTER READING"),
        ),
        body: ReadingStateful(meter));
  }
}

class ReadingStateful extends StatefulWidget {
  Meter meter;
  ReadingStateful(this.meter);
  @override
  State<StatefulWidget> createState() => ReadingState();
}

class ReadingState extends State<ReadingStateful> {
  var _valueController = TextEditingController();
  Fetch fetch = new Fetch();
  var url = 'http://mutall.co.ke/readings/insert_reading';
  var previousInfo = null;
  var hasLoaded = false;
  Map<String, String> streamMap = new HashMap();
  bool hasError = false;
  String errorMsg = null;

  @override
  initState() {
    super.initState();
    // Add listeners to this class
    fetch.getMeterInfo(widget.meter).then((value) {
      var type = widget.meter.type;
      var identifier = "";
      if(type == "stima"){
        identifier += "emeter";
      }else{
        identifier += "wmeter";
      }

      if(value.length == 0){
        value[identifier] = widget.meter.primary;
        value["date"] = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
        value["value"] = 0;
      }
      setState(() {
        previousInfo = value;
        hasLoaded = true;
      });
    });
  }

  calculate() {
    var prevDate = DateTime.parse(previousInfo['date']);
    var now = new DateTime.now();
    return now.difference(prevDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return hasLoaded ? _inputBox() : _loadingScreen();
  }

  Widget _inputBox() {
    var no_of_days = calculate();
    var previous_val = previousInfo['value'];
    return Center(
      child: Card(
          elevation: 4,
          child: SizedBox(
            width: 350,
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  widget.meter.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(widget.meter.number,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w200)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Last Read $no_of_days days ago",
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                    Text("Last Value $previous_val")
                  ],
                ),
                Container(width: 250, child: valueInput()),
                RaisedButton(
                  padding: EdgeInsets.all(15.0),
                  color: Colors.purpleAccent[700],
                  textColor: Colors.white,
                  onPressed: () async {
                    if (_validate()) {
                      setState(() {
                        hasError = false;
                      });
                      Fetch fetch = Fetch();
                      if (await fetch.uploadReading(Input(widget.meter.primary,
                          _valueController.text, widget.meter.type))) {
                        Fluttertoast.showToast(
                            msg: "record inserted",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.greenAccent[400],
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Provider.of<ListProvider>(context)
                            .removeMeter(widget.meter);
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                            msg: "Server Error",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    }
                  },
                  child: Text("UPLOAD"),
                )
              ],
            ),
          )),
    );
  }

  Widget valueInput() {
    return TextField(
      controller: _valueController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          hintText: "Enter Value",
          labelText: "Enter Value",
          errorText: hasError ? errorMsg : null,
          border: OutlineInputBorder()),
    );
  }

  Widget _loadingScreen() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          strokeWidth: 6.0,
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Text(
          "Fetching Previous",
          style: TextStyle(fontSize: 20),
        )
      ],
    ));
  }

  bool _validate() {
    bool valid = true;
    if (_valueController.text.isEmpty) {
      valid = false;
      setState(() {
        hasError = true;
        errorMsg = "Value cannot be empty";
      });
    } else {
      if (previousInfo['value'] > double.parse(_valueController.text)) {
        valid = false;
        setState(() {
          hasError = true;
          errorMsg = "Value cannot be smaller than last";
        });
      }
    }
    return valid;
  }
}
