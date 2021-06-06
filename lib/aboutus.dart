import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bill Details"),
        centerTitle: true,
        backgroundColor: Color(0xff003033),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              child: Text("IOT Project Idea", style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 0,right: 10),
              padding: EdgeInsets.only(left: 10,top: 0,right: 10),
              child: Text("We have designed this application so that it becomes easy for the people who use the application to get an idea about their monthly bill.", style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,

              ),),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 0,right: 10),
              padding: EdgeInsets.only(left: 10,top: 0,right: 10),
              child: Text("We have actually seen from the architecture of the circuit that it will be used on an outer switch board of the house. ", style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,right: 10),
              child: Row(
                children: [

                  Text("Our Group Members are - ", style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,right: 10),
              child: Row(
                children: [
                  InkWell(
                    child: Text("☀"),
                    onTap: (){

                    },
                  ),
                  Text("  Jatin Dhankhar", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,right: 10),
              child: Row(
                children: [
                  InkWell(
                    child: Text("☀"),
                    onTap: (){

                    },
                  ),
                  Text("  Aniket Kumar", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,right: 10),
              child: Row(
                children: [
                  InkWell(
                    child: Text("☀"),
                    onTap: (){

                    },
                  ),
                  Text("  Krishna Nand Dwivedi", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.only(left: 10,top: 10,right: 10),
              padding: EdgeInsets.only(left: 10,top: 10,right: 10),
              child: Row(
                children: [
                  InkWell(
                    child: Text("☀"),
                    onTap: (){
                    },
                  ),
                  Text("  Paurush Batish ", style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
