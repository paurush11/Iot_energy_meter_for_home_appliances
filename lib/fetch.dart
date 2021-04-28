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
  var _url = Uri.parse(
      "https://api.thingspeak.com/channels/1235406/feeds.json?api_key=5EO2GGRKJNKWPJV0");
  late StreamController _postsController;

  String name = "";
  String description = "";
  String field1 = "";
  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;
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


  final LinearGradient gradientColors =
  LinearGradient(colors: [ Colors.blue[50]!,
    Colors.blue[200]!,
    Colors.blue], stops:[
  0.0,0.5,1.0
      ]);

  @override
  void initState() {
    _postsController = new StreamController();
    loadPosts();
    _zoomPanBehavior = ZoomPanBehavior(
        enableMouseWheelZooming: true,
        enablePinching: true,
        //enableDoubleTapZooming: true,
        enableSelectionZooming: true,
        selectionRectBorderColor: Colors.red,
        selectionRectBorderWidth: 1,
        selectionRectColor: Colors.grey);
    _trackballBehavior = TrackballBehavior(
        enable: true,
        // Display mode of trackball tooltip
        tooltipDisplayMode: TrackballDisplayMode.floatAllPoints);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Bill Meter"),
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
              DateTime base =
                  DateTime.parse(snapshot.data['channel']['updated_at']);
              print(base);
              String p = "";
              p += DateFormat.d().format(base);
              p += " ";
              p += DateFormat.yMMMM().format(base);
              print(p);
              List<String> dates = [];
              int val = snapshot.data['channel']['last_entry_id'];
              print(val);
              print("------------------");
              List<_PowerCalc> zamana = [];
              List<_InstantPowerData> data = [];
              for (int i = 0; i < val; i++) {
                String newdate = "";
                String s = snapshot.data['feeds'][i]['created_at'];
                DateTime basedate = DateTime.parse(s);

                newdate += DateFormat.d().format(basedate);
                newdate += " ";
                newdate += DateFormat.yMMMM().format(basedate);
                newdate += " ";
                newdate += DateFormat.Hms().format(basedate);
                dates.add(newdate);
                int value = int.parse(snapshot.data['feeds'][i]['field1']);
                zamana.add(_PowerCalc(value.abs(), basedate));
                data.add(_InstantPowerData(newdate, value));
              }
              double netpower = 0.0;
              for(int i = 1;i<val;i++){
                print((zamana[i].val + zamana[i-1].val)/2);
                print(zamana[i].date.difference(zamana[i-1].date).inSeconds);
                netpower += (zamana[i].val + zamana[i-1].val)/2 * zamana[i].date.difference(zamana[i-1].date).inSeconds;
              }
              netpower/=3600000;
              print(netpower);

              return Container(
                height: MediaQuery.of(context).size.height,
                  child: Column(
                children: [

                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.grey)),
                    width: MediaQuery.of(context).size.width * .9,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${snapshot.data['channel']['name']}",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1*.4),
                        ),
                        Text(
                          "${snapshot.data['channel']['description']}",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1*.4),
                        ),
                        Text(
                          "${snapshot.data['channel']['field1']}",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1*.4),
                        ),

                        Text(
                          "Total Energy Consumed -> ${netpower.ceil()} (KWh)",
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width*.1*.4),
                        ),

                      ],
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
                        zoomPanBehavior: _zoomPanBehavior,
                        trackballBehavior: _trackballBehavior,
                        primaryXAxis: CategoryAxis(),
                        title: ChartTitle(text: 'Instantaneous Power Vs Time'),
                        legend: Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(enable: true,
                            borderColor: Colors.blueGrey,
                            borderWidth: 5,
                            tooltipPosition: TooltipPosition.pointer,
                            color: Colors.blue[900]),
                        series: <ChartSeries<_InstantPowerData, String>>[
                          AreaSeries<_InstantPowerData, String>(
                              dataSource: data,
                              borderColor: Colors.blue[900],
                              borderWidth: 2,
                              xValueMapper: (_InstantPowerData sales, _) =>
                                  sales.time,
                              yValueMapper: (_InstantPowerData sales, _) =>
                                  sales.values,
                              name: 'power',
                              gradient: gradientColors,
                              // Enable data label
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true))
                        ]),
                  )
                ],
              ));
            }),
          ),
        ));
  }
}

class _InstantPowerData {
  _InstantPowerData(this.time, this.values);
  final String time;
  final int values;

}
class _PowerCalc{
  _PowerCalc(this.val, this.date);
  final DateTime date;
  final int val;
}
