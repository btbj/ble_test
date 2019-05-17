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
              List<String> info = snapshot.data[index].split(':');
              bool connected = info[0] == 'C';
              DateTime time =
                  DateTime.fromMillisecondsSinceEpoch(int.parse(info[1]));
              int diffseconds = 0;
              String diff = '';
              if (index > 0) {
                List<String> previnfo = snapshot.data[index - 1].split(':');
                DateTime prevtime =
                    DateTime.fromMillisecondsSinceEpoch(int.parse(previnfo[1]));
                diffseconds = time.difference(prevtime).inSeconds;
                diff = '$diffseconds' + 's';
              }
              return ListTile(
                leading: SizedBox(
                  height: 35,
                  width: 20,
                  child: Center(
                    child: Text(
                      connected ? 'C' : 'D',
                      style: TextStyle(
                        color: connected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(time.toString()),
                trailing: Text(
                  diff,
                  style: TextStyle(
                      color: diffseconds > 70 ? Colors.red : Colors.green),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          String log = 'C:' + DateTime.now().millisecondsSinceEpoch.toString();
          print(log);
          List<String> data = log.split(':');
          var time = DateTime.fromMillisecondsSinceEpoch(int.parse(data[1]));
          print(time);
          await logManager.append(log);
        },
      ),
    );
  }
}
