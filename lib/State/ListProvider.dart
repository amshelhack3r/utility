import 'package:flutter/foundation.dart';
import 'package:mutall_water/models/Meter.dart';
import 'package:mutall_water/util/db.dart';

class ListProvider extends ChangeNotifier {
  List<Meter> _meters = [];
  bool _isWater = true;
  
  var provider = DatabaseProvider();
  ListProvider() {
    init();
  
  }
  get type => _isWater;
  get meters => _meters;
  get wMeters => _meters.where((meter)=>meter.type == 'water').toList();
  get eMeters => _meters.where((meter)=>meter.type == 'stima').toList();

  set type(String type){
    if(type == 'water'){
      _isWater = true;
    }else{
      _isWater = false;
    }
  }


  void removeMeter(Meter meter) {
    _meters.removeAt(_meters.indexOf(meter));
    notifyListeners();
  }

  void init() async {
    _meters = await provider.queryMeters();
      print("Database finished fetching");
      
  }
}
