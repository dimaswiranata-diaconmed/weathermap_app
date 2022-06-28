// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors, avoid_print, prefer_final_fields, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'package:weathermap/helper/location.dart';
import 'package:weathermap/model/weather.dart';

class DailyPage extends StatefulWidget {
  final List<WeatherDets>? daily;
  DailyPage({this.daily});
  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  double? _deviceWidth, _deviceHeight;

  Widget _buildDailyItem(WeatherDets daily) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            LocationUtils().getDayFormat(daily.dt),
            style: TextStyle(color: Color(0xff68798F)),
            textScaleFactor: 1,
          ),
          Row(
            children: [
              Image.network(
                "http://openweathermap.org/img/wn/${daily.weather![0].icon}@2x.png",
                height: 50,
                width: 60,
              ),
              Text(
                daily.weather![0].main!,
                style: TextStyle(color: Color(0xff68798F)),
                textScaleFactor: 1,
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '-' + LocationUtils().convertFtoC(daily.tempDaily!.min),
                style: TextStyle(color: Colors.white),
                textScaleFactor: 1,
              ),
              Icon(Icons.trip_origin, size: 4, color: Colors.white),
              SizedBox(
                width: 4,
              ),
              Text(
                '+' + LocationUtils().convertFtoC(daily.tempDaily!.max),
                style: TextStyle(color: Color(0xff68798F)),
                textScaleFactor: 1,
              ),
              Icon(Icons.trip_origin, size: 4, color: Color(0xff68798F))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDailyList() {
    return Container(
      child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.daily!.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildDailyItem(widget.daily![index]);
          }),
    );
  }

  Widget _buildTommorowDetsItem(String image, String value, String desc) {
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

  Widget _buildTomorrowDets() {
    return Container(
      margin: EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTommorowDetsItem('lib/assets/ic_wind.png',
              widget.daily![1].wind_speed.toString() + ' kmph', 'Wind'),
          _buildTommorowDetsItem('lib/assets/ic_water.png',
              widget.daily![1].humidity.toString() + '%', 'Humidity'),
          _buildTommorowDetsItem('lib/assets/ic_rain.png',
              widget.daily![1].clouds.toString() + '%', 'Chance of rain')
        ],
      ),
    );
  }

  Widget _buildTomorrowImageWeather() {
    return Container(
      height: _deviceHeight! * 0.15,
      width: _deviceWidth! * 0.40,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
              "http://openweathermap.org/img/wn/${widget.daily![1].weather![0].icon}@2x.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTomorrowTemperature() {
    String max = LocationUtils().convertFtoC(widget.daily![1].tempDaily!.max);
    String min = LocationUtils().convertFtoC(widget.daily![1].tempDaily!.min);
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTomorrowImageWeather(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tomorrow',
                style: TextStyle(
                  color: Colors.white,
                ),
                textScaleFactor: 1,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    max,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .headline2!
                        .copyWith(
                            color: Colors.white, fontWeight: FontWeight.w500),
                    textScaleFactor: 1,
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '/' + min,
                          style: Theme.of(context)
                              .primaryTextTheme
                              .headline4!
                              .copyWith(
                                  color: Color(0xff73CAFC),
                                  fontWeight: FontWeight.w500),
                          textScaleFactor: 1,
                        ),
                        Icon(
                          Icons.trip_origin,
                          size: 12,
                          color: Color(0xff73CAFC),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                widget.daily![1].weather![0].main!,
                style: Theme.of(context).primaryTextTheme.headline6!.copyWith(
                      color: Color(0xff73CAFC),
                    ),
                textScaleFactor: 1,
              ),
            ],
          )
        ],
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
                  Icons.calendar_month,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Flexible(
                  child: Text(
                    '7 Days',
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

  Widget _buildTomorrowWeather() {
    return Container(
      constraints: BoxConstraints(minHeight: _deviceHeight! * 0.4),
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
          _buildTomorrowTemperature(),
          _buildTomorrowDets()
        ],
      ),
    );
  }

  Widget _buildPageContent() {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return Container(
        constraints: BoxConstraints(minHeight: _deviceHeight!),
        color: Color(0xff000918),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTomorrowWeather(),
              _buildDailyList(),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageContent(),
    );
  }
}
