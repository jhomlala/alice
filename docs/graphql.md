# GraphQL

To use Alice with `graphql_flutter`, add `AliceGraphQLLink` to your link chain. You can optionally pass `url` to format the endpoint and server in the Alice inspector.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  alice: ^2.0.0
  alice_graphql_client: ^1.2.0
```

## Usage

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

## Example

[View the full Alice GraphQL Client Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_graphql_client)
