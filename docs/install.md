# How to install

1. Add this to your **pubspec.yaml** file:

```yaml
dependencies:
  alice: ^1.0.0-dev10
```

2. Choose adapter based on your HTTP client. **pubspec.yaml** file:

### Dio

```yaml
dependencies:
  alice_dio: ^1.0.4
```

### Chopper

```yaml
dependencies:
  alice_chopper: ^1.0.5
```

### Http

```yaml
dependencies:
  alice_http: ^1.0.4
```

### Http Client

```yaml
dependencies:
  alice_http_client: ^1.0.4
```

3. Choose optional database:

### Objectbox

```yaml
dependencies:
  objectbox: any
  alice_objectbox: ^1.0.2
```

4. Run `get` command:

```bash
$ flutter packages get
```