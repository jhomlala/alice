import 'package:alice/alice.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Alice _alice;

  @override
  void initState() {
    _alice = Alice(
      showNotification: true,
      showInspectorOnShake: true,
      maxCallsCount: 1000,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Alice HTTP Inspector - Example'),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Text(
                  'Welcome to example of Alice Http Inspector. Click buttons below to generate sample data.'),
              ElevatedButton(
                child: Text(
                  'Log example data',
                ),
                onPressed: _logExampleData,
              ),
              const SizedBox(height: 24),
              Text(
                  'After clicking on buttons above, you should receive notification.'
                  ' Click on it to show inspector. You can also shake your device or click button below.'),
              ElevatedButton(
                child: Text(
                  'Run HTTP Inspector',
                ),
                onPressed: _runHttpInspector,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _logExampleData() {
    final List<AliceLog> logs = [];
    logs.add(
      AliceLog(
        level: DiagnosticLevel.info,
        timestamp: DateTime.now(),
        message: 'Info log',
      ),
    );
    logs.add(
      AliceLog(
        level: DiagnosticLevel.debug,
        timestamp: DateTime.now(),
        message: 'Debug log',
      ),
    );
    logs.add(
      AliceLog(
        level: DiagnosticLevel.warning,
        timestamp: DateTime.now(),
        message: 'Warning log',
      ),
    );
    final notNumber = 'afs';
    try {
      int.parse(notNumber);
    } catch (e, stacktrace) {
      logs.add(
        AliceLog(
          level: DiagnosticLevel.error,
          timestamp: DateTime.now(),
          message: 'Error log',
          error: e,
          stackTrace: stacktrace,
        ),
      );
    }
    _alice.addLogs(logs);
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
