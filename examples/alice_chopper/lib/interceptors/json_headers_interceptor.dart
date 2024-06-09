import 'dart:async' show FutureOr;
import 'dart:io' show ContentType, HttpHeaders;

import 'package:chopper/chopper.dart';

class JsonHeadersInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) =>
      chain.proceed(
        applyHeader(
          chain.request,
          HttpHeaders.acceptHeader,
          ContentType.json.mimeType,
        ),
      );
}
