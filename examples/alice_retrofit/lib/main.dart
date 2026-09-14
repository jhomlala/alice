import 'package:flutter/material.dart';
import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'rest_client.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AliceDioAdapter _aliceDioAdapter = AliceDioAdapter();

  final configuration = AliceConfiguration(showShareButton: true);
  late final Alice _alice = Alice(configuration: configuration)
    ..addAdapter(_aliceDioAdapter);

  late final Dio _dio = Dio(BaseOptions(followRedirects: false))
    ..interceptors.add(_aliceDioAdapter);

  late final RestClient _client = RestClient(_dio);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _alice.getNavigatorKey(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Alice + Retrofit - Example')),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'Welcome to example of Alice + Retrofit Example. '
                'Click buttons below to generate sample data.',
              ),
              ElevatedButton(
                onPressed: _runRetrofitRequests,
                child: const Text('Run Retrofit HTTP Requests'),
              ),
              const SizedBox(height: 8),
              const Text(
                style: TextStyle(fontSize: 14),
                'After clicking on buttons above, you should receive notification.'
                ' Click on it to show inspector. You can also shake your device or click button below.',
              ),
              ElevatedButton(
                onPressed: _runHttpInspector,
                child: const Text('Run HTTP Inspector'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runRetrofitRequests() async {
    try {
      await _client.getPost(1);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
