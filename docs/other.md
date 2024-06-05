## Other usages

## Show inspector manually

You may need that if you won't use shake or notification:

```dart
alice.showInspector();
```

## Saving calls

Alice supports saving logs to your mobile device storage. In order to make save feature works, you need to add in your Android application manifest:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

## Flutter logs

If you want to log Flutter logs in Alice, you may use these methods:

```dart
alice.addLog(log);

alice.addLogs(logList);
```


## Inspector state

Check current inspector state (opened/closed) with:

```dart
alice.isInspectorOpened();
```