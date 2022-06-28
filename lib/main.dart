// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:weathermap/pages/home.dart';
import 'package:weathermap/scoped-models/main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final MainModel _model = MainModel();
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _model.navigatorKey = navigatorKey;
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
        model: _model,
        child: MaterialApp(navigatorKey: navigatorKey, routes: {
          '/': (BuildContext context) => HomePage(_model),
        }));
  }
}
