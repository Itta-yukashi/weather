import 'dart:convert';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class WeatherData {
  List<Weather> hourlyWeather1;
  List<Weather> hourlyWeather2;
  List<Weather> hourlyWeather3;
  List<Weather> dailyWeather;

  Weather currentWeather;

  WeatherData(
      {required this.hourlyWeather1,
      required this.hourlyWeather2,
      required this.hourlyWeather3,
      required this.dailyWeather,
      required this.currentWeather});
}

class Weather {
  int? temp;
  int? tempMax;
  int? tempMin;
  String? description;
  String? icon;
  DateTime? time;
  int? rainyPercent;
  String? title;
  int? rain;
  int? feelLike;

  Weather({
    this.temp,
    this.tempMax,
    this.tempMin,
    this.description,
    this.icon,
    this.time,
    this.rainyPercent,
    this.title,
    this.rain,
    this.feelLike,
  });

  static Future<WeatherData> getWeather(String coordinates) async {
    String url =
        "https://api.weatherapi.com/v1/forecast.json?key=78be26bc86bb481fad6141640232610&q=$coordinates&days=3&aqi=no&alerts=no&lang=ja";
    try {
      var result = await get(Uri.parse(url));
      String responseString = utf8.decode(result.bodyBytes);
      Map<String, dynamic> data = jsonDecode(responseString);
      List<dynamic> hourlyWeatherData1 =
          data["forecast"]["forecastday"][0]["hour"];
      List<dynamic> hourlyWeatherData2 =
          data["forecast"]["forecastday"][1]["hour"];
      List<dynamic> hourlyWeatherData3 =
          data["forecast"]["forecastday"][2]["hour"];

      List<dynamic> dailyWeatherData = data["forecast"]["forecastday"];

      Weather currentWeather = Weather(
        temp: data["forecast"]["forecastday"][0]["day"]["avgtemp_c"].toInt(),
        tempMax: data["forecast"]["forecastday"][0]["day"]["maxtemp_c"].toInt(),
        tempMin: data["forecast"]["forecastday"][0]["day"]["mintemp_c"].toInt(),
        description: data["forecast"]["forecastday"][0]["day"]["condition"]
            ["text"],
            
        rainyPercent: data["forecast"]["forecastday"][0]["day"]
                ["daily_chance_of_rain"]
            .toInt(),
        icon: data["forecast"]["forecastday"][0]["day"]["condition"]["icon"],
        title: data["location"]["name"].toString(),
        rain:
            data["forecast"]["forecastday"][0]["day"]["totalprecip_mm"].toInt(),
      );
      List<Weather> hourlyWeather1 = hourlyWeatherData1.map((weather) {
        return Weather(
          temp: weather["temp_c"].toInt(),
          time: DateTime.parse(weather["time"]),
          rainyPercent: weather["chance_of_rain"].toInt(),
          icon: weather["condition"]["icon"],
          rain: weather["precip_mm"].toInt(),
          feelLike:weather["feelslike_c"].toInt(),
        );
      }).toList();
      List<Weather> hourlyWeather2 = hourlyWeatherData2.map((weather) {
        return Weather(
          temp: weather["temp_c"].toInt(),
          time: DateTime.parse(weather["time"]),
          rainyPercent: weather["chance_of_rain"].toInt(),
          icon: weather["condition"]["icon"],
          rain: weather["precip_mm"].toInt(),
          feelLike:weather["feelslike_c"].toInt(),
        );
      }).toList();
      List<Weather> hourlyWeather3 = hourlyWeatherData3.map((weather) {
        return Weather(
          temp: weather["temp_c"].toInt(),
          time: DateTime.parse(weather["time"]),
          rainyPercent: weather["chance_of_rain"].toInt(),
          icon: weather["condition"]["icon"],
          rain: weather["precip_mm"].toInt(),
          feelLike:weather["feelslike_c"].toInt(),
        );
      }).toList();

      List<Weather> dailyWeather = dailyWeatherData.map((weatherData) {
        return Weather(
          tempMax: weatherData["day"]["maxtemp_c"].toInt(),
          temp: weatherData["day"]["avgtemp_c"].toInt(),
          tempMin: weatherData["day"]["mintemp_c"].toInt(),
          time: DateTime.parse(weatherData["date"]),
          rainyPercent: weatherData["day"]["daily_chance_of_rain"].toInt(),
          icon: weatherData["day"]["condition"]["icon"],
          rain: weatherData["day"]["totalprecip_mm"].toInt(),
         
          
        );
      }).toList();

      WeatherData weatherData = WeatherData(
          hourlyWeather1: hourlyWeather1,
          hourlyWeather2: hourlyWeather2,
          hourlyWeather3: hourlyWeather3,
          dailyWeather: dailyWeather,
          currentWeather: currentWeather);

      if (currentWeather.description != null &&
          currentWeather.description!.contains("近くで")) {
        currentWeather.description =
            currentWeather.description!.replaceAll("近くで", "曇り");
      }
      if (data["forecast"]["forecastday"][0]["day"]["condition"]["text"] ==
          null) {
        currentWeather.description = "";
      }

      return weatherData;
    } catch (e) {
      throw Exception('天気データの読み込みに失敗しました'); // エラーが発生した場合に例外をスローする
    }
  }

  static Future<Weather> getYesterdayWeather(String coordinates) async {
    String url =
        "https://api.weatherapi.com/v1/forecast.json?key=78be26bc86bb481fad6141640232610&q=$coordinates&days=1&aqi=no&alerts=no&lang=ja&dt=${DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)))}";
    try {
      var result = await get(Uri.parse(url));
      String responseString = utf8.decode(result.bodyBytes);
      Map<String, dynamic> data = jsonDecode(responseString);

      Weather yesterdayWeather = Weather(
        temp: data["forecast"]["forecastday"][0]["day"]["avgtemp_c"].toInt(),
        tempMax: data["forecast"]["forecastday"][0]["day"]["maxtemp_c"].toInt(),
        tempMin: data["forecast"]["forecastday"][0]["day"]["mintemp_c"].toInt(),
      );

      return yesterdayWeather;
    } catch (e) {
      throw Exception('座標を取得できませんでした'); // エラーが発生した場合に例外をスローする
    }
  }
}

class Address {
  String? latitude;
  String? longitude;
  String? title;

  Address({
    this.latitude,
    this.longitude,
    this.title,
  });

  static Future<Address> getCoordinates(String cityName) async {
    String url =
        "https://msearch.gsi.go.jp/address-search/AddressSearch?q=$cityName";

    try {
      var result = await get(Uri.parse(url));
      String responseString = utf8.decode(result.bodyBytes);
      var data = jsonDecode(responseString);

      if (result.statusCode == 200) {
        if (data is List && data.isNotEmpty) {
          List<String> titles = [
            for (var item in data) item["properties"]["title"]
          ];
          if (titles.contains(cityName)) {
            int index = titles.indexOf(cityName);
            var latitude = data[index]['geometry']['coordinates'][0];
            var longitude = data[index]['geometry']['coordinates'][1];
            return Address(
                latitude: latitude.toString(),
                longitude: longitude.toString(),
                title: cityName.toString());
          }
          if (!titles.contains(cityName)) {
            var title = data[0]["properties"]["title"];
            var latitude = data[0]['geometry']['coordinates'][0];
            var longitude = data[0]['geometry']['coordinates'][1];
            return Address(
                latitude: latitude.toString(),
                longitude: longitude.toString(),
                title: title.toString());
          }

          // ここでlatitudeを取得できます
        }
      } else {}
      // ignore: empty_catches
    } catch (e) {}

    // 失敗時はnullを返すか、適切なエラー処理を行う
    throw Exception('座標の取得に失敗しました');
  }
}
