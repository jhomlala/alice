import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:alice_graphql_client/alice_graphql_client.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final alice = Alice(configuration: AliceConfiguration(showNotification: true));
  
  final httpLink = HttpLink('https://countries.trevorblades.com/');
  final link = Link.from([
    AliceGraphQLLink(alice),
    httpLink,
  ]);

  final client = ValueNotifier(
    GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    ),
  );

  runApp(MyApp(client: client, alice: alice));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final Alice alice;

  const MyApp({super.key, required this.client, required this.alice});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        navigatorKey: alice.getNavigatorKey(),
        home: Scaffold(
          appBar: AppBar(title: const Text('Alice GraphQL Example')),
          body: Query(
            options: QueryOptions(document: gql('query { countries { name } }')),
            builder: (result, {fetchMore, refetch}) {
              if (result.isLoading) return const Center(child: CircularProgressIndicator());
              if (result.hasException) return Text(result.exception.toString());
              final countries = result.data!['countries'] as List;
              return ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) => ListTile(title: Text(countries[index]['name'])),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => alice.showInspector(),
            child: const Icon(Icons.bug_report),
          ),
        ),
      ),
    );
  }
}
