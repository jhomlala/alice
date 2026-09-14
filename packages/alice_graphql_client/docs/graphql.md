# GraphQL Integration

To use Alice with `graphql_flutter`, add `AliceGraphQLLink` to your link chain.

```dart
final alice = Alice();
final link = Link.from([
  AliceGraphQLLink(alice),
  HttpLink('https://your-api.com/graphql'),
]);

final client = GraphQLClient(
  cache: GraphQLCache(),
  link: link,
);
```
