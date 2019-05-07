import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_test/utils/StoreManager.dart';

class EditNameDialog {
  static Future show(BuildContext context, BluetoothDevice device) {
    return showDialog(
        context: context, builder: (context) => _NameDialog(device: device));
  }
}

class _NameDialog extends StatefulWidget {
  final BluetoothDevice device;
  _NameDialog({@required this.device});
  @override
  __NameDialogState createState() => __NameDialogState();
}

class __NameDialogState extends State<_NameDialog> {
  TextEditingController controller;
  String deviceName;
  @override
  void initState() {
    super.initState();
    deviceName = widget.device.name;
    controller = TextEditingController(text: widget.device.name);
  }

  Widget buildInputBox() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(15),
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onChanged: (String value) {
          setState(() {
            deviceName = value;
          });
        },
      ),
    );
  }

  Widget buildBtnGroup(BuildContext context) {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('关闭'),
          // textColor: Colors.blue,
        ),
        FlatButton(
          onPressed: deviceName.isEmpty ? null : () async {
            await StoreManager.saveChairName(widget.device.id, controller.text);
            Navigator.pop(context);
          },
          child: Text('确定'),
          textColor: Colors.white,
          color: Colors.blue,
        ),
      ],
    );
  }

  // Widget buildCloseBtn(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20),
  //     child: FlatButton(
  //       onPressed: () {
  //         Navigator.pop(context);
  //       },
  //       shape: RoundedRectangleBorder(
  //         side: BorderSide(width: 1, color: Colors.black)
  //       ),
  //       child: Text('关闭'),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SimpleDialog(
        title: Text('输入名称'),
        children: <Widget>[
          buildInputBox(),
          buildBtnGroup(context),
        ],
      ),
    );
  }
}
