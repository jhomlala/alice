import 'package:alice/src/model/alice_http_call.dart';

class SearchFilter {
  final String? method;
  final String? status;
  final String? host;
  final String? client;
  final String? duration;
  final String? tag;
  final bool duplicate;
  final String? text;

  SearchFilter({
    this.method,
    this.status,
    this.host,
    this.client,
    this.duration,
    this.tag,
    this.duplicate = false,
    this.text,
  });

  factory SearchFilter.parse(String query) {
    final regex = RegExp(
      r'(method|status|host|server|client|duration|tag|duplicate):([^\s]+)',
      caseSensitive: false,
    );
    final matches = regex.allMatches(query);

    String? method;
    String? status;
    String? host;
    String? client;
    String? duration;
    String? tag;
    bool duplicate = false;

    var remainingText = query;
    for (final match in matches) {
      final key = match.group(1)?.toLowerCase();
      final value = match.group(2);

      switch (key) {
        case 'method':
          method = value;
        case 'status':
          status = value;
        case 'host':
        case 'server':
          host = value;
        case 'client':
          client = value;
        case 'duration':
          duration = value;
        case 'tag':
          tag = value;
        case 'duplicate':
          duplicate = value?.toLowerCase() == 'true';
      }
      remainingText = remainingText.replaceFirst(match.group(0)!, '');
    }

    return SearchFilter(
      method: method?.toLowerCase(),
      status: status,
      host: host?.toLowerCase(),
      client: client?.toLowerCase(),
      duration: duration,
      tag: tag?.toLowerCase(),
      duplicate: duplicate,
      text: remainingText.trim().toLowerCase(),
    );
  }

  bool apply(AliceHttpCall call) {
    if (method != null && !call.method.toLowerCase().contains(method!)) {
      return false;
    }
    if (status != null && call.response?.status?.toString() != status) {
      return false;
    }
    if (host != null && !call.server.toLowerCase().contains(host!)) {
      return false;
    }
    if (client != null && !call.client.toLowerCase().contains(client!)) {
      return false;
    }
    if (tag != null && !(call.tag?.toLowerCase().contains(tag!) ?? false)) {
      return false;
    }
    if (duplicate && !call.isDuplicate) {
      return false;
    }
    if (duration != null) {
      final opMatch = RegExp(r'^([><=]?)(.+)$').firstMatch(duration!);
      if (opMatch != null) {
        final op = opMatch.group(1);
        final value = int.tryParse(opMatch.group(2) ?? '');
        if (value != null) {
          if (op == '>' && call.duration <= value) return false;
          if (op == '<' && call.duration >= value) return false;
          if (op == '=' && call.duration != value) return false;
          if ((op == null || op.isEmpty) && call.duration < value) return false;
        }
      }
    }
    if (text != null && text!.isNotEmpty) {
      final terms = text!.split(' ').where((term) => term.isNotEmpty);
      for (final term in terms) {
        if (!call.endpoint.toLowerCase().contains(term)) {
          return false;
        }
      }
    }
    return true;
  }
}
