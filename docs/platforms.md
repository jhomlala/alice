# Platform Support

Alice is a cross-platform HTTP inspector and supports all 6 major Flutter platforms.

| Platform | Supported | Notes |
| -------- | --------- | ----- |
| Android  | ✅ Yes     | Fully supported. |
| iOS      | ✅ Yes     | Fully supported. |
| macOS    | ✅ Yes     | Fully supported. |
| Linux    | ✅ Yes     | Fully supported. |
| Windows  | ✅ Yes     | Fully supported. |
| Web      | ✅ Yes     | Shake-to-open is not supported on Web. |

## Platform Specifics & Limitations

### Shake to open
Alice provides a feature to open the HTTP inspector by shaking the device. This relies on device accelerometer data.
- **Mobile (Android & iOS)**: Fully supported.
- **Desktop (macOS, Windows, Linux)**: Not supported. The feature gracefully falls back to a no-op to prevent crashes.
- **Web**: Not supported. 

### Exporting and Saving Calls
Alice allows you to save your HTTP calls to a file on the device.
- **iOS**: Alice explicitly requests storage permissions using `permission_handler` before saving.
- **Other Platforms**: Alice handles file saving without explicit runtime storage permission requests from the package itself (relying on platform defaults or application-level configurations).
