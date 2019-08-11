import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

class AliceStatsScreen extends StatelessWidget {
  final List<AliceHttpCall> calls;

  const AliceStatsScreen(this.calls);

  @override
  Widget build(BuildContext context) {
    int bytesSent = _getBytesSent();
    int bytesReceived = _getBytesReceived();
    return Scaffold(
      appBar: AppBar(
        title: Text("Alice - HTTP Inspector - Stats"),
      ),
      body: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              _getRow("Total requests:", "${_getTotalRequests()}"),
              _getRow("Pending requests:", "${_getPendingRequests()}"),
              _getRow("Success requests:", "${_getSuccessRequests()}"),
              _getRow("Redirection requests:", "${_getRedirectionRequests()}"),
              _getRow("Error requests:", "${_getErrorRequests()}"),
              _getRow("Bytes send:",
                  "$bytesSent bytes (${_getKilobytes(bytesSent)} KB)"),
              _getRow("Bytes received:",
                  "$bytesReceived bytes (${_getKilobytes(bytesReceived)} KB)"),
              _getRow(
                  "Average request time:", "${_getAverageRequestTime()} ms"),
              _getRow("Max request time:", "${_getMaxRequestTime()} ms"),
              _getRow("Min request time:", "${_getMinRequestTime()} ms"),
              _getRow("Get requests:", "${_getRequests("GET")} "),
              _getRow("Post requests:", "${_getRequests("POST")} "),
              _getRow("Delete requests:", "${_getRequests("DELETE")} "),
              _getRow("Put requests:", "${_getRequests("PUT")} "),
              _getRow("Patch requests:", "${_getRequests("PATCH")} "),
              _getRow("Secured requests:", "${_getSecuredRequests()}"),
              _getRow("Unsecured requests:", "${_getUnsecuredRequests()}"),
            ],
          ))),
    );
  }

  Row _getRow(String label, String value) {
    return Row(
      children: <Widget>[
        Text(
          label,
          style: _getLabelTextStyle(),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10),
        ),
        Text(
          value,
          style: _getValueTextStyle(),
        )
      ],
    );
  }

  TextStyle _getLabelTextStyle() {
    return TextStyle(fontSize: 16);
  }

  TextStyle _getValueTextStyle() {
    return TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  }

  int _getTotalRequests() {
    return calls.length;
  }

  int _getSuccessRequests() {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.response != null &&
          call.response.status >= 200 &&
          call.response.status < 300) {
        requests++;
      }
    });
    return requests;
  }

  int _getRedirectionRequests() {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.response != null &&
          call.response.status >= 300 &&
          call.response.status < 400) {
        requests++;
      }
    });
    return requests;
  }

  int _getErrorRequests() {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.response != null &&
          call.response.status >= 400 &&
          call.response.status < 600) {
        requests++;
      }
    });
    return requests;
  }

  int _getPendingRequests() {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.loading) {
        requests++;
      }
    });
    return requests;
  }

  int _getBytesSent() {
    int bytes = 0;
    calls.forEach((AliceHttpCall call) {
      bytes += call.request.size;
    });
    return bytes;
  }

  int _getBytesReceived() {
    int bytes = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.response != null) {
        bytes += call.response.size;
      }
    });
    return bytes;
  }

  int _getKilobytes(int bytes) {
    return bytes ~/ 1000;
  }

  int _getAverageRequestTime() {
    int requestTimeSum = 0;
    int requestsWithDurationCount = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.duration != 0) {
        requestTimeSum = call.duration;
        requestsWithDurationCount++;
      }
    });
    if (requestTimeSum == 0) {
      return 0;
    }
    return requestTimeSum ~/ requestsWithDurationCount;
  }

  int _getMaxRequestTime() {
    int maxRequestTime = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.duration > maxRequestTime) {
        maxRequestTime = call.duration;
      }
    });
    return maxRequestTime;
  }

  int _getMinRequestTime() {
    int minRequestTime = 10000000;
    if (calls.length == 0) {
      minRequestTime = 0;
    } else {
      calls.forEach((AliceHttpCall call) {
        if (call.duration != 0 && call.duration < minRequestTime) {
          minRequestTime = call.duration;
        }
      });
    }
    return minRequestTime;
  }

  int _getRequests(String requestType) {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.method == requestType) {
        requests++;
      }
    });
    return requests;
  }

  int _getSecuredRequests() {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (call.secure) {
        requests++;
      }
    });
    return requests;
  }

  int _getUnsecuredRequests() {
    int requests = 0;
    calls.forEach((AliceHttpCall call) {
      if (!call.secure) {
        requests++;
      }
    });
    return requests;
  }
}
