import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_test/utils/StoreManager.dart';
import './components/scan_btn/ScanBtn.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ble_test/scoped_model/main_model.dart';
import './components/edit_name_dialog.dart';
import './components/delete_name_dialog.dart';

class DeviceManagePage extends StatefulWidget {
  @override
  _DeviceManagePageState createState() => _DeviceManagePageState();
}

class _DeviceManagePageState extends State<DeviceManagePage> {
  List<BluetoothDevice> deviceList = [];
  bool editing = false;

  @override
  void initState() {
    super.initState();
    getDeviceList();
  }

  void getDeviceList() async {
    print('get device list');
    deviceList.clear();
    setState(() {});
    final deviceMap = await StoreManager.getChairNameMap();
    for (String id in deviceMap.keys) {
      deviceList.add(
        BluetoothDevice(
          id: DeviceIdentifier(id),
          name: deviceMap[id].toString(),
        ),
      );
    }
    setState(() {});
  }

  Widget _buildConnectBtn(BluetoothDevice device) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      bool connected = model.device != null && model.device.id == device.id;
      return FlatButton(
        onPressed: model.scanning
            ? null
            : () {
                if (connected) {
                  model.disconnect();
                } else {
                  print('connect ${device.id}');
                  model.scanToConnect(device);
                }
              },
        child: Text(connected ? '断开' : '连接'),
        color: connected ? Colors.red : Colors.blue,
        disabledColor: Colors.grey,
        textColor: Colors.white,
        shape: StadiumBorder(),
      );
    });
  }

  Widget _buildEditingBox(BluetoothDevice device) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 50,
          child: FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              print('edit');
              EditNameDialog.show(context, device).then((_) {
                getDeviceList();
              });
            },
            child: Icon(Icons.edit),
            textColor: Colors.grey,
          ),
        ),
        Container(
          width: 50,
          child: FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              print('delete');
              DeleteNameDialog.show(context, device).then((_) {
                getDeviceList();
              });
            },
            child: Icon(Icons.delete),
            textColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: deviceList.map((device) {
        return ListTile(
          title: Text(device.name.toString()),
          trailing:
              editing ? _buildEditingBox(device) : _buildConnectBtn(device),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('设备列表'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                setState(() {
                  this.editing = !this.editing;
                });
              },
              child: Text(this.editing ? '完成' : '管理'),
              textColor: Colors.white,
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              _buildDeviceList(),
              SizedBox(height: 20),
              editing ? SizedBox() : ScanBtn(onFinish: getDeviceList),
            ],
          ),
        ));
  }
}
