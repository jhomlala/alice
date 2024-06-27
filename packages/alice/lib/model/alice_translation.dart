/// Definition of translations for specific locale
class AliceTranslationData {
  final String languageCode;
  final Map<AliceTranslationKey, String> values;

  AliceTranslationData({
    required this.languageCode,
    required this.values,
  });
}

/// Translation keys
enum AliceTranslationKey {
  alice,
  callDetails,
  emailSubject,
  callDetailsOverview,
  callDetailsRequest,
  callDetailsResponse,
  callDetailsError,
  callDetailsEmpty,
  callErrorScreenErrorEmpty,
  callErrorScreenError,
  callErrorScreenStacktrace,
  callErrorScreenEmpty,
  callOverviewMethod,
  callOverviewServer,
  callOverviewEndpoint,
  callOverviewStarted,
  callOverviewFinished,
  callOverviewDuration,
  callOverviewBytesSent,
  callOverviewBytesReceived,
  callOverviewClient,
  callOverviewSecure,
  callRequestStarted,
  callRequestBytesSent,
  callRequestContentType,
  callRequestBody,
  callRequestBodyEmpty,
  callRequestFormDataFields,
  callRequestFormDataFiles,
  callRequestHeaders,
  callRequestHeadersEmpty,
  callRequestQueryParameters,
  callRequestQueryParametersEmpty
}
