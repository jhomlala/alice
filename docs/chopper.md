# Chopper

To use Alice with Chopper, add the adapter to your project.

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  alice: ^1.11.1
  alice_chopper: ^1.3.4
```

## Usage

```dart
import 'package:alice/alice.dart';
import 'package:alice_chopper/alice_chopper_adapter.dart';
import 'package:chopper/chopper.dart';

// Create Alice instance
Alice alice = Alice();

// Create Alice Chopper Adapter
AliceChopperAdapter aliceChopperAdapter = AliceChopperAdapter();

// Add adapter to Alice
alice.addAdapter(aliceChopperAdapter);

// Create chopper client
ChopperClient chopperClient = ChopperClient(
  interceptors: [aliceChopperAdapter],
);
```

## Example

[View the full Alice Chopper Example on GitHub](https://github.com/jhomlala/alice/tree/master/examples/alice_chopper)
