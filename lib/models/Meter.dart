import 'package:equatable/equatable.dart';

class Meter extends Equatable{
  int primary;
  String name;
  String number;
  String type;

  Meter(this.primary, this.name, this.number, this.type);

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{
      'pk':primary,
      'type':type,
      'name': name,
      'num': number
    };
    return map;
  }

  Meter.fromMap(Map<String, dynamic> map){
    primary = map['pk'];
    name = map['name'];
    number = map['num'];
    type = map['type'];
  }

  @override
  String toString() {
    return 'Meter{primary: $primary, name: $name, number: $number, type: $type}';
  }

  @override
  // TODO: implement props
  List<Object> get props => [primary];
}