import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iot_application_energy_meter/fetch.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:iot_application_energy_meter/widgets/powercalc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColorDark: Color(0xff001A33),
        scaffoldBackgroundColor: Colors.white,
        bottomAppBarColor: Color(0xffA7E0E9),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'IOT Based Energy Meter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _url = Uri.parse(
      "https://api.thingspeak.com/channels/1235406/feeds.json?api_key=5EO2GGRKJNKWPJV0");
  late StreamController _postsController;
  Future getdata() async {
    var response = await http.get(_url);
    if (response.statusCode == 200) {
      print(response.body);
      var jsonResponse = convert.jsonDecode(response.body);
      print(jsonResponse["channel"]);
      return jsonResponse;
    }
  }

  loadPosts() async {
    getdata().then((res) async {
      _postsController.add(res);
      return res;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _postsController = new StreamController();
    loadPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Color(0xff003033),
      ),
      drawer: Drawer(
        elevation: 16.0,
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xff001A33),
              height: MediaQuery.of(context).size.height * .35,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/image/iotimage.jpg"),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "About Us",
                style: TextStyle(fontSize: 20),
              ),
              leading: Icon(
                Icons.people,
                size: 20,
              ),
            ),
            Divider(
              height: 0.7,
              thickness: 2,
            ),
            Divider(
              height: 0.7,
              thickness: 2,
            ),
            ListTile(
              title: new Text(
                "My bill Summary",
                style: TextStyle(fontSize: 20),
              ),
              leading: new Icon(
                Icons.book_online,
                size: 20,
              ),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Fetch()));
              },
            ),
            Divider(
              height: 0.7,
              thickness: 2,
            ),
            ListTile(
              title: new Text(
                "Export Bill",
                style: TextStyle(fontSize: 20),
              ),
              leading: new Icon(
                Icons.import_export,
                size: 20,
              ),
            )
          ],
        ),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: StreamBuilder(
                stream: _postsController.stream,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  print('Has error: ${snapshot.hasError}');
                  print('Has data: ${snapshot.hasData}');
                  print('Snapshot Data ${snapshot.data}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  if (!snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Text('No Posts');
                  }
                  List<PowerCalc> zamana = [];
                  int val = snapshot.data['channel']['last_entry_id'];
                  for (int i = 0; i < val; i++) {
                    String s = snapshot.data['feeds'][i]['created_at'];
                    DateTime basedate = DateTime.parse(s);
                    int value = int.parse(snapshot.data['feeds'][i]['field1']);
                    zamana.add(PowerCalc(value.abs(), basedate));
                  }
                  double netpower = 0.0;
                  for(int i = 1;i<val;i++){
                    print((zamana[i].val + zamana[i-1].val)/2);
                    print(zamana[i].date.difference(zamana[i-1].date).inSeconds);
                    netpower += (zamana[i].val + zamana[i-1].val)/2 * zamana[i].date.difference(zamana[i-1].date).inSeconds;
                  }
                  netpower/=3600000;// to turn in KWH
                  print(netpower);

                  return Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                          child: Text("Total Power Consumed -- ${netpower.ceil()}"),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          )),
    );
  }
}
