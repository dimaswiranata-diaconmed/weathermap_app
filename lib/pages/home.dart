// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors, avoid_print, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:location/location.dart';
import 'package:weathermap/helper/location.dart';

import 'package:weathermap/model/weather.dart';
import 'package:weathermap/pages/daily.dart';
import 'package:weathermap/scoped-models/main.dart';
import 'package:weathermap/widget/adaptive_progress_indicator.dart';

class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage(this.model);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? _loaded;
  String? _errMessage;
  double? _lat, _long;
  WeatherDets? _current;
  List<WeatherDets> _hourly = [];
  List<WeatherDets> _daily = [];
  double? _deviceWidth, _deviceHeight;
  String? _location;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    if (_loaded != null) {
      setState(() => _loaded = null);
    }

    var location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }
    if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
      try {
        LocationData currentLocation = await location.getLocation();
        _lat = currentLocation.latitude;
        _long = currentLocation.longitude;
      } on Exception {
        _lat = null;
        _long = null;
      }
    }

    if (_lat == null || _long == null) {
      setState(() {
        _errMessage = "Please Activate Your Location";
        _loaded = false;
      });
      return;
    }
    Future<String> data = LocationUtils().getCurrentAddress(_lat!, _long!);
    data.then((value) => setState((() {
          setState(() {
            _location = value;
          });
        })));
    _getData();
  }

  Future<void> _getData() async {
    if (_loaded != null) {
      setState(() => _loaded = null);
    }
    Map<String, dynamic> result =
        await widget.model.getWeather(context, _lat!, _long!);
    if (!mounted) return;
    if (result['success']) {
      _setData(result['response']);
    } else {
      _errMessage = result['message'];
    }
    setState(() {
      _loaded = result['success'];
    });
  }

  void _setData(Map<String, dynamic> data) {
    // current
    List<Weather> currWeather = [];
    for (Map<String, dynamic> weath in data['current']['weather']) {
      currWeather.add(Weather(
        id: weath['id'],
        description: weath['description'],
        main: weath['main'],
        icon: weath['icon'],
      ));
    }
    _current = WeatherDets(
        dt: data['current']['dt'],
        sunrise: data['current']['sunrise'],
        sunset: data['current']['sunset'],
        pressure: data['current']['pressure'],
        humidity: data['current']['humidity'],
        clouds: data['current']['clouds'],
        visibilty: data['current']['visibilty'],
        wind_deg: data['current']['wind_deg'],
        temp: double.tryParse(data['current']['temp'].toString()),
        feels_like: double.tryParse(data['current']['feels_like'].toString()),
        dew_point: double.tryParse(data['current']['dew_point'].toString()),
        uvi: double.parse(data['current']['uvi'].toString()),
        wind_speed: double.tryParse(data['current']['wind_speed'].toString()),
        wind_gust: double.tryParse(data['current']['wind_speed'].toString()),
        weather: currWeather);
    // hourly
    _hourly = [];
    for (Map<String, dynamic> hour in data['hourly']) {
      currWeather = [];
      for (Map<String, dynamic> weath in hour['weather']) {
        currWeather.add(Weather(
          id: weath['id'],
          description: weath['description'],
          main: weath['main'],
          icon: weath['icon'],
        ));
      }
      _hourly.add(WeatherDets(
          dt: hour['dt'],
          sunrise: hour['sunrise'],
          sunset: hour['sunset'],
          pressure: hour['pressure'],
          humidity: hour['humidity'],
          clouds: hour['clouds'],
          visibilty: hour['visibilty'],
          wind_deg: hour['wind_deg'],
          temp: double.tryParse(hour['temp'].toString()),
          feels_like: double.tryParse(hour['feels_like'].toString()),
          dew_point: double.tryParse(hour['dew_point'].toString()),
          uvi: double.tryParse(hour['uvi'].toString()),
          wind_speed: double.tryParse(hour['wind_speed'].toString()),
          wind_gust: double.tryParse(hour['wind_speed'].toString()),
          weather: currWeather));
    }
    // daily
    _daily = [];
    for (Map<String, dynamic> daily in data['daily']) {
      currWeather = [];
      for (Map<String, dynamic> weath in daily['weather']) {
        currWeather.add(Weather(
          id: weath['id'],
          description: weath['description'],
          main: weath['main'],
          icon: weath['icon'],
        ));
      }
      _daily.add(WeatherDets(
          dt: daily['dt'],
          sunrise: daily['sunrise'],
          sunset: daily['sunset'],
          pressure: daily['pressure'],
          humidity: daily['humidity'],
          clouds: daily['clouds'],
          visibilty: daily['visibilty'],
          wind_deg: daily['wind_deg'],
          tempDaily: TempDaily(
            day: double.tryParse(daily['temp']['day'].toString()),
            min: double.tryParse(daily['temp']['min'].toString()),
            max: double.tryParse(daily['temp']['max'].toString()),
            night: double.tryParse(daily['temp']['night'].toString()),
            eve: double.tryParse(daily['temp']['eve'].toString()),
            morn: double.tryParse(daily['temp']['morn'].toString()),
          ),
          feelsLikeDaily: FeelsLikeDaily(
            day: double.tryParse(daily['feels_like']['day'].toString()),
            night: double.tryParse(daily['feels_like']['night'].toString()),
            eve: double.tryParse(daily['feels_like']['eve'].toString()),
            morn: double.tryParse(daily['feels_like']['morn'].toString()),
          ),
          dew_point: double.tryParse(daily['dew_point'].toString()),
          uvi: double.tryParse(daily['uvi'].toString()),
          wind_speed: double.tryParse(daily['wind_speed'].toString()),
          wind_gust: double.tryParse(daily['wind_speed'].toString()),
          weather: currWeather));
    }
  }

  Widget _buildHourItem(WeatherDets hour) {
    String temp = LocationUtils().convertFtoC(hour.temp);
    if (hour.temp == null ||
        (LocationUtils().getDateFormat(hour.dt) !=
            LocationUtils().getDateFormat(_current!.dt))) {
      return Container();
    }
    bool isCurrent = (LocationUtils().getHourFormat(hour.dt) ==
        LocationUtils().getHourFormat(_current!.dt));
    return Container(
      margin: EdgeInsets.only(right: 12.0),
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: !isCurrent
          ? BoxDecoration()
          : BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              gradient: LinearGradient(
                colors: [Color(0xff82DAFA), Color(0xff126CFA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: Color(0xff78D1F5).withOpacity(0.85),
                width: 1.0,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                temp,
                style: TextStyle(color: Colors.white),
                textScaleFactor: 1,
              ),
              Icon(Icons.trip_origin, size: 4, color: Colors.white)
            ],
          ),
          Image.network(
            "http://openweathermap.org/img/wn/${hour.weather![0].icon}@2x.png",
            scale: 1.5,
          ),
          Text(
            LocationUtils().getHourFormat(hour.dt),
            style: Theme.of(context).primaryTextTheme.caption,
            textScaleFactor: 1,
          )
        ],
      ),
    );
  }

  Widget _buildHourList() {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      height: _deviceHeight! * 0.15,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _hourly.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildHourItem(_hourly[index]);
          }),
    );
  }

  Widget _buildHourTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Today',
          style: Theme.of(context)
              .primaryTextTheme
              .subtitle1!
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          textScaleFactor: 1,
        ),
        GestureDetector(
          child: Row(
            children: [
              Text(
                '7 days',
                style: Theme.of(context)
                    .primaryTextTheme
                    .caption!
                    .copyWith(color: Colors.grey),
                textScaleFactor: 1,
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              )
            ],
          ),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (BuildContext context) {
            return DailyPage(
              daily: _daily,
            );
          })),
        ),
      ],
    );
  }

  Widget _buildHourWeather() {
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [_buildHourTitle(), _buildHourList()],
      ),
    );
  }

  Widget _buildCurrentDetsItem(String image, String value, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 24.0,
          width: 24.0,
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, height: 1.5),
          textScaleFactor: 1,
        ),
        Text(
          desc,
          style: Theme.of(context).primaryTextTheme.caption,
          textScaleFactor: 1,
        ),
      ],
    );
  }

  Widget _buildCurrentDets() {
    return Container(
      margin: EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCurrentDetsItem('lib/assets/ic_wind.png',
              _current!.wind_speed.toString() + ' kmph', 'Wind'),
          _buildCurrentDetsItem('lib/assets/ic_water.png',
              _current!.humidity.toString() + '%', 'Humidity'),
          _buildCurrentDetsItem('lib/assets/ic_rain.png',
              _current!.clouds.toString() + '%', 'Chance of rain')
        ],
      ),
    );
  }

  Widget _buildCurrentTemperature() {
    String temperature = LocationUtils().convertFtoC(_current!.temp!);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          temperature,
          style: Theme.of(context)
              .primaryTextTheme
              .headline1!
              .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          textScaleFactor: 1,
        ),
        SizedBox(
          width: 5.0,
        ),
        Icon(Icons.trip_origin,
            color: Color(
              0xff82B5F8,
            ))
      ],
    );
  }

  Widget _buildCurrentImageWeather() {
    return Container(
      height: _deviceHeight! * 0.20,
      width: _deviceWidth! * 0.8,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "http://openweathermap.org/img/wn/${_current!.weather![0].icon}@2x.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.only(top: 24),
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'lib/assets/ic_menu.png',
            height: 24,
            width: 24,
          ),
          Container(
            width: _deviceWidth! * 0.6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_pin,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Flexible(
                  child: Text(
                    _location ?? '',
                    style: Theme.of(context).primaryTextTheme.subtitle1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert,
            color: Colors.white,
          )
        ],
      ),
    );
  }

  Widget _buildCurrentWeather() {
    String datetime = LocationUtils().getDateFormat(_current!.dt);
    return Container(
      constraints: BoxConstraints(minHeight: _deviceHeight! * 0.7),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xff78D1F5).withOpacity(0.85),
          width: 3.0,
        ),
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(60),
          bottomLeft: Radius.circular(60),
        ),
        gradient: LinearGradient(
          colors: [Color(0xff82DAFA), Color(0xff126CFA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xff78D1F5).withOpacity(0.6),
            offset: Offset(0.0, 5.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildCurrentImageWeather(),
          _buildCurrentTemperature(),
          Text(
            _current!.weather![0].main!,
            style: Theme.of(context)
                .primaryTextTheme
                .headline5!
                .copyWith(fontWeight: FontWeight.bold),
            textScaleFactor: 1,
          ),
          SizedBox(
            height: 5.0,
          ),
          Text(
            'Today, ' + datetime,
            style: Theme.of(context).primaryTextTheme.caption!,
            textScaleFactor: 1,
          ),
          SizedBox(
            height: 8.0,
          ),
          _buildCurrentDets()
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
        future: Future.value(_loaded),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return RefreshIndicator(
                onRefresh: _getData,
                child: Container(
                  constraints: BoxConstraints(minHeight: _deviceHeight!),
                  color: Color(0xff000918),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    child: Column(
                      children: [_buildCurrentWeather(), _buildHourWeather()],
                    ),
                  ),
                ),
              );
            } else {
              return Container(
                constraints: BoxConstraints(minHeight: _deviceHeight!),
                color: Color(0xff000918),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errMessage ?? 'Error 404',
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      GestureDetector(
                        child: Container(
                          color: Colors.white,
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Request Again'),
                        ),
                        onTap: () {
                          if (_lat == null || _long == null) {
                            _getUserLocation();
                          } else {
                            _getData();
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            }
          } else {
            return Center(child: AdaptiveProgressIndicator());
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(),
    );
  }
}
