import 'package:flutter/material.dart';

class Alert {
  static show(BuildContext context, {String title = '提示', @required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(title: title, message: message)
    );
  }
}

class AlertDialog extends StatelessWidget {
  final String message;
  final String title;
  AlertDialog({this.title, this.message});

  Widget buildMessageBody() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(message),
    );
  }

  Widget buildCloseBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('确定'),
        textColor: Colors.white,
        color: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
      children: <Widget>[
        buildMessageBody(),
        buildCloseBtn(context),
      ],
    );
  }
}