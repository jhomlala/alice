# How to install

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice: ^1.0.0
```

2. Choose adapter based on your HTTP client. **pubspec.yaml** file:

### Dio

```yaml
dependencies:
  alice_dio: ^1.0.7
```

### Chopper

```yaml
dependencies:
  alice_chopper: ^1.0.8
```

### Http

```yaml
dependencies:
  alice_http: ^1.0.7
```

### Http Client

```yaml
dependencies:
  alice_http_client: ^1.0.7
```

3. Choose optional database:

### Objectbox

```yaml
dependencies:
  objectbox: any
  alice_objectbox: ^1.0.4
```

4. Run `get` command:

```bash
$ flutter packages get
```