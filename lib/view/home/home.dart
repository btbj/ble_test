import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:ble_test/scoped_model/main_model.dart';
import 'package:ble_test/models/ChairState.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_test/components/alert.dart';
import 'package:ble_test/utils/StoreManager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MainModel _model;
  BluetoothState state;
  bool firstShow = true;
  String initTime = DateTime.now().toString();
  @override
  void initState() {
    super.initState();
    _model = ScopedModel.of(context);
    checkBleState();
  }

  void checkBleState() async {
    if (firstShow) {
      await _model.initBle();
    }
    firstShow = false;

    _model.stateSubject.listen((s) {
      dealState(s);
    });
    await _model.refreshBleState();
    dealState(_model.state);
  }

  void dealState(BluetoothState s) async {
    print(s);
    if (firstShow && s == BluetoothState.off) {
      firstShow = false;
      setState(() {});
      print('ble not open');
      Alert.show(context, message: '请打开蓝牙');
    }
    if (s == BluetoothState.on && _model.deviceStateSubject.value == BluetoothDeviceState.disconnected) {
      final lastDevice = await StoreManager.getLastConnectedDevice();
      if (lastDevice != null) {
        // 暂时停用
        // _model.scanToConnect(lastDevice);
      }
    }
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          child: Text(label),
        ),
        Container(
          padding: EdgeInsets.all(5),
          child: Text(value),
        ),
      ],
    );
  }

  String getBleStateText(BluetoothState state) {
    String result;
    switch (state) {
      case BluetoothState.off:
        result = '关闭';
        break;
      case BluetoothState.on:
        result = '开启';
        break;
      case BluetoothState.turningOff:
        result = '关闭中...';
        break;
      case BluetoothState.turningOn:
        result = '开启中...';
        break;
      case BluetoothState.unauthorized:
        result = '未授权';
        break;
      case BluetoothState.unavailable:
        result = '不可用';
        break;
      default:
        result = '未知';
    }
    return result;
  }

  String getBleDeviceStateText(BluetoothDeviceState state) {
    String result;
    switch (state) {
      case BluetoothDeviceState.connected:
        result = '已连接';
        break;
      case BluetoothDeviceState.connecting:
        result = '连接中';
        break;
      case BluetoothDeviceState.disconnected:
        result = '已断开';
        break;
      case BluetoothDeviceState.disconnecting:
        result = '断开中';
        break;
    }
    return result;
  }

  Widget buildBleBox(MainModel model) {
    return Container(
      width: 280,
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(100),
        },
        border: TableBorder.all(width: 1, color: Colors.grey),
        defaultColumnWidth: FlexColumnWidth(1.0),
        children: <TableRow>[
          _buildTableRow('蓝牙状态:', getBleStateText(model.state)),
          _buildTableRow('设备状态:', getBleDeviceStateText(model.deviceStateSubject.value)),
          _buildTableRow('蓝牙数据:', model.value.toString()),
        ],
      ),
    );
  }

  Widget buildStateBox(ChairState state) {
    return Container(
      width: 280,
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(100),
        },
        border: TableBorder.all(width: 1, color: Colors.grey),
        defaultColumnWidth: FlexColumnWidth(1.0),
        children: <TableRow>[
          _buildTableRow('state:', '${state.state}'),
          _buildTableRow('leg:', '${state.leg}'),
          _buildTableRow('rfix:', '${state.rfix}'),
          _buildTableRow('lfix:', '${state.lfix}'),
          _buildTableRow('routation:', '${state.routation}'),
          _buildTableRow('pad:', '${state.pad}'),
          _buildTableRow('buclke:', '${state.buckle}'),
          _buildTableRow('temperature:', '${state.temperature}'),
          _buildTableRow('battery:', '${state.battery}'),
        ],
      ),
    );
  }

  // Widget buildDisconnectBtn(MainModel model) {
  //   return FlatButton(
  //     child: Text('disconnect'),
  //     onPressed: () {
  //       model.disconnect();
  //     },
  //     color: Colors.red,
  //     textColor: Colors.white,
  //     shape: StadiumBorder(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(builder: (context, child, model) {
      print('rebuild home');
      return Scaffold(
        appBar: AppBar(
          title: Text('BLE TEST'),
          actions: <Widget>[
            FlatButton(
              child: Icon(Icons.list),
              textColor: Colors.white,
              onPressed: () {
                model.stopScan();
                Navigator.pushNamed(context, 'device_manage');
              },
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 10),
                buildBleBox(model),
                SizedBox(height: 10),
                buildStateBox(model.chairState),
                SizedBox(height: 10),
                Text(this.initTime),
                SizedBox(height: 10),
                Text('connected at: ${model.connectedTime}'),
                SizedBox(height: 10),
                Text('disconnected at: ${model.disconnectedTime}'),
                // SizedBox(height: 10),
                // buildDisconnectBtn(model),
              ],
            ),
          ],
        ),
        floatingActionButton: IconButton(
          onPressed: () {
            this.checkBleState();
          },
          icon: Icon(Icons.refresh),
        ),
      );
    });
  }
}
