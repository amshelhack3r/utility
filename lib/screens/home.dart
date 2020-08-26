import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mutall_water/State/ListProvider.dart';
import 'package:mutall_water/util/db.dart';
import 'package:mutall_water/screens/ReadingInputState.dart';
import 'package:provider/provider.dart';
import '../models/Meter.dart';
class Home extends StatelessWidget {
  String type;
  Home(this.type);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: Text("Mutall Water Meter"),
        centerTitle: true,
      ),
      body: Container(
        margin: EdgeInsets.all(10.0),
        child: ClientList(type),
      ),
    );
  }
}

class ClientList extends StatefulWidget {
  String type;
  ClientList(this.type);
  @override
  State<StatefulWidget> createState() => _listState();
}

class _listState extends State<ClientList> {
  DatabaseProvider provider;
  @override
  initState() {
    super.initState();
    provider = new DatabaseProvider();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ListProvider>(context).type = widget.type;
    var x = Provider.of<ListProvider>(context).meters;
    print(x.length);
    // TODO: implement build
    return Consumer<ListProvider>(
      builder: (BuildContext context, ListProvider value, Widget child) =>
          ListView.builder(
              itemCount:
                  value.type ? value.wMeters.length : value.eMeters.length,
              padding: EdgeInsets.all(20.0),
              itemBuilder: (BuildContext _context, int i) {
                return _buildRow(
                    value.type ? value.wMeters[i] : value.eMeters[i]);
              }),
    );
  }

  Widget _buildRow(Meter meter) {
    var leadingIcon;
    if (meter.type == "stima") {
      leadingIcon = Icon(FontAwesomeIcons.lightbulb, color: Colors.purpleAccent[700],);
    } else {
      leadingIcon = Icon(FontAwesomeIcons.tint, color: Colors.purpleAccent[700]);
    }
    return Card(
      elevation: 6,
      color: Colors.blueGrey[50],
      child: ListTile(
        leading: leadingIcon,
        title: Text(
          meter.number,
          style: TextStyle(
            color: Colors.purple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(meter.name.toUpperCase(),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
        )),
        isThreeLine: true,
        onTap: () {
          print(meter.name);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReadingInputState(meter)));
        },
      ),
    );
  }
}
