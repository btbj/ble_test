import 'package:flutter_blue/flutter_blue.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ble_test/scoped_model/main_model.dart';
import 'package:flutter/material.dart';

class ConnectingBox extends StatefulWidget {
  @override
  _ConnectingBoxState createState() => _ConnectingBoxState();
}

class _ConnectingBoxState extends State<ConnectingBox> {
  MainModel _model;

  @override
  void initState() {
    super.initState();
    _model = ScopedModel.of(context);
    _model.deviceStateSubject.listen((s) {
      if (s == BluetoothDeviceState.connected) {
        Navigator.pop(context);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return SimpleDialog(
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
              Text('连接上次使用设备中'),
              FlatButton(
                onPressed: () async {
                  await model.disconnect();
                  await model.stopScan();
                  Navigator.pop(context);
                },
                child: Text('取消'),
                color: Colors.blue,
                textColor: Colors.white,
              ),
            ],
          ),
        ],
      );
    });
  }
}
