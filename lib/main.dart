// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:weatherapp/air.dart';

void main(){
  runApp(
    MaterialApp(
      title: "Weather App",
      debugShowCheckedModeBanner: false,
      home: Home()
    )
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _controller = TextEditingController();

  double lat = 0, lon = 0;
  List<Map<String, dynamic>> list = [];
  Map<String, List<Map<String, dynamic>>> groupedForecasts = {};

  bool searchButtonPressed = false;
  bool airButtonPressed = false;

  Future<List<dynamic>> getLatLon() async {
    if (_controller.text.isNotEmpty) {
      String url =
          "http://api.openweathermap.org/geo/1.0/direct?q=${_controller.text}&appid={yourapiid}";

      http.Response response = await http.get(Uri.parse(url));

      List<dynamic> responseData = jsonDecode(response.body);
      return responseData;
    } else {
      return [{
        "lat": 0.0,
        "lon": 0.0,
      }];
    }
  }
  Future<List<Map<String, dynamic>>> getFutureData() async {
    if (_controller.text.isNotEmpty) {
      List<dynamic> latLonData = await getLatLon();

      lat = latLonData[0]["lat"];
      lon = latLonData[0]["lon"];

      String url = "http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid={yourapiid}";

      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<Map<String, dynamic>> forecastList = responseData['list'].cast<Map<String, dynamic>>();
        return forecastList;
      } else {
        throw Exception("Failed to fetch data");
      }
    } else {
      return [{"list": []}];
    }
  }

  groupByDate() {
    groupedForecasts = {};

    if (list[0]['dt_txt'] != null) {
      for (var item in list) {
        String currentDate = item['dt_txt'];

        if (groupedForecasts.containsKey(currentDate.substring(0,10))) {
          groupedForecasts[currentDate.substring(0,10)]!.add(item);
        } else {
          groupedForecasts[currentDate.substring(0,10)] = [item];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Weather App"),
        backgroundColor: Color.fromRGBO(23, 71, 109, 1),
        // style: TextStyle(color: Colors.black),), 
        // backgroundColor: Color.fromRGBO(222, 236, 247, 1),
        // shadowColor: Color.fromRGBO(1, 1, 1, 0),
        
      ),
      backgroundColor: Color.fromRGBO(222, 236, 247, 1),
      body: FutureBuilder(
        future: getFutureData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            list = snapshot.data!;
            groupByDate();
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
          } else {
            return Center(child: CircularProgressIndicator());
          }

          return Container(
            alignment:Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                if (searchButtonPressed) ...[
                  Text("Previsões para ${_controller.text}", style: TextStyle(fontSize: 24,),),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(172, 207, 236, 1)), 
                      foregroundColor: MaterialStatePropertyAll<Color>(Colors.black)),
                    onPressed: () {
                      setState(() { Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => AirPollutionScreen(lat: lat, lon: lon)
                        )
                      ); });
                    }, 
                    child: Text("Ver qualidade do ar")
                  ),
                  SizedBox(height: 20,),
                  Forecast(context),
                ]
                else ...[
                  SizedBox(
                    width: 300,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: _controller,
                      style: TextStyle(
                        fontSize: 40
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Color.fromRGBO(172, 207, 236, 1)), 
                      foregroundColor: MaterialStatePropertyAll<Color>(Colors.black)),
                    onPressed: () {
                      setState(() { searchButtonPressed = true; });
                    }, 
                    child: Text("Buscar")
                  ),
                ],
                SizedBox(height: 20,),
              ],
            ),
          );
      },
      )
    );
  }

  Widget Forecast(BuildContext context) {
   List<String> getDateString(String date) {
      DateTime dateTime = DateTime.parse(date);
      String weekday = "";

      switch(dateTime.weekday) {
        case 1: weekday = "Segunda-feira";
        case 2: weekday = "Terça-feira";
        case 3: weekday = "Quarta-feira";
        case 4: weekday = "Quinta-feira";
        case 5: weekday = "Sexta-feira";
        case 6: weekday = "Sábado";
        case 7: weekday = "Domingo";
      }

      return [weekday,"${dateTime.day}/${dateTime.month}/${dateTime.year}"];
    }
    getHourString(String hour) {
      DateTime time = DateTime.parse(hour);
      return "${time.hour}:00";
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      height: MediaQuery.of(context).size.height*0.66,
      child: ListView.builder(
        itemCount: groupedForecasts.length,
        itemBuilder: (context, index) {
          List<String> listKeys = groupedForecasts.keys.toList();
          List<Map<String, dynamic>> item = groupedForecasts[listKeys[index]]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Text(getDateString(item[0]['dt_txt'].toString())[0], 
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    )),
                  ),
                  Text(getDateString(item[0]['dt_txt'].toString())[1], 
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w500,
                  )),
                ],
              ),
              SizedBox(height: 8,),
              Text("${item[0]['main']['temp_min']}°C MÁX e ${item[0]['main']['temp_min']}°C MÍN", style: TextStyle(color: Color.fromRGBO(23, 71, 109, 1))),
              SizedBox(height: 20,),
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width:MediaQuery.of(context).size.width*0.9,
                    height: 180,
                    // padding: EdgeInsets.all(8),
                    child: ListView.builder(
                        itemCount: item.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int i) {
                          String status = (item[i]['weather'][0]['main']).toString();
                          return Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                Text(getHourString(item[i]['dt_txt'].toString()), 
                                  style: TextStyle(
                                    fontSize: 18.0,
                                  )),
                                  SizedBox(height: 10,),
                                  Text("${(item[i]['main']['temp']).toString()} °C"),
                                  SizedBox(height: 10,),
                                  SizedBox(
                                    height:60,
                                    width:60,
                                    child: Image.network("https://openweathermap.org/img/wn/${item[i]['weather'][0]['icon']}@2x.png"),
                                  ),
                                  
                                  Text(status),
                                ]
                            ),
                          );
                        }),
                  ),
                ],
              ),
              ],
            );
          },
      )
    );
  }
}
