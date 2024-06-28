import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';
import 'package:alice_objectbox/model/cached_alice_http_request.dart';
import 'package:alice_objectbox/model/cached_alice_http_response.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class CachedAliceHttpCall implements AliceHttpCall {
  CachedAliceHttpCall(
    this.id, {
    this.objectId = 0,
    DateTime? createdTime,
    this.client = '',
    this.loading = true,
    this.secure = false,
    this.method = '',
    this.endpoint = '',
    this.server = '',
    this.uri = '',
    this.duration = 0,
  }) : createdTime = createdTime ?? DateTime.now();

  @Id()
  int objectId;

  @override
  @Index(type: IndexType.value)
  @Unique(onConflict: ConflictStrategy.replace)
  final int id;

  @override
  @Property(type: PropertyType.dateNano)
  DateTime createdTime;

  @override
  String client;

  @override
  bool loading;

  @override
  bool secure;

  @override
  String method;

  @override
  String endpoint;

  @override
  String server;

  @override
  String uri;

  @override
  int duration;

  @override
  @Transient()
  AliceHttpRequest? get request => requestRel.target;

  @override
  @Transient()
  set request(AliceHttpRequest? value) {
    requestRel.target = value != null
        ? CachedAliceHttpRequest.fromAliceHttpRequest(value)
        : null;
  }

  @protected
  final ToOne<CachedAliceHttpRequest> requestRel =
      ToOne<CachedAliceHttpRequest>();

  @override
  @Transient()
  AliceHttpResponse? get response => responseRel.target;

  @override
  @Transient()
  set response(AliceHttpResponse? value) {
    responseRel.target = value != null
        ? CachedAliceHttpResponse.fromAliceHttpResponse(value)
        : null;
  }

  @protected
  final ToOne<CachedAliceHttpResponse> responseRel =
      ToOne<CachedAliceHttpResponse>();

  @override
  @Transient()
  AliceHttpError? get error => errorRel.target;

  @override
  @Transient()
  set error(AliceHttpError? value) {
    errorRel.target =
        value != null ? CachedAliceHttpError.fromAliceHttpError(value) : null;
  }

  @protected
  final ToOne<CachedAliceHttpError> errorRel = ToOne<CachedAliceHttpError>();

  @override
  void setResponse(AliceHttpResponse response) {
    this.response = response;
    loading = false;
  }

  factory CachedAliceHttpCall.fromAliceHttpCall(AliceHttpCall call) =>
      CachedAliceHttpCall(
        call.id,
        client: call.client,
        loading: call.loading,
        secure: call.secure,
        method: call.method,
        endpoint: call.endpoint,
        server: call.server,
        uri: call.uri,
        duration: call.duration,
      )
        ..error = call.error
        ..request = call.request
        ..response = call.response;
}
