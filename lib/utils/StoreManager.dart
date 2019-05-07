import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_blue/flutter_blue.dart';

class StoreManager {
  static final chairNameMapKey = 'chairNameMap';
  static final lastConnectedKey = 'lastConnectedDeviceId';

  static Future saveLastConnectedDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastConnectedKey, device.id.toString());
    return;
  }

  static Future<BluetoothDevice> getLastConnectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final String id = prefs.getString(lastConnectedKey);
    if (id.isEmpty) {
      return null;
    } else {
      return BluetoothDevice(id: DeviceIdentifier(id));
    }
  }

  static Future<Map<String, dynamic>> getChairNameMap() async {
    final prefs = await SharedPreferences.getInstance();
    String savedString = prefs.getString(chairNameMapKey) ?? '{}';
    final chairNameMap = jsonDecode(savedString);
    return chairNameMap;
  }

  static Future saveChairName(DeviceIdentifier id, String name) async {
    final savedChairName = await getChairNameMap();
    if (name == null) {
      savedChairName.remove(id.toString());
    } else {
      savedChairName[id.toString()] = name;
    }

    final prefs = await SharedPreferences.getInstance();
    final newDataString = jsonEncode(savedChairName);
    await prefs.setString(chairNameMapKey, newDataString);
    return;
  }
}