import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Fetch extends StatefulWidget {
  @override
  _FetchState createState() => _FetchState();
}

class _FetchState extends State<Fetch> {
  var _url = Uri.parse("https://api.thingspeak.com/channels/1235406/feeds.json?api_key=5EO2GGRKJNKWPJV0");
  StreamController _postsController;
  String name = "";
  String description = "";
  String field1 = "";
  Future getdata() async{
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
    _postsController = new StreamController();
    loadPosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
            return Text(snapshot.error);
          }

          if (!snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Text('No Posts');
          }
          DateTime base = DateTime.parse(snapshot.data['channel']['updated_at']);
          print(base);
          String p = "";
          p+= DateFormat.d().format(base);
          p+= " ";
          p+= DateFormat.yMMMM().format(base);
          print(p);
          List<String>dates = [];
          int val =  snapshot.data['channel']['last_entry_id'];
          print(val);
          List<_InstantPowerData> data = [
          ];
          for(int i = 0;i<val;i++){
            String newdate = "";
            print(newdate + "loll");
            String s = snapshot.data['feeds'][i]['created_at'];
            DateTime basedate = DateTime.parse(s);
            newdate+= DateFormat.d().format(basedate);
            newdate+= " ";
            newdate+= DateFormat.yMMMM().format(basedate);
            newdate+= " ";
            newdate += DateFormat.Hms().format(basedate);
            dates.add(newdate);
            int value = int.parse(snapshot.data['feeds'][i]['field1']);
            data.add(_InstantPowerData(newdate,value));
          }

          return Container(
            child: Column(
              children: [
                Expanded(child: Container(

                )),
                Expanded(child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Colors.grey
                    )
                  ),
                  width: MediaQuery.of(context).size.width*.8,
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${snapshot.data['channel']['name']}", style: TextStyle(
                        fontSize: 20
                      ),),
                      Text("${snapshot.data['channel']['description']}", style: TextStyle(
                          fontSize: 20
                      ),),
                      Text("${snapshot.data['channel']['field1']}", style: TextStyle(
                          fontSize: 20
                      ),),
                      Text("Last updated at -> $p", style: TextStyle(
                          fontSize: 20
                      ),),
                    ],
                  ),
                ),
                ),
                // Expanded(
                //   flex: 2,
                //     child: Container(
                //       height: MediaQuery.of(context).size.height*.4,
                //       child: ListView.builder(
                //         itemCount: snapshot.data['channel']['last_entry_id'],
                //         itemBuilder: (context, i){
                //           return Container(
                //             height: MediaQuery.of(context).size.height*.2,
                //             margin: EdgeInsets.all(10),
                //             child: Column(
                //               children: [
                //                 Text("The value for power is - ${snapshot.data['feeds'][i]['field1']}"),
                //                 Text("The value of time is - ${dates[i]}"),
                //                 //
                //               ],
                //             ),
                //           );
                //         },
                //
                //       )
                //
                // )),
                Expanded(
                  flex: 4,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Instantaneous Power wrt time'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: <ChartSeries<_InstantPowerData, String>>[
                      LineSeries<_InstantPowerData, String>(
                      dataSource: data,
                      xValueMapper: (_InstantPowerData sales, _) => sales.time,
                      yValueMapper: (_InstantPowerData sales, _) => sales.values,
                      name: 'power',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: true))]


                ),)
              ],
            )
          );
          }
      ),
    )
    );
  }
}
class _InstantPowerData {
  _InstantPowerData(this.time, this.values);
  final String time;
  final int values;
}