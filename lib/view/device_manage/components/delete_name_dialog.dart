import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:ble_test/utils/StoreManager.dart';

class DeleteNameDialog {
  static Future show(BuildContext context, BluetoothDevice device) {
    return showDialog(
        context: context, builder: (context) => _ConfrimDialog(device: device));
  }
}

class _ConfrimDialog extends StatelessWidget {
  final BluetoothDevice device;
  _ConfrimDialog({@required this.device});

  Widget buildMessageBox() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Text('确定要删除设备吗'),
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
          onPressed: () async {
            await StoreManager.saveChairName(device.id, null);
            Navigator.pop(context);
          },
          child: Text('删除'),
          textColor: Colors.white,
          color: Colors.red,
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
        title: Text('删除设备'),
        children: <Widget>[
          buildMessageBox(),
          buildBtnGroup(context),
        ],
      ),
    );
  }
}
