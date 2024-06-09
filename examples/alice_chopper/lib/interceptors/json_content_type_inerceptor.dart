import 'dart:async' show FutureOr;
import 'dart:io' show ContentType, HttpHeaders;

import 'package:chopper/chopper.dart';

class JsonContentTypeInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) =>
      switch (chain.request.method) {
        HttpMethod.Post || HttpMethod.Put || HttpMethod.Patch => chain.proceed(
            applyHeader(
              chain.request,
              HttpHeaders.contentTypeHeader,
              ContentType.json.mimeType,
            ),
          ),
        _ => chain.proceed(chain.request),
      };
}
