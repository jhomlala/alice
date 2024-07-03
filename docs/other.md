## Other usages

## Show inspector manually

You may need that if you won't use shake or notification:

```dart
alice.showInspector();
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