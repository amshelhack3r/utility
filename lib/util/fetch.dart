import 'dart:convert';
import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mutall_water/models/Input.dart';
import 'package:mutall_water/util/db.dart';
import 'dart:async';
import '../models/Meter.dart';

const meters_url = "https://mutall.co.ke/readings/meters";
const insert_url = "https://mutall.co.ke/readings/meters";


class Fetch {
  DatabaseProvider provider;

  Fetch() {
    provider = new DatabaseProvider();
  }

  insertStimaData(data) {
    print(data);
    for (var stima in data) {
      Meter meter =
          new Meter(stima['emeter'], stima['name'], stima['num'], 'stima');
      provider.insertMeter(meter);
    }
    Fluttertoast.showToast(
        msg: "inserted stima data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  insertWaterData(data) {
    for (var water in data) {
      Meter meter = new Meter(
          water['wmeter'], water['name'], water['serial_no'], 'water');
      provider.insertMeter(meter);
    }

    Fluttertoast.showToast(
        msg: "inserted water data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  getMeters() async {
    try{
      var response = await http.get(meters_url);
      var data = jsonDecode(response.body);
      await provider.dropDb();
      insertWaterData(data['water']);
      insertStimaData(data['stima']);
  
    }on SocketException{
      Fluttertoast.showToast(
        msg: "Server Error! Check Internet Connection",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
    }
  }

  Future<Map> getMeterInfo(Meter meter) async{
    try{
      var response = await http.get(meters_url+'/'+meter.type+'/'+meter.primary.toString());
      return jsonDecode(response.body);
      
    }on SocketException{
          Fluttertoast.showToast(
        msg: "Server Error! Check Internet Connection",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
    }
    }
  
  Future<bool> uploadReading(Input input) async {
    try{
    var response = await http.post(insert_url, body: {
      'primary': input.primary.toString(),
      'date': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]),
      'value': input.value,
      'type':input.type
    });
    print(response.body);
    print(response.statusCode);
    if(response.statusCode == 200){
      return true;
    }else{
      return false;
    }
    }on SocketException{
      Fluttertoast.showToast(
        msg: "Server Error! Check Internet Connection",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.greenAccent[400],
        textColor: Colors.white,
        fontSize: 16.0);
  
    }
  }
}
