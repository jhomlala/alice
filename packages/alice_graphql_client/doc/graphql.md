# GraphQL

To use Alice with `graphql_flutter`, add `AliceGraphQLLink` to your link chain.

```dart
import 'package:alice/alice.dart';
import 'package:alice_graphql_client/alice_graphql_client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

final alice = Alice();
final link = Link.from([
  AliceGraphQLLink(alice: alice),
  HttpLink('https://your-api.com/graphql'),
]);

final client = GraphQLClient(
  cache: GraphQLCache(),
  link: link,
);
```
