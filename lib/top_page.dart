import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:weather_app/image_api.dart';
import 'package:weather_app/weather.dart';
import 'package:flutter/scheduler.dart';
import 'package:weather_app/weather_widget.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  String _selectedChipText = ""; // 選択されたチップのテキストを保存する変数
  Future<void> _refreshWeatherData() async {
    await _loadWeatherData();
  }

  double height = 0;
  late Future<void> _weatherDataFuture;
  final TextEditingController _locationController = TextEditingController();
  List<Map<String, dynamic>> datas = [];
  String coordinates = "35.25989111,136.219292";
  String title = "滋賀県立大学";
  Weather currentWeather = Weather();
  Weather yesterdayWeather = Weather();
  String errorMessage = "";
  List<Weather> hourlyWeather1 = [];
  List<Weather> hourlyWeather2 = [];
  List<Weather> hourlyWeather3 = [];
  List<Weather> dailyWeather = [];
  bool isSelected = false;
  bool isLoading = false; // データ読み込み中かどうかを示すフラグ
  final _key = GlobalKey();
  int tag = 17842154833023097;
  int feelLike = 0;

  @override
  void initState() {
    super.initState();
    _weatherDataFuture = _loadWeatherData();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        height = _key.currentContext!.size!.height;
      });
    });
    super.initState();
  }

  Future<void> _loadWeatherData() async {
    try {
      WeatherData weatherData = await Weather.getWeather(coordinates);
      Weather yesterdayWeather = await Weather.getYesterdayWeather(coordinates);

      setState(() {
        this.yesterdayWeather = yesterdayWeather;
        currentWeather = weatherData.currentWeather;
        hourlyWeather1 = weatherData.hourlyWeather1;
        hourlyWeather2 = weatherData.hourlyWeather2;
        hourlyWeather3 = weatherData.hourlyWeather3;
        dailyWeather = weatherData.dailyWeather;

        errorMessage = "";
        isLoading = false;
      });
      int feelLike = hourlyWeather1.length >= 7
          ? (hourlyWeather1[7].feelLike! +
                  hourlyWeather1[8].feelLike! +
                  hourlyWeather1[9].feelLike! +
                  hourlyWeather1[10].feelLike! +
                  hourlyWeather1[11].feelLike! +
                  hourlyWeather1[12].feelLike! +
                  hourlyWeather1[13].feelLike! +
                  hourlyWeather1[14].feelLike! +
                  hourlyWeather1[15].feelLike! +
                  hourlyWeather1[16].feelLike! +
                  hourlyWeather1[17].feelLike! +
                  hourlyWeather1[18].feelLike! +
                  hourlyWeather1[19].feelLike!) ~/
              13
          : 50;

      int currentTemperature = feelLike;
      if (currentTemperature <= 5) {
        tag = 17842314631034063;
      } else if (currentTemperature > 5 && currentTemperature <= 8) {
        tag = 17841542101078752;
      } else if (currentTemperature > 8 && currentTemperature <= 12) {
        tag = 17842872790022050;
      } else if (currentTemperature > 12 && currentTemperature <= 16) {
        tag = 17842568872057530;
      } else if (currentTemperature > 16 && currentTemperature <= 20) {
        tag = 17861548534047047;
      } else if (currentTemperature > 20) {
        tag = 17842726897003807;
      }
      print(tag);
      setState(() {
        this.feelLike = feelLike;
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          height = _key.currentContext!.size!.height;
          _getInstagramData(); // Pass the updated URL to this method
        });
      });
    } catch (e) {
      setState(() {
        errorMessage = '天気データの読み込みに失敗しました';
        isLoading = false; // データ読み込み完了(エラー)
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          height = _key.currentContext!.size!.height;
        });
      });
    }
  }

  Future<void> _getInstagramData() async {
    try {
      List<Map<String, dynamic>> data =
          await PixabayService.getInstagramData(tag);
      setState(() {
        datas = data;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _fetchCoordinates(String cityName) async {
    setState(() {
      isLoading = true; // データ読み込み中
    });

    try {
      Address address = await Address.getCoordinates(cityName);
      coordinates = "${address.longitude},${address.latitude}";
      title = address.title ?? "";

      await _loadWeatherData();
    } catch (e) {
      setState(() {
        errorMessage = '座標を取得できませんでした';
        isLoading = false; // データ読み込み完了(エラー)
        _chipsList.removeLast();
        _locationController.clear(); //リセット処理
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          height = _key.currentContext!.size!.height;
        });
      });
    }
  }

  // チップのテキストを保存するリスト
  final List<String> _chipsList = [];
  // 選択されたチップのテキストを保存する変数

  // チップを追加するメソッド
  void _addChip(String text) {
    // チップの数が5個以上の場合、先頭のチップを削除
    if (_chipsList.length >= 10) {
      _chipsList.removeAt(0);
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        height = _key.currentContext!.size!.height;
      });
    });

    // 既存のチップリストに含まれていない場合にのみ新しいチップを追加
    if (!_chipsList.contains(text)) {
      setState(() {
        _chipsList.add(text);
        _locationController.clear();
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          height = _key.currentContext!.size!.height;
        });
      });
    }
  }

  void _removeChip(String text) {
    setState(() {
      _chipsList.remove(text);
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        height = _key.currentContext!.size!.height;
      });
    });
  }

  DateTime now = DateTime.now();
  String formattedDate = '';
  @override
  Widget build(BuildContext context) {
    if (dailyWeather.isNotEmpty && dailyWeather[0].time != null) {
      now = dailyWeather[0].time!;
      formattedDate = DateFormat('yyyy年MM月dd日').format(now);
    }

    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.black,

        surfaceTintColor: Colors.white,
        toolbarHeight: height + 10,
        title: Container(
          key: _key,
          constraints: const BoxConstraints(),
          child: Column(
            children: [
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => _locationController.clear(), //リセット処理
                    icon: const Icon(Icons.clear),
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                  ),
                  labelText: '検索したい場所を入力してください',
                  counterText: '', // 文字数カウンターを非表示にする
                ),
                maxLength: 20, // 入力可能な最大文字数を指定
                onSubmitted: (String input) {
                  _fetchCoordinates(input);
                  _addChip(input);
                  _locationController.text = input;
                  _selectedChipText = input;
                },
              ),
              const SizedBox(
                height: 8,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  textDirection: TextDirection.rtl,
                  spacing: 8.0, // チップ間の水平スペース
                  direction: Axis.horizontal, // Wrap内でのメイン軸方向
                  children: _chipsList.map((String chipText) {
                    isSelected =
                        (chipText == _selectedChipText); // チップが選択されているかどうかを判定

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedChipText = chipText; // ユーザーが選択したチップのテキストを保存
                          _fetchCoordinates(chipText); // チップのテキストを使用して座標を取得
                          _locationController.text = chipText;
                        });
                      },
                      child: Chip(
                        shape: const StadiumBorder(),
                        side: const BorderSide(
                            color: Color.fromARGB(0, 255, 255, 255),
                            width: 0), // 境界線の設定
                        deleteIconColor: isSelected
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(255, 0, 0, 0),
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // 追加：上下の余計なmarginを削除
                        labelPadding: const EdgeInsets.symmetric(
                            horizontal: 5), // 追加：文字左右の多すぎるpaddingを調整
                        visualDensity: const VisualDensity(
                            horizontal: 0.0,
                            vertical: -2), // 追加：文字上下の多すぎるpaddingを調整
                        backgroundColor: isSelected
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(20, 0, 0, 0),
                        label: Text(
                          chipText,
                          style: TextStyle(
                            color: isSelected
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        onDeleted: () {
                          setState(() {
                            _chipsList.remove(chipText);
                            _removeChip(chipText);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              errorMessage == ""
                  ? const Text(
                      "",
                      style: TextStyle(fontSize: 0),
                    )
                  : Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
            ],
          ),
        ), // AppBarのタイトルを設定
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: isLoading == true
              ? const LinearProgressIndicator(
                  minHeight: 2,
                )
              : const SizedBox(
                  height: 2,
                ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshWeatherData,
        child: FutureBuilder(
          future: _weatherDataFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
            } else if (dailyWeather.isEmpty) {
              // データがまだロードされていない場合やdailyWeatherが空の場合はローディングスピナーを表示
              return const Center(child: CircularProgressIndicator());
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    Text(
                      ' $formattedDate (${weekDay[now.weekday - 1]})',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          // テキストを中央揃えにする
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentWeather.description == null
                              ? "-"
                              : "${currentWeather.description}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        Image.network(
                          'https:${currentWeather.icon}',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("平均"),
                        Text(
                          currentWeather.temp == null
                              ? "-"
                              : "${currentWeather.temp}",
                          style: const TextStyle(fontSize: 80),
                        ),
                        const Text(
                          "℃",
                          style: TextStyle(fontSize: 50),
                        ),
                        Tooltip(
                          message: '前日との気温差', // 表示するメッセージ
                          preferBelow: true, // メッセージを子widgetの上に出すか下に出すか
                          decoration: const BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                          ), // 吹き出しの形や色の調整
                          showDuration: const Duration(
                              milliseconds: 1500), // 何秒間メッセージを見せるか
                          triggerMode: TooltipTriggerMode
                              .longPress, // どのような条件でメッセージを表示するか
                          enableFeedback:
                              true, // メッセージが表示された際に何かしらのフィードバックがあるかどうか
                          child: Column(
                            children: [
                              if (currentWeather.temp == null)
                                const Text(
                                  "-",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )
                              else if (currentWeather.temp! -
                                      yesterdayWeather.temp! >
                                  0)
                                Text(
                                  "[+${currentWeather.temp! - yesterdayWeather.temp!}]",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                )
                              else
                                Text(
                                  "[${currentWeather.temp! - yesterdayWeather.temp!}]",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Row(
                            children: [
                              const Text("最高"),
                              Text(
                                currentWeather.tempMax == null
                                    ? "-"
                                    : "${currentWeather.tempMax!}℃",
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.redAccent),
                              ),
                              if (currentWeather.tempMax == null)
                                const Text(
                                  "-",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.red),
                                )
                              else if ((currentWeather.tempMax! -
                                      yesterdayWeather.tempMax!) >
                                  0)
                                Text(
                                  "[+${currentWeather.tempMax! - yesterdayWeather.tempMax!}]",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.red),
                                )
                              else
                                Text(
                                  "[${currentWeather.tempMax! - yesterdayWeather.tempMax!}]",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.red),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                const Text("最低"),
                                Text(
                                  currentWeather.tempMin == null
                                      ? "-"
                                      : "${currentWeather.tempMin!}℃",
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.blueAccent),
                                ),
                                if (currentWeather.tempMin == null)
                                  const Text(
                                    "-",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.blue),
                                  )
                                else if ((currentWeather.tempMin! -
                                        yesterdayWeather.tempMin!) >
                                    0)
                                  Text(
                                    "[+${currentWeather.tempMin! - yesterdayWeather.tempMin!}]",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.blue),
                                  )
                                else
                                  Text(
                                    "[${currentWeather.tempMin! - yesterdayWeather.tempMin!}]",
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.blue),
                                  ),
                              ],
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                const Text("体感温度"),
                                Text(
                                  "$feelLike",
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const Text("℃"),
                              ],
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: 120,
                          child: Row(children: [
                            feelLike >= 30
                                ? SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL0_wght400_GRAD0_opsz24.png"),
                                  )
                                : SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL1_wght400_GRAD0_opsz24.png"),
                                  ),
                            feelLike >= 20
                                ? SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL0_wght400_GRAD0_opsz24.png"),
                                  )
                                : SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL1_wght400_GRAD0_opsz24.png"),
                                  ),
                            feelLike >= 16
                                ? SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL0_wght400_GRAD0_opsz24.png"),
                                  )
                                : SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL1_wght400_GRAD0_opsz24.png"),
                                  ),
                            feelLike >= 10
                                ? SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL0_wght400_GRAD0_opsz24.png"),
                                  )
                                : SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL1_wght400_GRAD0_opsz24.png"),
                                  ),
                            feelLike >= 5
                                ? SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL0_wght400_GRAD0_opsz24.png"),
                                  )
                                : SizedBox(
                                    width: 20,
                                    child: Image.asset(
                                        "assets/images/apparel_FILL1_wght400_GRAD0_opsz24.png"),
                                  ),
                          ]),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                const Text("降水確率"),
                                Text(
                                  currentWeather.rainyPercent == null
                                      ? "-"
                                      : "${currentWeather.rainyPercent}",
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const Text("%"),
                              ],
                            )),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                            width: 120,
                            child: Row(
                              children: [
                                const Text("合計降水量"),
                                Text(
                                  currentWeather.rainyPercent == null
                                      ? "-"
                                      : "${currentWeather.rain}",
                                  style: const TextStyle(fontSize: 30),
                                ),
                                const Text("mm"),
                              ],
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Divider(
                      height: 0,
                    ),
                    WeatherWidget(
                      sublistNumber: 0,
                      hourlyNumber: hourlyWeather1,
                      dailyNumber: dailyWeather,
                    ),
                    const Divider(
                      height: 0,
                      color: Colors.black12,
                    ),
                    WeatherWidget(
                      sublistNumber: 1,
                      hourlyNumber: hourlyWeather2,
                      dailyNumber: dailyWeather,
                    ),
                    const Divider(
                      height: 0,
                      color: Colors.black12,
                    ),
                    WeatherWidget(
                      sublistNumber: 2,
                      hourlyNumber: hourlyWeather3,
                      dailyNumber: dailyWeather,
                    ),
                    const Divider(
                      height: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Wrap(
                        children: [
                          GradientText(
                            '今日のおすすめコーデ',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                            colors: const [
                              Colors.orange,
                              Colors.red,
                              Colors.pinkAccent,
                              Colors.purple,
                              Colors.blue,
                            ],
                          ),
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    datas.isEmpty
                        ? const LinearProgressIndicator(
                            minHeight: 2,
                          )
                        : const SizedBox(
                            height: 2,
                          ),
                    InstagramGrid(datas: datas),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
