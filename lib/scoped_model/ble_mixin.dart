import 'dart:async';
// import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_test/utils/NotificationManager.dart';
import 'package:ble_test/models/ChairState.dart';
import 'package:ble_test/utils/StoreManager.dart';

mixin BleMixin on Model {
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  FlutterBlue get flutterBlue => _flutterBlue;

  NotificationManager notificationManager = NotificationManager();
  ChairState _chairState = ChairState();
  ChairState get chairState => _chairState;

  final String targetUUIDString = '0000ffe1-0000-1000-8000-00805f9b34fb';
  BluetoothCharacteristic targetChar;

  StreamSubscription _scanSubscription;
  StreamSubscription get scanSubscription => _scanSubscription;
  bool _scanning = false;
  bool get scanning => _scanning;
  Map<DeviceIdentifier, ScanResult> _scanResults = Map();
  Map<DeviceIdentifier, ScanResult> get scanResults => _scanResults;

  StreamSubscription _stateSubscription;
  Stream _stateStream;
  Stream get stateStream => _stateStream;
  StreamSubscription get stateSubscription => _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  BluetoothDevice device;
  bool get inConnected => (device != null);
  StreamSubscription<BluetoothDeviceState> deviceConnection;
  StreamSubscription<BluetoothDeviceState> _deviceStateSubscription;
  StreamSubscription<BluetoothDeviceState> get deviceStateSubscription =>
      _deviceStateSubscription;
  List<BluetoothService> services = List();
  StreamSubscription<List<int>> valueChangedSubscriptions;
  List<int> _value = [];
  List<int> get value => _value;

  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  Future refreshBleState() async {
    state = await _flutterBlue.state;
    print(state);
    notifyListeners();
    return;
  }

  Future initBle() async {
    await this.notificationManager.init();
    await _flutterBlue.setUniqueId('welldon_safe_chair');
    _flutterBlue.state.then((s) {
      state = s;
      print(state);
      notifyListeners();
    });
    // if (state != BluetoothState.on) return;
    _stateStream = _flutterBlue.onStateChanged().asBroadcastStream();
    _stateSubscription = _stateStream.listen((s) {
      state = s;
      notifyListeners();
      if (s == BluetoothState.turningOff) {
        disconnect();
      }
      if (s == BluetoothState.off) {
        disconnect();
        print('close ble');
        notificationManager.show('蓝牙已关闭');
      }
    });
    return;
  }

  void disposeBle() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
  }

  void startScan() async {
    await stopScan();
    await this.disconnect();
    print('start scan');
    this._scanResults.clear();
    _scanSubscription =
        _flutterBlue.scan(timeout: Duration(seconds: 10)).listen((scanResult) {
      this._scanResults[scanResult.device.id] = scanResult;
      // if (scanResult.device.name == 'BLE003U') {
      //   print(scanResult.advertisementData.localName);
      //   print(scanResult.advertisementData.manufacturerData);
      // }
      notifyListeners();
    }, onDone: stopScan);
    _scanning = true;
    notifyListeners();
  }

  Future stopScan() async {
    print('stop scan');
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _scanning = false;
    notifyListeners();
    return;
  }

  void connect(BluetoothDevice targetDevice) {
    deviceConnection = _flutterBlue
        .connect(
          targetDevice,
          timeout: Duration(seconds: 10),
        )
        .listen(null, onDone: disconnect);
    targetDevice.state.then((s) {
      deviceState = s;
      notifyListeners();
    });

    _deviceStateSubscription = targetDevice.onStateChanged().listen((s) async {
      deviceState = s;
      notifyListeners();
      if (s == BluetoothDeviceState.connected) {
        device = targetDevice;
        valueChangedSubscriptions?.cancel();
        valueChangedSubscriptions = null;
        await StoreManager.saveLastConnectedDevice(targetDevice);
        await this.scanServices(targetDevice);
        notifyListeners();
        // Navigator.pop(context);
      }
      if (s == BluetoothDeviceState.disconnected) {
        // notificationManager.show('断开连接');
        reconnect();
      }
    });
  }

  void reconnect() {
    if (device == null) return;
    deviceConnection = _flutterBlue
        .connect(
          device,
          timeout: Duration(seconds: 60),
        )
        .listen(null, onDone: disconnect);
    device.state.then((s) {
      deviceState = s;
      notifyListeners();
    });

    _deviceStateSubscription = device.onStateChanged().listen((s) async {
      deviceState = s;
      notifyListeners();
      if (s == BluetoothDeviceState.connected) {
        valueChangedSubscriptions?.cancel();
        valueChangedSubscriptions = null;
        await this.scanServices(device);
        notifyListeners();
      }
      if (s == BluetoothDeviceState.disconnected) {
        // notificationManager.show('断开连接');
        reconnect();
      }
    });
  }

  Future disconnect() async {
    print('disconnect');
    await _deviceStateSubscription?.cancel();
    _deviceStateSubscription = null;
    await deviceConnection?.cancel();
    deviceConnection = null;
    await valueChangedSubscriptions?.cancel();
    valueChangedSubscriptions = null;
    if (device != null) {
      notificationManager.show('断开连接');
    }
    device = null;
    this.deviceState = BluetoothDeviceState.disconnected;
    print('change to: ${this.deviceState}');
    notifyListeners();
    return;
  }

  Future scanServices(BluetoothDevice targetDevice) async {
    List<BluetoothService> services = await targetDevice.discoverServices();

    for (BluetoothService service in services) {
      List<BluetoothCharacteristic> chars = service.characteristics;
      for (BluetoothCharacteristic char in chars) {
        if (char.uuid.toString() == targetUUIDString) {
          this.targetChar = char;
          targetDevice.setNotifyValue(char, true);
          valueChangedSubscriptions =
              targetDevice.onValueChanged(char).listen((value) {
            this._value = value;
            print(value);
            _chairState.setValue(value);
            // if (value != null && value[11] == 6) {
            //   this.notificationManager.show('666');
            // }
            targetDevice.writeCharacteristic(char, [0xbb, 0x01]);
            notifyListeners();
          });
        }
      }
    }

    return;
  }

  void scanToConnect(BluetoothDevice targetDevice) async {
    await stopScan();
    await this.disconnect();
    print('start scan');
    this._scanResults.clear();
    _scanSubscription =
        _flutterBlue.scan(timeout: Duration(seconds: 10)).listen((scanResult) {
          if (scanResult.device.id == targetDevice.id && scanResult.advertisementData.connectable) {
            connect(scanResult.device);
            _scanning = false;
          }
      notifyListeners();
    }, onDone: stopScan);
    _scanning = true;
    notifyListeners();
  }
}
