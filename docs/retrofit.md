# Retrofit

Alice supports [Retrofit](https://pub.dev/packages/retrofit) out of the box because it is built on top of [Dio](https://pub.dev/packages/dio).

To integrate Alice with Retrofit, you simply need to add the `alice_dio` interceptor to the `Dio` instance that is passed to your Retrofit `RestClient` constructor.

## Setup

1. Add `alice` and `alice_dio` to your `pubspec.yaml` dependencies.
2. Initialize `Alice`:

```dart
Alice alice = Alice(navigatorKey: navigatorKey);
```

3. Configure your `Dio` instance:

```dart
final dio = Dio();
dio.interceptors.add(alice.getDioInterceptor());
```

4. Pass the `dio` instance to your `RestClient`:

```dart
final client = RestClient(dio);
```

Now, all network requests performed by your `RestClient` will be captured and displayed in the Alice inspector.
