import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ble_test/scoped_model/main_model.dart';
import './components/ResultPage.dart';
import 'package:ble_test/components/alert.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanBtn extends StatelessWidget {
  final Function onFinish;
  ScanBtn({@required this.onFinish});
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return Container(
        child: Center(
          child: FlatButton(
            onPressed: model.scanning ? null : () async {
              if (model.state != BluetoothState.on) {
                Alert.show(context, message: '请打开蓝牙');
                return;
              }
              model.startScan();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultPage(),
                  fullscreenDialog: true,
                ),
              ).then((_) {
                model.stopScan();
                onFinish();
              });
            },
            child: Text('添加设备'),
            textColor: Colors.white,
            color: Colors.blue,
            disabledColor: Colors.grey,
          ),
        ),
      );
    });
  }
}
