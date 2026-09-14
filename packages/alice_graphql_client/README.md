# alice_graphql_client

A GraphQL adapter for Alice.

## Usage

To use Alice with `graphql_flutter`, add `AliceGraphQLLink` to your link chain. You can optionally pass the `url` to properly format the endpoint and server in the Alice inspector.

```dart
import 'package:alice/alice.dart';
import 'package:alice_graphql_client/alice_graphql_client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final alice = Alice();
final url = 'https://your-api.com/graphql';

final link = Link.from([
  AliceGraphQLLink(alice: alice, url: url),
  HttpLink(url),
]);

final client = GraphQLClient(
  cache: GraphQLCache(),
  link: link,
);
```
