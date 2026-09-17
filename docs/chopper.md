# Chopper

To use Alice with Chopper, add the adapter to your project.

## Installation

Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice_chopper: ^1.3.0
```

## Usage

```dart
/// Create Alice instance
Alice alice = Alice();

/// Create Alice Chopper Adapter
AliceChopperAdapter aliceChopperAdapter = AliceChopperAdapter();

///Add adapter to Alice
alice.addAdapter(aliceChopperAdapter);

/// Create chopper client
ChopperClient chopperClient = ChopperClient(
    interceptors: [_aliceChopperAdapter],
);
```

## Example

[View the full Alice Chopper Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_chopper)
