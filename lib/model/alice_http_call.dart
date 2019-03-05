import 'package:alice/model/alice_http_error.dart';
import 'package:alice/model/alice_http_request.dart';
import 'package:alice/model/alice_http_response.dart';

class AliceHttpCall{
  final int id;
  String client = "";
  bool loading = true;
  bool secure = false;
  String method = "";
  String endpoint = "";
  String server = "";
  int duration = 0;

  AliceHttpRequest request;
  AliceHttpResponse response;
  AliceHttpError error;

  AliceHttpCall(this.id){
    loading = true;
  }

  setResponse(AliceHttpResponse response){
    this.response = response;
    loading = false;
  }
}