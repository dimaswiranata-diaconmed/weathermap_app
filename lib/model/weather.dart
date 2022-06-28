// ignore_for_file: non_constant_identifier_names

class Weather {
  int? id;
  String? main, description, icon;

  Weather({this.id, this.main, this.description, this.icon});
}

class TempDaily {
  double? day, min, max, night, eve, morn;
  TempDaily({this.day, this.min, this.max, this.night, this.eve, this.morn});
}

class FeelsLikeDaily {
  double? day, night, eve, morn;
  FeelsLikeDaily({this.day, this.night, this.eve, this.morn});
}

class WeatherDets {
  int? dt, sunrise, sunset, pressure, humidity, clouds, visibilty, wind_deg;
  double? temp, feels_like, dew_point, uvi, wind_speed, wind_gust;
  List<Weather>? weather;
  TempDaily? tempDaily;
  FeelsLikeDaily? feelsLikeDaily;

  WeatherDets(
      {this.dt,
      this.sunrise,
      this.sunset,
      this.pressure,
      this.humidity,
      this.clouds,
      this.visibilty,
      this.wind_deg,
      this.temp,
      this.feels_like,
      this.dew_point,
      this.uvi,
      this.wind_speed,
      this.wind_gust,
      this.weather,
      this.tempDaily,
      this.feelsLikeDaily});
}
