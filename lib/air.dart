// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AirPollutionScreen extends StatefulWidget {
  final double lat;
  final double lon;

  const AirPollutionScreen({ Key? key, required this.lat, required this.lon }): super(key: key);

  @override
  _AirPollutionScreenState createState() => _AirPollutionScreenState();
}

class _AirPollutionScreenState extends State<AirPollutionScreen> {
  Map<String, dynamic> list = {};
  int aqi = 0;
  Future<Map<String, dynamic>> getFutureAirData() async {
      String url = "http://api.openweathermap.org/data/2.5/air_pollution?lat=${widget.lat}&lon=${widget.lon}&appid={yourapiid}";

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception("Failed to fetch data");
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(title: Text("Poluição do ar"),
        backgroundColor: Color.fromRGBO(23, 71, 109, 1),
        // style: TextStyle(color: Colors.black),), 
        // backgroundColor: Color.fromRGBO(222, 236, 247, 1),
        // shadowColor: Color.fromRGBO(1, 1, 1, 0),
        
      ),
      backgroundColor: Color.fromRGBO(222, 236, 247, 1),
      body: FutureBuilder(
        future: getFutureAirData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list = snapshot.data!['list'][0];
            aqi = list["main"]["aqi"];
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
          } else {
            return Center(child: CircularProgressIndicator());
          }

          return Container(
            alignment:Alignment.center,
            child: Column( 
              children: [
                SizedBox(height:20),
                Text("Índice de qualidade do ar: $aqi"),
                SizedBox(height:6),
                if (aqi == 1)
                  Text("Qualidade boa", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromRGBO(23, 71, 109, 1)), ),
                if (aqi == 2)
                  Text("Qualidade suficiente", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromRGBO(23, 71, 109, 1)),),
                if (aqi == 3)
                  Text("Qualidade moderada", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromRGBO(23, 71, 109, 1)),),
                if (aqi == 4)
                  Text("Qualidade insuficiente", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromRGBO(23, 71, 109, 1)),),
                if (aqi == 5)
                  Text("Qualidade ruim", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color.fromRGBO(23, 71, 109, 1)),),
                SizedBox(
                  height: 20,
                ),
                Text("Concentrações de gases (em μg/m\u00B3):", style: TextStyle(fontSize: 18),),
                SizedBox(height:20),
                Container(
                  width: MediaQuery.of(context).size.width*0.9,
                  alignment: Alignment.center,
                  child: Column(
                    children:[ 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(children:[
                            SizedBox(height:3),
                            Text("CO", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                            SizedBox(height:2),
                            Text("${list['components']['co']}", style: TextStyle(),),
                          ],),
                          SizedBox(width:15,),
                          Column(
                            children: [
                              SizedBox(height:3),
                              Text("NO", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                              SizedBox(height:2),
                              Text("${list['components']['no']}"),
                            ],
                          ),
                          SizedBox(width:15,),
                          Column(
                            children: [
                              Text("NO\u2082", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                              Text("${list['components']['no2']}"),
                            ],
                          ),
                          SizedBox(width:15,),
                          Column(
                            children: [
                              Text("O\u2083", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                              Text("${list['components']['o3']}"),
                            ],
                          ),
                          SizedBox(width:15,),
                          Column(
                            children: [
                              Text("SO\u2082 ", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                              Text("${list['components']['so2']}"),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height:20),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.center,  
                      children: [
                        SizedBox(width:15,),
                        Column(
                          children: [
                            Text("PM\u2082\u201a\u2085", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                            Text("${list['components']['pm2_5']}"),
                          ],
                        ),
                        SizedBox(width:15,),
                        Column(
                          children: [
                            Text("PM\u2081\u2080", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                            Text("${list['components']['pm10']}"),
                          ],
                        ),
                        SizedBox(width:15,),
                        Column(
                          children: [
                            Text("NH\u2083", style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color: Colors.black),),
                            Text("${list['components']['nh3']}"),
                          ],
                        ),
                      ],
                    ),
                    ]
                  ),
                ),
              ],
            ),
          );
        }
    ));
  }
}