import 'package:flutter/material.dart';
import 'package:mutall_water/State/ListProvider.dart';
import 'package:provider/provider.dart';
import './screens/selection.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (context) => ListProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: myTheme(),
        title: "mutall meters",
        home: Selection(),
      ),
    );
  }
}

ThemeData myTheme() {
  return ThemeData(
      primarySwatch: Colors.purple,
   );
     
}
