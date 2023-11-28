import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expandable/expandable.dart';
import 'package:weather_app/weather.dart';


 List<String> weekDay = [
    "月",
    "火",
    "水",
    "木",
    "金",
    "土",
    "日",
  ];



class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key,required this.sublistNumber,required this.hourlyNumber,required this.dailyNumber});
    final int sublistNumber;
    final List<Weather> hourlyNumber;
        final List<Weather> dailyNumber;

  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      theme: const ExpandableThemeData(hasIcon: true),
      header: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: dailyNumber.sublist(sublistNumber,sublistNumber+1).map((weather) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("${DateFormat('d').format(weather.time!)}日"),
                            Text("(${weekDay[weather.time!.weekday - 1]})"),
                          ],
                        ),
                      ),
                      
                      Row(
                        children: [
                          Image.network(
                            'https:${weather.icon}',
                            height: 30,
                            width: 30,
                          ),
                          Text(
                            "${weather.rainyPercent}%",
                            style: TextStyle(
                                color: Color.fromARGB(
                                    255,
                                    (weather.rainyPercent!.toInt() * (2.55))
                                        .toInt(),
                                    140 -
                                        (weather.rainyPercent!.toInt() * (1.4))
                                            .toInt(),
                                    255 -
                                        (weather.rainyPercent!.toInt() * (2.55))
                                            .toInt())),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${weather.rain}",
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 140, 255)),
                          ),
                          const Text(
                            "mm",
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 8),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              child: Row(
                                children: [
                                  Text(
                                    "${weather.tempMax}",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  ),
                                  const Text("℃",style: TextStyle(fontSize: 12,color: Colors.red),),
                                  
                                ],
                              ),
                            ),
                            
                            SizedBox(
                              child: Row(
                                children: [
                                  Text(
                                    "${weather.temp}",
                                    style: const TextStyle(fontSize: 16),
                                    
                                  ),const Text("℃",style: TextStyle(fontSize: 12,),),
                                ],
                              ),
                            ),
                            
                            SizedBox(
                              child: Row(
                                children: [
                                  Text(
                                    "${weather.tempMin}",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.blue),
                                  ),
                                   const Text("℃",style: TextStyle(fontSize: 12,color: Colors.blue),),
                                ],
                              ),
                            ),
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      collapsed: const Text(
        '',
        style: TextStyle(fontSize: 0),
      ),
      expanded: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: hourlyNumber.map((weather) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Color.fromARGB(0, 255, 255, 255),
                    Color.fromARGB(0, 255, 255, 255),
                    Color.fromARGB(49, 0, 4, 255),
                    Color.fromARGB(0, 255, 255, 255),
                  ], // 赤と青を指定
                  stops: [
                    0.0,
                    1 - (weather.rain!.toDouble() / 80),
                    1 - (weather.rain!.toDouble() / 80),
                    1.0
                  ],
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  children: [
                    Text("${DateFormat('H').format(weather.time!)}時"),
                    Image.network(
                      'https:${weather.icon}',
                      height: 30,
                      width: 30,
                    ),
                    Row(
                      children: [
                        Text("${weather.temp}"),
                        const Text("℃",style: TextStyle(fontSize: 12,),),
                      ],
                    ),
                    Text(
                      "${weather.rainyPercent}%",
                      style: TextStyle(
                          color: Color.fromARGB(
                              255,
                              (weather.rainyPercent!.toInt() * (2.55)).toInt(),
                              140 -
                                  (weather.rainyPercent!.toInt() * (1.4))
                                      .toInt(),
                              255 -
                                  (weather.rainyPercent!.toInt() * (2.55))
                                      .toInt())),
                    ),
                    Row(
                      children: [
                        Text(
                          "${weather.rain}",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 140, 255)),
                        ),
                        const Text(
                          "mm",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 140, 255),
                              fontSize: 8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
