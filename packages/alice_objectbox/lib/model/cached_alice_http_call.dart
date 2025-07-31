// ignore_for_file: must_be_immutable

import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:alice_objectbox/extensions/alice_http_error_extension.dart';
import 'package:alice_objectbox/extensions/alice_http_request_extension.dart';
import 'package:alice_objectbox/extensions/alice_http_response_extension.dart';
import 'package:alice_objectbox/model/cached_alice_http_error.dart';
import 'package:alice_objectbox/model/cached_alice_http_request.dart';
import 'package:alice_objectbox/model/cached_alice_http_response.dart';
import 'package:meta/meta.dart';
import 'package:objectbox/objectbox.dart';

/// ObjectBox [Entity] of [AliceHttpCall].
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

  /// ObjectBox internal ID.
  @internal
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
  set request(AliceHttpRequest? value) => requestRel.target = value?.toCached();

  /// [ToOne] relation of [request].
  @internal
  final ToOne<CachedAliceHttpRequest> requestRel =
      ToOne<CachedAliceHttpRequest>();

  @override
  @Transient()
  AliceHttpResponse? get response => responseRel.target;

  @override
  @Transient()
  set response(AliceHttpResponse? value) =>
      responseRel.target = value?.toCached();

  /// [ToOne] relation of [response].
  @internal
  final ToOne<CachedAliceHttpResponse> responseRel =
      ToOne<CachedAliceHttpResponse>();

  @override
  @Transient()
  AliceHttpError? get error => errorRel.target;

  @override
  @Transient()
  set error(AliceHttpError? value) => errorRel.target = value?.toCached();

  /// [ToOne] relation of [error].
  @internal
  final ToOne<CachedAliceHttpError> errorRel = ToOne<CachedAliceHttpError>();

  @override
  List<Object?> get props => [
    id,
    createdTime,
    client,
    loading,
    secure,
    method,
    endpoint,
    server,
    uri,
    duration,
    request,
    response,
    error,
  ];

  @override
  bool? get stringify => true;
}
