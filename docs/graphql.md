# GraphQL

To use Alice with `graphql_flutter`, add `AliceGraphQLLink` to your link chain. You can optionally pass the `url` to properly format the endpoint and server in the Alice inspector.

```dart
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
