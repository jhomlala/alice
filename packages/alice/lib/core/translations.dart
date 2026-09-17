import 'package:alice/model/translation.dart';

/// Class used to manage translations in Alice.
class Translations {
  /// Contains list of translation data for all languages.
  static final List<AliceTranslationData> _translations = _initialise();

  /// Initialises translation data for all languages.
  static List<AliceTranslationData> _initialise() {
    List<AliceTranslationData> translations = [];
    translations.add(_buildEnTranslations());
    translations.add(_buildPlTranslations());
    return translations;
  }

  /// Builds [AliceTranslationData] for english language.
  static AliceTranslationData _buildEnTranslations() {
    return AliceTranslationData(
      languageCode: "en",
      values: {
        TranslationKey.alice: "Alice",
        TranslationKey.callDetails: "HTTP Call Details",
        TranslationKey.emailSubject: "Alice report",
        TranslationKey.callDetailsRequest: "Request",
        TranslationKey.callDetailsResponse: "Response",
        TranslationKey.callDetailsOverview: "Overview",
        TranslationKey.callDetailsError: "Error",
        TranslationKey.callDetailsEmpty: "Loading data failed",
        TranslationKey.callErrorScreenErrorEmpty: "Error is empty",
        TranslationKey.callErrorScreenError: "Error:",
        TranslationKey.callErrorScreenStacktrace: "Stack trace:",
        TranslationKey.callErrorScreenEmpty: "Nothing to display here",
        TranslationKey.callOverviewMethod: "Method:",
        TranslationKey.callOverviewServer: "Server:",
        TranslationKey.callOverviewEndpoint: "Endpoint:",
        TranslationKey.callOverviewStarted: "Started:",
        TranslationKey.callOverviewFinished: "Finished:",
        TranslationKey.callOverviewDuration: "Duration:",
        TranslationKey.callOverviewBytesSent: "Bytes sent:",
        TranslationKey.callOverviewBytesReceived: "Bytes received:",
        TranslationKey.callOverviewClient: "Client:",
        TranslationKey.callOverviewSecure: "Secure:",
        TranslationKey.callRequestStarted: "Started:",
        TranslationKey.callRequestBytesSent: "Bytes sent:",
        TranslationKey.callRequestContentType: "Content type:",
        TranslationKey.callRequestBody: "Body:",
        TranslationKey.callRequestBodyEmpty: "Body is empty",
        TranslationKey.callRequestFormDataFields: "Form data fields:",
        TranslationKey.callRequestFormDataFiles: "Form files:",
        TranslationKey.callRequestHeaders: "Headers:",
        TranslationKey.callRequestHeadersEmpty: "Headers are empty",
        TranslationKey.callRequestQueryParameters: "Query parameters",
        TranslationKey.callRequestQueryParametersEmpty:
            "Query parameters are empty",
        TranslationKey.callResponseWaitingForResponse: "Awaiting response...",
        TranslationKey.callResponseError: "Error",
        TranslationKey.callResponseReceived: "Received:",
        TranslationKey.callResponseBytesReceived: "Bytes received:",
        TranslationKey.callResponseStatus: "Status:",
        TranslationKey.callResponseHeaders: "Headers:",
        TranslationKey.callResponseHeadersEmpty: "Headers are empty",
        TranslationKey.callResponseBodyImage: "Body: Image",
        TranslationKey.callResponseBody: "Body:",
        TranslationKey.callResponseTooLargeToShow: "Too large to show",
        TranslationKey.callResponseBodyShow: "Show body",
        TranslationKey.callResponseLargeBodyShowWarning:
            'Warning! It will take some time to render output.',
        TranslationKey.callResponseBodyVideo: 'Body: Video',
        TranslationKey.callResponseBodyVideoWebBrowser:
            'Open video in web browser',
        TranslationKey.callResponseHeadersUnknown: "Unknown",
        TranslationKey.callResponseBodyUnknown:
            'Unsupported body. Alice'
            ' can render video/image/text body. Response has Content-Type: '
            "[contentType] which can't be handled. If you're feeling lucky you "
            "can try button below to try render body as text, but it may fail.",
        TranslationKey.callResponseBodyUnknownShow: "Show unsupported body",
        TranslationKey.callsListInspector: "Inspector",
        TranslationKey.callsListLogger: "Logger",
        TranslationKey.callsListTimeline: "Timeline",
        TranslationKey.callsListDeleteLogsDialogTitle: "Delete logs",
        TranslationKey.callsListDeleteLogsDialogDescription:
            "Do you want to clear logs?",
        TranslationKey.callsListYes: "Yes",
        TranslationKey.callsListNo: "No",
        TranslationKey.callsListDeleteCallsDialogTitle: "Delete calls",
        TranslationKey.callsListDeleteCallsDialogDescription:
            "Do you want to delete HTTP calls?",
        TranslationKey.callsListSearchHint:
            "Search (e.g. status:200 method:GET)",
        TranslationKey.searchHelpTitle: "Advanced Search",
        TranslationKey.searchHelpDescription:
            "You can use advanced syntax to filter calls:\n\n"
            "• status:200 (Filter by HTTP status)\n"
            "• method:GET (Filter by HTTP method)\n"
            "• duration:>1000 (Filter by duration in ms. Supports <, >, =)\n"
            "• host:google.com (Filter by server host)\n"
            "• client:dio (Filter by HTTP client)\n\n"
            "Example: \"status:500 method:POST api/users\"",
        TranslationKey.callsListSort: "Sort",
        TranslationKey.callsListDelete: "Delete",
        TranslationKey.callsListStats: "Stats",
        TranslationKey.callsListSave: "Save",
        TranslationKey.logsEmpty: "There are no logs to show",
        TranslationKey.logsError: "Failed to display error",
        TranslationKey.logsItemError: "Error:",
        TranslationKey.logsItemStackTrace: "Stack trace:",
        TranslationKey.logsCopied: "Copied to clipboard.",
        TranslationKey.sortDialogTitle: "Select filter",
        TranslationKey.sortDialogAscending: 'Ascending',
        TranslationKey.sortDialogDescending: "Descending",
        TranslationKey.sortDialogAccept: "Accept",
        TranslationKey.sortDialogCancel: "Cancel",
        TranslationKey.sortDialogTime: "Create time (default)",
        TranslationKey.sortDialogResponseTime: "Response time",
        TranslationKey.sortDialogResponseCode: "Response code",
        TranslationKey.sortDialogResponseSize: "Response size",
        TranslationKey.sortDialogEndpoint: "Endpoint",
        TranslationKey.statsTitle: "Stats",
        TranslationKey.statsTotalRequests: "Total requests:",
        TranslationKey.statsPendingRequests: "Pending requests:",
        TranslationKey.statsSuccessRequests: "Success requests:",
        TranslationKey.statsRedirectionRequests: "Redirection requests:",
        TranslationKey.statsErrorRequests: "Error requests:",
        TranslationKey.statsBytesSent: "Bytes sent:",
        TranslationKey.statsBytesReceived: "Bytes received:",
        TranslationKey.statsAverageRequestTime: "Average request time:",
        TranslationKey.statsMaxRequestTime: "Max request time:",
        TranslationKey.statsMinRequestTime: "Min request time:",
        TranslationKey.statsGetRequests: "GET requests:",
        TranslationKey.statsPostRequests: "POST requests:",
        TranslationKey.statsDeleteRequests: "DELETE requests:",
        TranslationKey.statsPutRequests: "PUT requests:",
        TranslationKey.statsPatchRequests: "PATCH requests:",
        TranslationKey.statsSecuredRequests: "Secured requests:",
        TranslationKey.statsUnsecuredRequests: "Unsecured requests:",
        TranslationKey.statsTopSlowest: "Top 3 Slowest",
        TranslationKey.statsRecentErrors: "Recent Errors",
        TranslationKey.statsLargestPayloads: "Largest Payloads",
        TranslationKey.statsStatusDistribution: "Status Distribution",
        TranslationKey.statsHttpMethods: "HTTP Methods",
        TranslationKey.statsStatusSuccess: "Success",
        TranslationKey.statsStatusRedirect: "Redirect",
        TranslationKey.statsStatusError: "Error",
        TranslationKey.statsTotalData: "Total Data",
        TranslationKey.notificationLoading: "Loading:",
        TranslationKey.notificationSuccess: "Success:",
        TranslationKey.notificationRedirect: "Redirect:",
        TranslationKey.notificationError: "Error:",
        TranslationKey.notificationTotalRequests:
            "Alice (total [callCount] HTTP calls)",
        TranslationKey.saveDialogPermissionErrorTitle: "Permission error",
        TranslationKey.saveDialogPermissionErrorDescription:
            "Permission not granted. Couldn't save logs.",
        TranslationKey.saveDialogEmptyErrorTitle: "Call history empty",
        TranslationKey.saveDialogEmptyErrorDescription:
            "There are no calls to save.",
        TranslationKey.saveDialogFileSaveErrorTitle: "Save error",
        TranslationKey.saveDialogFileSaveErrorDescription:
            "Failed to save http calls to file.",
        TranslationKey.saveSuccessTitle: "Logs saved",
        TranslationKey.saveSuccessDescription:
            "Successfully saved logs in [path].",
        TranslationKey.saveSuccessView: "View file",
        TranslationKey.saveHeaderTitle: "Alice - HTTP Inspector",
        TranslationKey.saveHeaderAppName: "App name:",
        TranslationKey.saveHeaderPackage: "Package:",
        TranslationKey.saveHeaderVersion: "Version:",
        TranslationKey.saveHeaderBuildNumber: "Build number:",
        TranslationKey.saveHeaderGenerated: "Generated:",
        TranslationKey.saveLogId: "Id:",
        TranslationKey.saveLogGeneralData: "General data",
        TranslationKey.saveLogServer: "Server:",
        TranslationKey.saveLogMethod: "Method:",
        TranslationKey.saveLogEndpoint: "Endpoint:",
        TranslationKey.saveLogClient: "Client:",
        TranslationKey.saveLogDuration: "Duration:",
        TranslationKey.saveLogSecured: "Secured connection:",
        TranslationKey.saveLogCompleted: "Completed:",
        TranslationKey.saveLogRequest: "Request",
        TranslationKey.saveLogRequestTime: "Request time:",
        TranslationKey.saveLogRequestContentType: "Request content type:",
        TranslationKey.saveLogRequestCookies: "Request cookies:",
        TranslationKey.saveLogRequestHeaders: "Request headers:",
        TranslationKey.saveLogRequestQueryParams: "Request query params:",
        TranslationKey.saveLogRequestSize: "Request size:",
        TranslationKey.saveLogRequestBody: "Request body:",
        TranslationKey.saveLogResponse: "Response",
        TranslationKey.saveLogResponseTime: "Response time:",
        TranslationKey.saveLogResponseStatus: "Response status:",
        TranslationKey.saveLogResponseSize: "Response size:",
        TranslationKey.saveLogResponseHeaders: "Response headers:",
        TranslationKey.saveLogResponseBody: "Response body:",
        TranslationKey.saveLogError: "Error",
        TranslationKey.saveLogStackTrace: "Stack trace",
        TranslationKey.saveLogCurl: "Curl",
        TranslationKey.accept: "Accept",
        TranslationKey.parserFailed: "Failed to parse: ",
        TranslationKey.unknown: "Unknown",
        TranslationKey.jsonViewerParsing: "Parsing JSON...",
        TranslationKey.jsonViewerInvalid: "Invalid JSON: ",
        TranslationKey.jsonViewerObject: "Object",
        TranslationKey.jsonViewerArray: "Array",
        TranslationKey.jsonViewerShowMore: "Show more ([remaining] remaining)",
        TranslationKey.exportFormatDialogTitle: "Select export format",
        TranslationKey.exportFormatTxt: "Export as TXT",
        TranslationKey.exportFormatHar: "Export as HAR",
        TranslationKey.exportFormatCancel: "Cancel",
        TranslationKey.saveLoading: "Loading...",
        TranslationKey.replay: "♻️ Replay",
        TranslationKey.replayMultipartNotSupported:
            "Multipart/FormData replays are not yet supported.",
        TranslationKey.replaySuccess: "Success",
        TranslationKey.replaySuccessMessage: "Request replayed successfully",
        TranslationKey.replayError: "Replay failed",
        TranslationKey.replayNotSupportedOnPlatform:
            "Replay is not supported on this platform.",
      },
    );
  }

  /// Builds [AliceTranslationData] for polish language.
  static AliceTranslationData _buildPlTranslations() {
    return AliceTranslationData(
      languageCode: "pl",
      values: {
        TranslationKey.alice: "Alice",
        TranslationKey.callDetails: "Połączenie HTTP - detale",
        TranslationKey.emailSubject: "Raport ALice",
        TranslationKey.callDetailsRequest: "Żądanie",
        TranslationKey.callDetailsResponse: "Odpowiedź",
        TranslationKey.callDetailsOverview: "Przegląd",
        TranslationKey.callDetailsError: "Błąd",
        TranslationKey.callDetailsEmpty: "Błąd ładowania danych",
        TranslationKey.callErrorScreenErrorEmpty: "Brak błędów",
        TranslationKey.callErrorScreenError: "Błąd:",
        TranslationKey.callErrorScreenStacktrace: "Ślad stosu:",
        TranslationKey.callErrorScreenEmpty: "Brak danych do wyświetlenia",
        TranslationKey.callOverviewMethod: "Metoda:",
        TranslationKey.callOverviewServer: "Serwer:",
        TranslationKey.callOverviewEndpoint: "Endpoint:",
        TranslationKey.callOverviewStarted: "Rozpoczęto:",
        TranslationKey.callOverviewFinished: "Zakończono:",
        TranslationKey.callOverviewDuration: "Czas trwania:",
        TranslationKey.callOverviewBytesSent: "Bajty wysłane:",
        TranslationKey.callOverviewBytesReceived: "Bajty odebrane:",
        TranslationKey.callOverviewClient: "Klient:",
        TranslationKey.callOverviewSecure: "Połączenie zabezpieczone:",
        TranslationKey.callRequestStarted: "Ropoczęto:",
        TranslationKey.callRequestBytesSent: "Bajty wysłane:",
        TranslationKey.callRequestContentType: "Typ zawartości:",
        TranslationKey.callRequestBody: "Body:",
        TranslationKey.callRequestBodyEmpty: "Body jest puste",
        TranslationKey.callRequestFormDataFields: "Pola forumlarza:",
        TranslationKey.callRequestFormDataFiles: "Pliki formularza:",
        TranslationKey.callRequestHeaders: "Headery:",
        TranslationKey.callRequestHeadersEmpty: "Headery są puste",
        TranslationKey.callRequestQueryParameters: "Parametry query",
        TranslationKey.callRequestQueryParametersEmpty:
            "Parametry query są puste",
        TranslationKey.callResponseWaitingForResponse:
            "Oczekiwanie na odpowiedź...",
        TranslationKey.callResponseError: "Błąd",
        TranslationKey.callResponseReceived: "Otrzymano:",
        TranslationKey.callResponseBytesReceived: "Bajty odebrane:",
        TranslationKey.callResponseStatus: "Status:",
        TranslationKey.callResponseHeaders: "Headery:",
        TranslationKey.callResponseHeadersEmpty: "Headery są puste",
        TranslationKey.callResponseBodyImage: "Body: Obraz",
        TranslationKey.callResponseBody: "Body:",
        TranslationKey.callResponseTooLargeToShow: "Za duże aby pokazać",
        TranslationKey.callResponseBodyShow: "Pokaż body",
        TranslationKey.callResponseLargeBodyShowWarning:
            'Uwaga! Może zająć trochę czasu, zanim uda się wyrenderować output.',
        TranslationKey.callResponseBodyVideo: 'Body: Video',
        TranslationKey.callResponseBodyVideoWebBrowser:
            'Otwórz video w przeglądarce',
        TranslationKey.callResponseHeadersUnknown: "Nieznane",
        TranslationKey.callResponseBodyUnknown:
            'Nieznane body. Alice'
            ' może renderować video/image/text. Odpowiedź ma typ zawartości:'
            "[contentType], który nie może być obsłużony.Jeżeli chcesz, możesz "
            "spróbować wyrenderować body jako tekst, ale może to się nie udać.",
        TranslationKey.callResponseBodyUnknownShow: "Pokaż nieobsługiwane body",
        TranslationKey.callsListInspector: "Inspektor",
        TranslationKey.callsListLogger: "Logger",
        TranslationKey.callsListTimeline: "Oś czasu",
        TranslationKey.callsListDeleteLogsDialogTitle: "Usuń logi",
        TranslationKey.callsListDeleteLogsDialogDescription:
            "Czy chcesz usunąc logi?",
        TranslationKey.callsListYes: "Tak",
        TranslationKey.callsListNo: "Nie",
        TranslationKey.callsListDeleteCallsDialogTitle: "Usuń połączenia",
        TranslationKey.callsListDeleteCallsDialogDescription:
            "Czy chcesz usunąć zapisane połaczenia HTTP?",
        TranslationKey.callsListSearchHint:
            "Szukaj (np. status:200 method:GET)",
        TranslationKey.searchHelpTitle: "Zaawansowane wyszukiwanie",
        TranslationKey.searchHelpDescription:
            "Możesz użyć zaawansowanej składni do filtrowania połączeń:\n\n"
            "• status:200 (Filtruj po statusie HTTP)\n"
            "• method:GET (Filtruj po metodzie HTTP)\n"
            "• duration:>1000 (Filtruj po czasie w ms. Wspiera <, >, =)\n"
            "• host:google.com (Filtruj po hoście serwera)\n"
            "• client:dio (Filtruj po kliencie HTTP)\n\n"
            "Przykład: \"status:500 method:POST api/users\"",
        TranslationKey.callsListSort: "Sortuj",
        TranslationKey.callsListDelete: "Usuń",
        TranslationKey.callsListStats: "Statystyki",
        TranslationKey.callsListSave: "Zapis",
        TranslationKey.logsEmpty: "Brak rezultatów",
        TranslationKey.logsError: "Problem z wyświetleniem logów.",
        TranslationKey.logsItemError: "Błąd:",
        TranslationKey.logsItemStackTrace: "Ślad stosu:",
        TranslationKey.logsCopied: "Skopiowano do schowka.",
        TranslationKey.sortDialogTitle: "Wybierz filtr",
        TranslationKey.sortDialogAscending: 'Rosnąco',
        TranslationKey.sortDialogDescending: "Malejąco",
        TranslationKey.sortDialogAccept: "Akceptuj",
        TranslationKey.sortDialogCancel: "Anuluj",
        TranslationKey.sortDialogTime: "Czas utworzenia (domyślnie)",
        TranslationKey.sortDialogResponseTime: "Czas odpowiedzi",
        TranslationKey.sortDialogResponseCode: "Status odpowiedzi",
        TranslationKey.sortDialogResponseSize: "Rozmiar odpowiedzi",
        TranslationKey.sortDialogEndpoint: "Endpoint",
        TranslationKey.statsTitle: "Statystyki",
        TranslationKey.statsTotalRequests: "Razem żądań:",
        TranslationKey.statsPendingRequests: "Oczekujące żądania:",
        TranslationKey.statsSuccessRequests: "Poprawne żądania:",
        TranslationKey.statsRedirectionRequests: "Żądania przekierowania:",
        TranslationKey.statsErrorRequests: "Błędne żądania:",
        TranslationKey.statsBytesSent: "Bajty wysłane:",
        TranslationKey.statsBytesReceived: "Bajty otrzymane:",
        TranslationKey.statsAverageRequestTime: "Średni czas żądania:",
        TranslationKey.statsMaxRequestTime: "Maksymalny czas żądania:",
        TranslationKey.statsMinRequestTime: "Minimalny czas żądania:",
        TranslationKey.statsGetRequests: "Żądania GET:",
        TranslationKey.statsPostRequests: "Żądania POST:",
        TranslationKey.statsDeleteRequests: "Żądania DELETE:",
        TranslationKey.statsPutRequests: "Żądania PUT:",
        TranslationKey.statsPatchRequests: "Żądania PATCH:",
        TranslationKey.statsSecuredRequests: "Żądania zabezpieczone:",
        TranslationKey.statsUnsecuredRequests: "Żądania niezabezpieczone:",
        TranslationKey.statsTopSlowest: "Top 3 najwolniejsze",
        TranslationKey.statsRecentErrors: "Ostatnie błędy",
        TranslationKey.statsLargestPayloads: "Największe dane",
        TranslationKey.statsStatusDistribution: "Dystrybucja statusów",
        TranslationKey.statsHttpMethods: "Metody HTTP",
        TranslationKey.statsStatusSuccess: "Poprawne",
        TranslationKey.statsStatusRedirect: "Przekierowania",
        TranslationKey.statsStatusError: "Błędy",
        TranslationKey.statsTotalData: "Razem danych",
        TranslationKey.notificationLoading: "Oczekujące:",
        TranslationKey.notificationSuccess: "Poprawne:",
        TranslationKey.notificationRedirect: "Przekierowanie:",
        TranslationKey.notificationError: "Błąd:",
        TranslationKey.notificationTotalRequests:
            "Alice (razem [callCount] połączeń HTTP)",
        TranslationKey.saveDialogPermissionErrorTitle: "Błąd pozwolenia",
        TranslationKey.saveDialogPermissionErrorDescription:
            "Pozwolenie nieprzyznane. Nie można zapisać logów.",
        TranslationKey.saveDialogEmptyErrorTitle: "Pusta historia połaczeń",
        TranslationKey.saveDialogEmptyErrorDescription:
            "Nie ma połączeń do zapisania.",
        TranslationKey.saveDialogFileSaveErrorTitle: "Błąd zapisu",
        TranslationKey.saveDialogFileSaveErrorDescription:
            "Nie można zapisać danych do pliku.",
        TranslationKey.saveSuccessTitle: "Logi zapisane",
        TranslationKey.saveSuccessDescription: "Zapisano logi w [path].",
        TranslationKey.saveSuccessView: "Otwórz plik",
        TranslationKey.saveHeaderTitle: "Alice - Inspektor HTTP",
        TranslationKey.saveHeaderAppName: "Nazwa aplikacji:",
        TranslationKey.saveHeaderPackage: "Paczka:",
        TranslationKey.saveHeaderVersion: "Wersja:",
        TranslationKey.saveHeaderBuildNumber: "Numer buildu:",
        TranslationKey.saveHeaderGenerated: "Wygenerowano:",
        TranslationKey.saveLogId: "Id:",
        TranslationKey.saveLogGeneralData: "Ogólne informacje",
        TranslationKey.saveLogServer: "Serwer:",
        TranslationKey.saveLogMethod: "Metoda:",
        TranslationKey.saveLogEndpoint: "Endpoint:",
        TranslationKey.saveLogClient: "Klient:",
        TranslationKey.saveLogDuration: "Czas trwania:",
        TranslationKey.saveLogSecured: "Połączenie zabezpieczone:",
        TranslationKey.saveLogCompleted: "Zakończono:",
        TranslationKey.saveLogRequest: "Żądanie",
        TranslationKey.saveLogRequestTime: "Czas żądania:",
        TranslationKey.saveLogRequestContentType: "Typ zawartości żądania:",
        TranslationKey.saveLogRequestCookies: "Ciasteczka żądania:",
        TranslationKey.saveLogRequestHeaders: "Heady żądania",
        TranslationKey.saveLogRequestQueryParams: "Parametry query żądania",
        TranslationKey.saveLogRequestSize: "Rozmiar żądania:",
        TranslationKey.saveLogRequestBody: "Body żądania:",
        TranslationKey.saveLogResponse: "Odpowiedź",
        TranslationKey.saveLogResponseTime: "Czas odpowiedzi:",
        TranslationKey.saveLogResponseStatus: "Status odpowiedzi:",
        TranslationKey.saveLogResponseSize: "Rozmiar odpowiedzi:",
        TranslationKey.saveLogResponseHeaders: "Headery odpowiedzi:",
        TranslationKey.saveLogResponseBody: "Body odpowiedzi:",
        TranslationKey.saveLogError: "Błąd",
        TranslationKey.saveLogStackTrace: "Ślad stosu",
        TranslationKey.saveLogCurl: "Curl",
        TranslationKey.accept: "Akceptuj",
        TranslationKey.parserFailed: "Problem z parsowaniem: ",
        TranslationKey.unknown: "Nieznane",
        TranslationKey.jsonViewerParsing: "Parsowanie JSON...",
        TranslationKey.jsonViewerInvalid: "Nieprawidłowy JSON: ",
        TranslationKey.jsonViewerObject: "Obiekt",
        TranslationKey.jsonViewerArray: "Tablica",
        TranslationKey.jsonViewerShowMore: "Pokaż więcej (zostało [remaining])",
        TranslationKey.exportFormatDialogTitle: "Wybierz format eksportu",
        TranslationKey.exportFormatTxt: "Eksportuj jako TXT",
        TranslationKey.exportFormatHar: "Eksportuj jako HAR",
        TranslationKey.exportFormatCancel: "Anuluj",
        TranslationKey.saveLoading: "Ładowanie...",
        TranslationKey.replay: "♻️ Ponowne",
        TranslationKey.replayMultipartNotSupported:
            "Powtórzenie żądań z Multipart/FormData nie jest jeszcze wspierane.",
        TranslationKey.replaySuccess: "Sukces",
        TranslationKey.replaySuccessMessage:
            "Żądanie zostało pomyślnie powtórzone",
        TranslationKey.replayError: "Powtórzenie nie powiodło się",
        TranslationKey.replayNotSupportedOnPlatform:
            "Ponowne wykonanie żądania nie jest wspierane na tej platformie.",
      },
    );
  }

  /// Returns localized value for specific [languageCode] and [key]. If value
  /// can't be selected then [key] will be returned.
  static String get({
    required String languageCode,
    required TranslationKey key,
  }) {
    try {
      final data = _translations.firstWhere(
        (element) => element.languageCode == languageCode,
        orElse: () => _translations.first,
      );
      final value = data.values[key] ?? key.toString();
      return value;
    } catch (error) {
      return key.toString();
    }
  }
}
