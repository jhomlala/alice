import 'package:alice/alice.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Alice _alice = Alice(
    showNotification: true,
    showInspectorOnShake: true,
    maxCallsCount: 1000,
  );

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
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'Welcome to example of Alice Http Inspector. '
                'Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _logExampleData,
                child: const Text(
                  'Log example data',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'After clicking on buttons above, you should receive notification.'
                ' Click on it to show inspector. You can also shake your device or click button below.',
              ),
              ElevatedButton(
                onPressed: _runHttpInspector,
                child: const Text(
                  'Run HTTP Inspector',
                ),
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
    const String notNumber = 'afs';
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
