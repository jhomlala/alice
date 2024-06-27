import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';
import 'package:alice_objectbox/model/cached_alice_http_request.dart';
import 'package:alice_objectbox/model/cached_alice_http_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

part 'cached_alice_http_call.g.dart';

@Entity()
@JsonSerializable(explicitToJson: true)
class CachedAliceHttpCall implements AliceHttpCall {
  CachedAliceHttpCall(
    this.id, {
    this.objectId = 0,
    this.client = '',
    this.loading = true,
    this.secure = false,
    this.method = '',
    this.endpoint = '',
    this.server = '',
    this.uri = '',
    this.duration = 0,
  }) {
    createdTime = DateTime.timestamp();
  }

  @Id()
  @JsonKey(includeFromJson: false, includeToJson: false)
  int objectId;

  @override
  @Index(type: IndexType.value)
  @Unique(onConflict: ConflictStrategy.replace)
  final int id;

  @override
  @Property(type: PropertyType.dateNano)
  late DateTime createdTime;

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
  @JsonKey(
    toJson: _aliceHttpRequestToJson,
    fromJson: CachedAliceHttpRequest.fromJson,
  )
  AliceHttpRequest? get request => requestRel?.target;

  @override
  @Transient()
  set request(AliceHttpRequest? value) {
    requestRel?.target = value != null
        ? CachedAliceHttpRequest.fromAliceHttpRequest(value)
        : null;
  }

  static _aliceHttpRequestToJson(AliceHttpRequest? request) => request != null
      ? CachedAliceHttpRequest.fromAliceHttpRequest(request).toJson()
      : null;

  @protected
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ToOne<CachedAliceHttpRequest>? requestRel =
      ToOne<CachedAliceHttpRequest>();

  @override
  @Transient()
  @JsonKey(
    toJson: _aliceHttpResponseToJson,
    fromJson: CachedAliceHttpResponse.fromJson,
  )
  AliceHttpResponse? get response => responseRel?.target;

  @override
  @Transient()
  set response(AliceHttpResponse? value) {
    responseRel?.target = value != null
        ? CachedAliceHttpResponse.fromAliceHttpResponse(value)
        : null;
  }

  static _aliceHttpResponseToJson(AliceHttpResponse? response) =>
      response != null
          ? CachedAliceHttpResponse.fromAliceHttpResponse(response).toJson()
          : null;

  @protected
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ToOne<CachedAliceHttpResponse>? responseRel =
      ToOne<CachedAliceHttpResponse>();

  @override
  @Transient()
  @JsonKey(
    toJson: _aliceHttpErrorToJson,
    fromJson: CachedAliceHttpError.fromJson,
  )
  AliceHttpError? get error => errorRel?.target;

  @override
  @Transient()
  set error(AliceHttpError? value) {
    errorRel?.target =
        value != null ? CachedAliceHttpError.fromAliceHttpError(value) : null;
  }

  static _aliceHttpErrorToJson(AliceHttpError? error) => error != null
      ? CachedAliceHttpError.fromAliceHttpError(error).toJson()
      : null;

  @protected
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ToOne<CachedAliceHttpError>? errorRel = ToOne<CachedAliceHttpError>();

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

  factory CachedAliceHttpCall.fromJson(Map<String, dynamic> json) =>
      _$CachedAliceHttpCallFromJson(json);

  Map<String, dynamic> toJson() => _$CachedAliceHttpCallToJson(this);
}
