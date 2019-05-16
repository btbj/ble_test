import 'package:flutter/material.dart';
import 'package:ble_test/utils/LogManager.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  LogManager logManager;

  @override
  void initState() {
    logManager = LogManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
        actions: <Widget>[
          FlatButton(
            child: Text('clear'),
            onPressed: () async {
              await logManager.clear();
            },
            textColor: Colors.white,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: logManager.logSubject,
        initialData: [],
        builder: (context, snapshot) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data[index]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // await logManager.append('test log');
        },
      ),
    );
  }
}
