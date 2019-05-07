// import 'dart:async';
// import 'package:flutter_blue/flutter_blue.dart';

// class BleManager {
//   factory BleManager() => _getInstance();
//   static BleManager get instance => _getInstance();
//   static BleManager _instance;
//   BleManager._internal() {
//     // 初始化
//   }

//   static BleManager _getInstance() {
//     if (_instance == null) {
//       _instance = BleManager._internal();
//     }
//     return _instance;
//   }

//   FlutterBlue _flutterBlue = FlutterBlue.instance;

//   StreamSubscription _scanSubscription;
//   StreamSubscription get scanSubscription => _scanSubscription;

//   StreamSubscription _stateSubscription;
//   StreamSubscription get stateSubscription => _stateSubscription;
//   BluetoothState state = BluetoothState.unknown;

//   BluetoothDevice device;
//   bool get inConnected => (device != null);
//   StreamSubscription<BluetoothDeviceState> deviceConnection;
//   StreamSubscription<BluetoothDeviceState> _deviceStateSubscription;
//   StreamSubscription<BluetoothDeviceState> get deviceStateSubscription => _deviceStateSubscription;
//   List<BluetoothService> services = List();
//   Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
//   BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

//   void startScan() {
//     _scanSubscription = _flutterBlue
//         .scan(
//           timeout: Duration(seconds: 10),
//         )
//         .listen((_) {});
//   }

//   void stopScan() {
//     print('stop scan');
//     _scanSubscription?.cancel();
//     _scanSubscription = null;
//     return;
//   }

//   void connect(BluetoothDevice targetDevice) {
//     deviceConnection = _flutterBlue
//         .connect(
//           targetDevice,
//           timeout: Duration(seconds: 4),
//         )
//         .listen(null);

//     _deviceStateSubscription = targetDevice.onStateChanged().listen((_) {});
//   }

//   void disconnect() {
//     print('disconnect');
//     _deviceStateSubscription?.cancel();
//     _deviceStateSubscription = null;
//     deviceConnection?.cancel();
//     deviceConnection = null;
//     device = null;
//   }
// }
