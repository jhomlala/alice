import 'package:flutter/material.dart';
import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'rest_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      home: const MyHomePage(),
    );
  }
}

final alice = Alice();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late RestClient client;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    aliceDioAdapter = AliceDioAdapter();
    alice.addAdapter(aliceDioAdapter);
    dio.interceptors.add(aliceDioAdapter);
    client = RestClient(dio);
  }

  late AliceDioAdapter aliceDioAdapter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alice Retrofit Example")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await client.getPost(1);
              },
              child: const Text("Trigger Request"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                alice.showInspector();
              },
              child: const Text("Open Alice Inspector"),
            ),
          ],
        ),
      ),
    );
  }
}
