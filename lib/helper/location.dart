import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

class LocationUtils {
  Future<String> getCurrentAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    if (placemarks.isNotEmpty) {
      return placemarks[0].subLocality!;
    } else {
      return 'Location';
    }
  }

  String convertFtoC(double? value) {
    if (value == null) {
      return '0';
    } else {
      return (value - 273.15).toStringAsFixed(0);
    }
  }

  String getDateFormat(int? dt) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(dt! * 1000);
    return DateFormat('dd MMMM').format(datetime);
  }

  String getHourFormat(int? dt) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(dt! * 1000);
    return DateFormat('HH:MM').format(datetime);
  }

  String getDayFormat(int? dt) {
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(dt! * 1000);
    return DateFormat('EEE').format(datetime);
  }
}
