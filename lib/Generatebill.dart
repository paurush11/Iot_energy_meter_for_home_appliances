import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'dart:convert' as convert;
import 'widgets/powercalc.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class BillGenerate extends StatefulWidget {
  @override
  _BillGenerateState createState() => _BillGenerateState();
}

class _BillGenerateState extends State<BillGenerate> {
  late Uint8List _imageFile;
  var _url = Uri.parse("https://api.thingspeak.com/channels/1235406/feeds.json?api_key=5EO2GGRKJNKWPJV0");
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
  _launchURL(url) async {

    await launch(url);
  }


  final LinearGradient gradientColors =
  LinearGradient(colors: [ Colors.blue[100]!,
    Colors.blue[200]!,
    Colors.blue[400]!], stops:[
    1.0,0.2,1.0
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
   int BillRate = 0, NewBill = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Bill Details"),
          centerTitle: true,
          backgroundColor: Color(0xff003033),
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
                  List<PowerCalc> zamana = [];
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
                    zamana.add(PowerCalc(value.abs(), basedate));
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
                      height: MediaQuery.of(context).size.height*.9,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(width: 4, color: Colors.grey)),
                              width: MediaQuery.of(context).size.width * .98,
                              margin: EdgeInsets.all(20),
                              padding: EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(),
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    child: Text("MY BILL", style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(),
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    child: Text("This months Total Power Consumption has been ${netpower.ceilToDouble() } (KWH/UT). Please Select your current Power Plan as per Your Service Provider.", style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(),
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text("Rate Value - $BillRate \u20B9 / KWH", style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(5),
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: Colors.grey ,
                                        inactiveTrackColor: Color(0XFF8D8E98),
                                        thumbColor: Color(0xff003033),
                                        overlayColor: Color(0xff009093),
                                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 15.0),
                                        overlayShape: RoundSliderOverlayShape(overlayRadius: 30.0),
                                      ),
                                      child: Slider(
                                        value: BillRate.toDouble(),
                                        min: 0.0,
                                        max: 20.0,

                                        onChanged: (double newvalue ){
                                          setState(() {
                                            BillRate = newvalue.toInt();
                                            NewBill = BillRate.round()*netpower.round();
                                          });

                                        },


                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(),
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    child: Center(
                                      child: Text("Your Bill is - $NewBill \u20B9 ", style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),),
                                    ),
                                  ),

                                  Container(
                                    decoration: BoxDecoration(),
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                              String url = "https://wa.me/+919306334458?text=The bill amount is $NewBill \u20B9";
                                            _launchURL(url);
                                          },
                                          child: Container(
                                            color: Color(0xff003033),
                                              margin: EdgeInsets.all(10),
                                              padding: EdgeInsets.all(10),
                                              child: Text("WhatsApp", style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20
                                              ),)),
                                        ),
                                        InkWell(
                                          onTap: () async{
                                            String uri = Uri.encodeFull('mailto:paurushbatishfbd@gmail.com?subject=My Bill&body=My current Bill is $NewBill \u20B9.Please pay this upfront.');
                                            await launch(uri);
                                          },
                                          child: Container(
                                              color: Color(0xff003033),
                                              margin: EdgeInsets.all(10),
                                              padding: EdgeInsets.all(10),
                                              child: Text("Mail", style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20
                                              ),)),
                                        ),



                                      ],
                                    )
                                  ),




                                ],
                              ),
                            ),

                          ],
                        ),
                      );
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

