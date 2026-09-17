# Alice Project Architecture

## Overview

The `alice` package is structured to separate public API models, core orchestration, side-effect driven services, pure utilities, and internal UI components. 

### Directory Structure

- **`lib/core/`**: Central orchestration (`AliceCore`, `AliceAdapter`) and global configurations.
- **`lib/services/`**: Side-effect driven operations (e.g., File Saving, SharedPreferences Storage, Shake Detection, Logcat access). Grouped by feature with self-contained platform abstractions.
- **`lib/utils/`**: Pure functions, parsers, and formatters (e.g., `Curl`, `AliceParser`).
- **`lib/export/`**: Exporters and export managers (HAR, Text).
- **`lib/ui/`**: All internal screens, widgets, and dialogs.
- **`lib/model/`**: Data models.

## Naming Conventions (Effective Dart)

Following Effective Dart guidelines ("Avoid prefixing library names and identifiers with the package name"), we employ the following naming strategy:

1. **Public API (Prefixed with `Alice`)**:
   Classes exported in `lib/alice.dart` (or meant to be consumed by external adapters/projects) retain the `Alice` prefix to prevent namespace collisions in consuming applications (e.g., avoiding conflicts with `dart:io`'s `HttpRequest`).
   - Examples: `Alice`, `AliceCore`, `AliceHttpCall`, `AliceLogger`, `AliceConfiguration`, `AliceMemoryStorage`.

2. **Internal Classes (No Prefix)**:
   All internal classes that are **not exported** to the public API strip the `Alice` prefix entirely. 
   - UI Widgets: `CallsListScreen`, `InspectorScreen`
   - Services: `ShareService`, `PackageInfoService`, `PermissionService`, `NotificationService`
   - Exporters: `TextExporter`, `HarExporter`, `ExportService`
   - Utilities: `ConversionUtils`, `Utils`

3. **Service Suffix**:
   Any class that provides system-level, side-effect, or platform-integration features is suffixed with `Service` (e.g., `LogcatService`, `PackageInfoService`, `ReplayService`) for consistency, replacing older `Helper` or `Provider` suffixes.
