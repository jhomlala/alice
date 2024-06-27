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
    AliceTranslationKey.callResponseBodyVideoWebBrowser: 'Open video in web browser',
    AliceTranslationKey.callResponseHeadersUnknown: "Unknown",
    AliceTranslationKey.callResponseBodyUnknown: 'Unsupported body. Alice'
    ' can render video/image/text body. Response has Content-Type: '
    "[contentType] which can't be handled. If you're feeling lucky you "
    "can try button below to try render body as text, but it may fail.",
      AliceTranslationKey.callResponseBodyUnknownShow:"Show unsupported body",
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
