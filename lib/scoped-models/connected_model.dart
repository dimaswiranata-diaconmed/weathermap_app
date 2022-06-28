// ignore_for_file: prefer_final_fields, unused_local_variable, prefer_const_constructors, avoid_print, await_only_futures, prefer_generic_function_type_aliases, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import 'package:weathermap/helper/constant.dart';

typedef void AdditionalSuccessProcess(Map<String, dynamic> responseData);

mixin ConnectedModel on Model {
  Future<bool> checkConnection() async {
    bool connected = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        connected = true;
      }
    } on SocketException catch (_) {}
    return connected;
  }

  Future<Map<String, dynamic>> httpPost(
      String? url,
      String? method,
      Map<String, dynamic> data,
      String? successMessage,
      BuildContext? context) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    String? baseUrl = SERVER_URL;
    String? message = '';
    bool hasError = true;
    http.Response? response;

    if (await checkConnection()) {
      print('data $url');
      print(data);
      print(baseUrl + url!);
      Map<String, dynamic>? responseData = {};
      try {
        switch (method) {
          case 'GET':
            response = await http
                .get(
                  Uri.parse(baseUrl + url),
                  headers: headers,
                )
                .timeout(Duration(seconds: 15));
            break;
          case 'DELETE':
            response = await http
                .delete(
                  Uri.parse(baseUrl + url),
                  headers: headers,
                )
                .timeout(Duration(seconds: 15));
            break;
          case 'CREATE':
            response = await http
                .post(
                  Uri.parse(baseUrl + url),
                  headers: headers,
                  body: json.encode(data),
                )
                .timeout(Duration(seconds: 15));
            break;
          case 'UPDATE':
            response = await http
                .put(
                  Uri.parse(baseUrl + url),
                  headers: headers,
                  body: json.encode(data),
                )
                .timeout(Duration(seconds: 15));
            break;
        }

        print("status code:" + response!.statusCode.toString());
        switch (response.statusCode) {
          case 401:
            responseData = json.decode(response.body);
            print(responseData);
            message = SESSION_EXP;
            break;
          case 404:
            responseData = json.decode(response.body);
            print(responseData);
            message = HTTP_404;
            break;
          case 400:
            responseData = json.decode(response.body);
            print(responseData);
            message = HTTP_400;
            break;
          case 500:
            responseData = json.decode(response.body);
            print(responseData);
            message = responseData!['error_message'] ?? HTTP_500;
            break;
          case 200:
            responseData = json.decode(response.body);
            print(responseData);
            hasError = false;
            break;
          case 201:
            responseData = json.decode(response.body);
            print(responseData);
            hasError = false;
            break;
          default:
            responseData = json.decode(response.body);
            print(responseData);
            if (responseData!['errMessage'] != null) {
              message = responseData['errMessage'];
            } else if (response.body != null) {
              message = response.body;
            } else {
              message = HTTP_FAILED;
            }
            break;
        }
      } on TimeoutException catch (_) {
        message = HTTP_TIMEOUT;
      } catch (error) {
        print('error $url');
        print(error);
        message = HTTP_ERROR;
      }
      return {
        'success': !hasError,
        'message': message,
        'response': responseData
      };
    } else {
      return {'success': !hasError, 'message': NO_CONNECTION, 'response': ''};
    }
  }
}

mixin FeatureModel on ConnectedModel {
  Future<Map<String, dynamic>> getUserList(BuildContext context) {
    Map<String, String?> data = {};
    return httpPost('/api/users?page=1', 'GET', data, '', context);
  }

  Future<Map<String, dynamic>> getWeather(
      BuildContext context, double lat, double lon) {
    Map<String, String?> data = {};
    return httpPost(
        '/data/2.5/onecall?lat=${lat.toString()}&lon=${lon.toString()}&exclude=minutely&appid=45865970ebbfbc127eb2a16dd7f753e7',
        'GET',
        data,
        '',
        context);
  }

  Future<Map<String, dynamic>> deleteUser(BuildContext context, String id) {
    Map<String, String?> data = {};
    return httpPost('/api/users/' + id, 'DELETE', data, '', context);
  }

  Future<Map<String, dynamic>> createUser(
      BuildContext context, Map<String, dynamic> data) {
    return httpPost('/api/users/', 'CREATE', data, '', context);
  }

  Future<Map<String, dynamic>> updateUser(
      BuildContext context, Map<String, dynamic> data, String id) {
    return httpPost('/api/users/' + id, 'UPDATE', data, '', context);
  }
}

mixin UtilityModel on ConnectedModel {
  late GlobalKey<NavigatorState> navigatorKey;
}
