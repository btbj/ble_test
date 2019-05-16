import 'package:flutter/material.dart';
import 'package:ble_test/view/log_page/log_page.dart';

class SideMenu extends StatefulWidget {
  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildClearBtn() {
    return FlatButton(
      child: ListTile(
        title: Text('Logs'),
      ),
      onPressed: () {
        print('open log');
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => LogPage(),
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
            // title: Text('Menu'),
            ),
        body: Column(
          children: <Widget>[
            _buildClearBtn(),
          ],
        ),
      ),
    );
  }
}
