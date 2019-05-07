import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ble_test/scoped_model/main_model.dart';
import 'package:ble_test/view/home/home.dart';
import 'package:ble_test/view/device_manage/device_manage.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MainModel _mainModel = MainModel();

  @override
  void initState() {
    // _mainModel.initBle();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: _mainModel,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
          'device_manage': (context) => DeviceManagePage()
        },
      ),
    );
  }
}
