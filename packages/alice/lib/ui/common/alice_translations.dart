import 'package:alice/model/alice_translation.dart';

class AliceTranslations {
  static final List<AliceTranslationData> _translations = _initialise();

  static List<AliceTranslationData> _initialise() {
    List<AliceTranslationData> translations = [];
    translations.add(_buildEnTranslations());
    return translations;
  }

  static AliceTranslationData _buildEnTranslations() {
    return AliceTranslationData(languageCode: "en", values: {
      AliceTranslationKey.alice: "Alice",
      AliceTranslationKey.callDetails: "HTTP Call Details",
      AliceTranslationKey.emailSubject: "Alice report",
      AliceTranslationKey.callDetailsRequest: "Request",
      AliceTranslationKey.callDetailsResponse: "Response",
      AliceTranslationKey.callDetailsOverview: "Overview",
      AliceTranslationKey.callDetailsError: "Error",
      AliceTranslationKey.callDetailsEmpty: "Loading data failed",
      AliceTranslationKey.callErrorScreenErrorEmpty: "Error is empty",
      AliceTranslationKey.callErrorScreenError: "Error:",
      AliceTranslationKey.callErrorScreenStacktrace: "Stack trace:",
      AliceTranslationKey.callErrorScreenEmpty: "Nothing to display here",
      AliceTranslationKey.callOverviewMethod: "Method:",
      AliceTranslationKey.callOverviewServer: "Server:",
      AliceTranslationKey.callOverviewEndpoint: "Endpoint:",
      AliceTranslationKey.callOverviewStarted: "Started:",
      AliceTranslationKey.callOverviewFinished: "Finished:",
      AliceTranslationKey.callOverviewDuration: "Duration:",
      AliceTranslationKey.callOverviewBytesSent: "Bytes sent:",
      AliceTranslationKey.callOverviewBytesReceived: "Bytes received:",
      AliceTranslationKey.callOverviewClient: "Client:",
      AliceTranslationKey.callOverviewSecure: "Secure:",
      AliceTranslationKey.callRequestStarted: "Started:",
      AliceTranslationKey.callRequestBytesSent: "Bytes sent:",
      AliceTranslationKey.callRequestContentType: "Content type:",
      AliceTranslationKey.callRequestBody: "Body:",
      AliceTranslationKey.callRequestBodyEmpty: "Body is empty",
      AliceTranslationKey.callRequestFormDataFields: "Form data fields:",
      AliceTranslationKey.callRequestFormDataFiles: "Form files:",
      AliceTranslationKey.callRequestHeaders: "Headers:",
      AliceTranslationKey.callRequestHeadersEmpty: "Headers are empty",
      AliceTranslationKey.callRequestQueryParameters: "Query parameters",
      AliceTranslationKey.callRequestQueryParametersEmpty:
          "Query parameters are empty",
      AliceTranslationKey.callResponseWaitingForResponse:
          "Awaiting response...",
      AliceTranslationKey.callResponseError: "Error",
      AliceTranslationKey.callResponseReceived: "Received",
      AliceTranslationKey.callResponseBytesReceived: "Bytes received:",
      AliceTranslationKey.callResponseStatus: "Status:",
      AliceTranslationKey.callResponseHeaders: "Headers:",
      AliceTranslationKey.callResponseHeadersEmpty: "Headers are empty",
      AliceTranslationKey.callResponseBodyImage: "Body: Image",
      AliceTranslationKey.callResponseBody: "Body:",
      AliceTranslationKey.callResponseTooLargeToShow: "Too large to show",
      AliceTranslationKey.callResponseBodyShow: "Show body",
      AliceTranslationKey.callResponseLargeBodyShowWarning:
          'Warning! It will take some time to render output.',
      AliceTranslationKey.callResponseBodyVideo: 'Body: Video',
      AliceTranslationKey.callResponseBodyVideoWebBrowser:
          'Open video in web browser',
      AliceTranslationKey.callResponseHeadersUnknown: "Unknown",
      AliceTranslationKey.callResponseBodyUnknown: 'Unsupported body. Alice'
          ' can render video/image/text body. Response has Content-Type: '
          "[contentType] which can't be handled. If you're feeling lucky you "
          "can try button below to try render body as text, but it may fail.",
      AliceTranslationKey.callResponseBodyUnknownShow: "Show unsupported body",
      AliceTranslationKey.callsListInspector: "Inspector",
      AliceTranslationKey.callsListLogger: "Logger",
      AliceTranslationKey.callsListDeleteLogsDialogTitle: "Delete logs",
      AliceTranslationKey.callsListDeleteLogsDialogDescription:
          "Do you want to clear logs?",
      AliceTranslationKey.callsListYes: "Yes",
      AliceTranslationKey.callsListNo: "No",
      AliceTranslationKey.callsListDeleteCallsDialogTitle: "Delete calls",
      AliceTranslationKey.callsListDeleteCallsDialogDescription:
          "Do you want to delete http calls?",
      AliceTranslationKey.callsListSearchHint: "Search http request...",
      AliceTranslationKey.callsListSort: "Sort",
      AliceTranslationKey.callsListDelete: "Delete",
      AliceTranslationKey.callsListStats: "Stats",
      AliceTranslationKey.callsListSave: "Save",
      AliceTranslationKey.logsEmpty: "There are no logs to show",
      AliceTranslationKey.logsItemError: "Error:",
      AliceTranslationKey.logsItemStackTrace: "Stack trace:",
      AliceTranslationKey.logsCopied: "Copied to clipboard.",
      AliceTranslationKey.sortDialogTitle: "Select filter",
      AliceTranslationKey.sortDialogAscending: 'Ascending',
      AliceTranslationKey.sortDialogDescending: "Descending",
      AliceTranslationKey.sortDialogAccept: "Accept",
      AliceTranslationKey.sortDialogCancel: "Cancel",
      AliceTranslationKey.sortDialogTime: "Create time (default)",
      AliceTranslationKey.sortDialogResponseTime: "Response time",
      AliceTranslationKey.sortDialogResponseCode: "Response code",
      AliceTranslationKey.sortDialogResponseSize: "Response size",
      AliceTranslationKey.sortDialogEndpoint: "Endpoint",
      AliceTranslationKey.statsTitle: "Stats",
      AliceTranslationKey.statsTotalRequests: "Total requests:",
      AliceTranslationKey.statsPendingRequests: "Pending requests:",
      AliceTranslationKey.statsSuccessRequests: "Success requests:",
      AliceTranslationKey.statsRedirectionRequests: "Redirection requests:",
      AliceTranslationKey.statsErrorRequests: "Error requests:",
      AliceTranslationKey.statsBytesSent: "Bytes sent:",
      AliceTranslationKey.statsBytesReceived: "Bytes received:",
      AliceTranslationKey.statsAverageRequestTime: "Average request time:",
      AliceTranslationKey.statsMaxRequestTime: "Max request time:",
      AliceTranslationKey.statsMinRequestTime: "Min request time:",
      AliceTranslationKey.statsGetRequests: "GET requests:",
      AliceTranslationKey.statsPostRequests: "POST requests:",
      AliceTranslationKey.statsDeleteRequests: "DELETE requests:",
      AliceTranslationKey.statsPutRequests: "PUT requests:",
      AliceTranslationKey.statsPatchRequests: "PATCH requests:",
      AliceTranslationKey.statsSecuredRequests: "Secured requests:",
      AliceTranslationKey.statsUnsecuredRequests: "Unsecured requests:",
    });
  }

  static String get({
    required String languageCode,
    required AliceTranslationKey key,
  }) {
    try {
      final data = _translations
          .firstWhere((element) => element.languageCode == languageCode);
      final value = data.values[key] ?? key.toString();
      return value;
    } catch (error) {
      return key.toString();
    }
  }
}
