import 'package:alice/core/alice_adapter.dart';
import 'package:grpc/grpc.dart';

class AliceGrpcAdapter extends ClientInterceptor with AliceAdapter {
  @override
  ResponseFuture<R> interceptUnary<Q, R>(ClientMethod<Q, R> method, Q request,
      CallOptions options, ClientUnaryInvoker<Q, R> invoker) {
   print(request);
    return super.interceptUnary(method, request, options, invoker);
  }
}
