# Migration

## Migration to 1.8.0

In recent versions, Alice underwent a significant architectural cleanup to improve maintainability and enforce a strict public API:

1. **Hidden Internal Implementation:** All internal files have been moved to the `lib/src/` directory. You should no longer use "deep imports" (e.g., `import 'package:alice/core/alice_logger.dart';`). 
2. **Strict Public API:** Only core classes prefixed with `Alice` (e.g., `AliceConfiguration`, `AliceLogger`, `AliceHttpCall`) are exposed in the public API. You can access all of them simply via:
```dart
import 'package:alice/alice.dart';
```
3. **Service Renames:** If you previously extended or used any internal `Helper` classes (like `ExportHelper` or `ReplayHelper`), note that they have been renamed to `Service` (e.g., `ExportService`) and are now considered private internal implementation details.
4. **Utils Renamed:** If you previously relied on the global `Utils` class for logging, it has been renamed to `AliceUtils` to comply with the prefixing rules. You can now use `AliceUtils.log()`.