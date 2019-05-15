import 'package:scoped_model/scoped_model.dart';
import 'package:ble_test/scoped_model/main_model.dart';
import 'package:flutter/material.dart';
import 'package:ble_test/utils/StoreManager.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  Map<String, dynamic> deviceNameMap;
  @override
  void initState() {
    super.initState();
    getDeviceNameMap();
  }

  void getDeviceNameMap() async {
    deviceNameMap = await StoreManager.getChairNameMap();
    setState(() {});
  }

  List<Widget> buildBodyList(BuildContext context, MainModel model) {
    List<Widget> result = model.scanResults.values.map((result) {
      bool hasName = deviceNameMap != null &&
          deviceNameMap[result.device.id.toString()] != null;
      String nameText = hasName
          ? deviceNameMap[result.device.id.toString()].toString()
          : result.device.name;
      return ListTile(
        title: Text(nameText),
        subtitle: Text(result.device.id.toString()),
        trailing: Text(result.rssi.toString()),
        onTap: () async {
          // connectDevice(target.device);
          model.connect(result.device);
          await StoreManager.saveChairName(
              result.device.id, nameText);
          Navigator.pop(context);
        },
      );
    }).toList();

    if (model.scanStateSubject.value) {
      result.add(ListTile(
        title: Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(),
          ),
        ),
      ));
    }
    return result;
  }

  Widget buildActionBtn(MainModel model) {
    return FlatButton(
      onPressed: () {
        if (model.scanStateSubject.value) {
          model.stopScan();
        } else {
          model.startScan();
        }
      },
      child: Text(model.scanStateSubject.value ? '停止' : '重新扫描'),
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Result'),
          actions: <Widget>[
            buildActionBtn(model),
          ],
        ),
        body: ListView(
          children: buildBodyList(context, model),
        ),
      );
    });
  }
}
