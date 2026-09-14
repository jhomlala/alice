import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_graphql_client/alice_graphql_client.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final configuration = AliceConfiguration(showShareButton: true);
  late final Alice _alice = Alice(configuration: configuration);
  late final ValueNotifier<GraphQLClient> _client;

  @override
  void initState() {
    super.initState();
    final url = 'https://countries.trevorblades.com/';
    final httpLink = HttpLink(url);
    final link = Link.from([AliceGraphQLLink(_alice, url: url), httpLink]);

    _client = ValueNotifier(GraphQLClient(cache: GraphQLCache(), link: link));
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: _client,
      child: MaterialApp(
        navigatorKey: _alice.getNavigatorKey(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(title: const Text('Alice + GraphQL - Example')),
          body: Container(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                const SizedBox(height: 8),
                const Text(
                  style: TextStyle(fontSize: 14),
                  'Welcome to example of Alice + GraphQL Example. '
                  'Click buttons below to generate sample data.',
                ),
                ElevatedButton(
                  onPressed: _runGraphQLRequests,
                  child: const Text('Run GraphQL Requests'),
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
      ),
    );
  }

  void _runGraphQLRequests() async {
    final client = _client.value;

    // Simple Query
    await client.query(
      QueryOptions(document: gql('query { countries { name } }')),
    );

    // Another Query
    await client.query(
      QueryOptions(
        document: gql('query { country(code: "PL") { name native } }'),
      ),
    );
  }

  void _runHttpInspector() {
    _alice.showInspector();
  }
}
