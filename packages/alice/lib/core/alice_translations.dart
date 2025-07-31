import 'package:alice/model/alice_translation.dart';

/// Class used to manage translations in Alice.
class AliceTranslations {
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
        AliceTranslationKey.callResponseReceived: "Received:",
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
        AliceTranslationKey.callResponseBodyUnknown:
            'Unsupported body. Alice'
            ' can render video/image/text body. Response has Content-Type: '
            "[contentType] which can't be handled. If you're feeling lucky you "
            "can try button below to try render body as text, but it may fail.",
        AliceTranslationKey.callResponseBodyUnknownShow:
            "Show unsupported body",
        AliceTranslationKey.callsListInspector: "Inspector",
        AliceTranslationKey.callsListLogger: "Logger",
        AliceTranslationKey.callsListDeleteLogsDialogTitle: "Delete logs",
        AliceTranslationKey.callsListDeleteLogsDialogDescription:
            "Do you want to clear logs?",
        AliceTranslationKey.callsListYes: "Yes",
        AliceTranslationKey.callsListNo: "No",
        AliceTranslationKey.callsListDeleteCallsDialogTitle: "Delete calls",
        AliceTranslationKey.callsListDeleteCallsDialogDescription:
            "Do you want to delete HTTP calls?",
        AliceTranslationKey.callsListSearchHint: "Search HTTP call...",
        AliceTranslationKey.callsListSort: "Sort",
        AliceTranslationKey.callsListDelete: "Delete",
        AliceTranslationKey.callsListStats: "Stats",
        AliceTranslationKey.callsListSave: "Save",
        AliceTranslationKey.logsEmpty: "There are no logs to show",
        AliceTranslationKey.logsError: "Failed to display error",
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
        AliceTranslationKey.notificationLoading: "Loading:",
        AliceTranslationKey.notificationSuccess: "Success:",
        AliceTranslationKey.notificationRedirect: "Redirect:",
        AliceTranslationKey.notificationError: "Error:",
        AliceTranslationKey.notificationTotalRequests:
            "Alice (total [callCount] HTTP calls)",
        AliceTranslationKey.saveDialogPermissionErrorTitle: "Permission error",
        AliceTranslationKey.saveDialogPermissionErrorDescription:
            "Permission not granted. Couldn't save logs.",
        AliceTranslationKey.saveDialogEmptyErrorTitle: "Call history empty",
        AliceTranslationKey.saveDialogEmptyErrorDescription:
            "There are no calls to save.",
        AliceTranslationKey.saveDialogFileSaveErrorTitle: "Save error",
        AliceTranslationKey.saveDialogFileSaveErrorDescription:
            "Failed to save http calls to file.",
        AliceTranslationKey.saveSuccessTitle: "Logs saved",
        AliceTranslationKey.saveSuccessDescription:
            "Successfully saved logs in [path].",
        AliceTranslationKey.saveSuccessView: "View file",
        AliceTranslationKey.saveHeaderTitle: "Alice - HTTP Inspector",
        AliceTranslationKey.saveHeaderAppName: "App name:",
        AliceTranslationKey.saveHeaderPackage: "Package:",
        AliceTranslationKey.saveHeaderVersion: "Version:",
        AliceTranslationKey.saveHeaderBuildNumber: "Build number:",
        AliceTranslationKey.saveHeaderGenerated: "Generated:",
        AliceTranslationKey.saveLogId: "Id:",
        AliceTranslationKey.saveLogGeneralData: "General data",
        AliceTranslationKey.saveLogServer: "Server:",
        AliceTranslationKey.saveLogMethod: "Method:",
        AliceTranslationKey.saveLogEndpoint: "Endpoint:",
        AliceTranslationKey.saveLogClient: "Client:",
        AliceTranslationKey.saveLogDuration: "Duration:",
        AliceTranslationKey.saveLogSecured: "Secured connection:",
        AliceTranslationKey.saveLogCompleted: "Completed:",
        AliceTranslationKey.saveLogRequest: "Request",
        AliceTranslationKey.saveLogRequestTime: "Request time:",
        AliceTranslationKey.saveLogRequestContentType: "Request content type:",
        AliceTranslationKey.saveLogRequestCookies: "Request cookies:",
        AliceTranslationKey.saveLogRequestHeaders: "Request headers:",
        AliceTranslationKey.saveLogRequestQueryParams: "Request query params:",
        AliceTranslationKey.saveLogRequestSize: "Request size:",
        AliceTranslationKey.saveLogRequestBody: "Request body:",
        AliceTranslationKey.saveLogResponse: "Response",
        AliceTranslationKey.saveLogResponseTime: "Response time:",
        AliceTranslationKey.saveLogResponseStatus: "Response status:",
        AliceTranslationKey.saveLogResponseSize: "Response size:",
        AliceTranslationKey.saveLogResponseHeaders: "Response headers:",
        AliceTranslationKey.saveLogResponseBody: "Response body:",
        AliceTranslationKey.saveLogError: "Error",
        AliceTranslationKey.saveLogStackTrace: "Stack trace",
        AliceTranslationKey.saveLogCurl: "Curl",
        AliceTranslationKey.accept: "Accept",
        AliceTranslationKey.parserFailed: "Failed to parse: ",
        AliceTranslationKey.unknown: "Unknown",
      },
    );
  }

  /// Builds [AliceTranslationData] for polish language.
  static AliceTranslationData _buildPlTranslations() {
    return AliceTranslationData(
      languageCode: "pl",
      values: {
        AliceTranslationKey.alice: "Alice",
        AliceTranslationKey.callDetails: "Połączenie HTTP - detale",
        AliceTranslationKey.emailSubject: "Raport ALice",
        AliceTranslationKey.callDetailsRequest: "Żądanie",
        AliceTranslationKey.callDetailsResponse: "Odpowiedź",
        AliceTranslationKey.callDetailsOverview: "Przegląd",
        AliceTranslationKey.callDetailsError: "Błąd",
        AliceTranslationKey.callDetailsEmpty: "Błąd ładowania danych",
        AliceTranslationKey.callErrorScreenErrorEmpty: "Brak błędów",
        AliceTranslationKey.callErrorScreenError: "Błąd:",
        AliceTranslationKey.callErrorScreenStacktrace: "Ślad stosu:",
        AliceTranslationKey.callErrorScreenEmpty: "Brak danych do wyświetlenia",
        AliceTranslationKey.callOverviewMethod: "Metoda:",
        AliceTranslationKey.callOverviewServer: "Serwer:",
        AliceTranslationKey.callOverviewEndpoint: "Endpoint:",
        AliceTranslationKey.callOverviewStarted: "Rozpoczęto:",
        AliceTranslationKey.callOverviewFinished: "Zakończono:",
        AliceTranslationKey.callOverviewDuration: "Czas trwania:",
        AliceTranslationKey.callOverviewBytesSent: "Bajty wysłane:",
        AliceTranslationKey.callOverviewBytesReceived: "Bajty odebrane:",
        AliceTranslationKey.callOverviewClient: "Klient:",
        AliceTranslationKey.callOverviewSecure: "Połączenie zabezpieczone:",
        AliceTranslationKey.callRequestStarted: "Ropoczęto:",
        AliceTranslationKey.callRequestBytesSent: "Bajty wysłane:",
        AliceTranslationKey.callRequestContentType: "Typ zawartości:",
        AliceTranslationKey.callRequestBody: "Body:",
        AliceTranslationKey.callRequestBodyEmpty: "Body jest puste",
        AliceTranslationKey.callRequestFormDataFields: "Pola forumlarza:",
        AliceTranslationKey.callRequestFormDataFiles: "Pliki formularza:",
        AliceTranslationKey.callRequestHeaders: "Headery:",
        AliceTranslationKey.callRequestHeadersEmpty: "Headery są puste",
        AliceTranslationKey.callRequestQueryParameters: "Parametry query",
        AliceTranslationKey.callRequestQueryParametersEmpty:
            "Parametry query są puste",
        AliceTranslationKey.callResponseWaitingForResponse:
            "Oczekiwanie na odpowiedź...",
        AliceTranslationKey.callResponseError: "Błąd",
        AliceTranslationKey.callResponseReceived: "Otrzymano:",
        AliceTranslationKey.callResponseBytesReceived: "Bajty odebrane:",
        AliceTranslationKey.callResponseStatus: "Status:",
        AliceTranslationKey.callResponseHeaders: "Headery:",
        AliceTranslationKey.callResponseHeadersEmpty: "Headery są puste",
        AliceTranslationKey.callResponseBodyImage: "Body: Obraz",
        AliceTranslationKey.callResponseBody: "Body:",
        AliceTranslationKey.callResponseTooLargeToShow: "Za duże aby pokazać",
        AliceTranslationKey.callResponseBodyShow: "Pokaż body",
        AliceTranslationKey.callResponseLargeBodyShowWarning:
            'Uwaga! Może zająć trochę czasu, zanim uda się wyrenderować output.',
        AliceTranslationKey.callResponseBodyVideo: 'Body: Video',
        AliceTranslationKey.callResponseBodyVideoWebBrowser:
            'Otwórz video w przeglądarce',
        AliceTranslationKey.callResponseHeadersUnknown: "Nieznane",
        AliceTranslationKey.callResponseBodyUnknown:
            'Nieznane body. Alice'
            ' może renderować video/image/text. Odpowiedź ma typ zawartości:'
            "[contentType], który nie może być obsłużony.Jeżeli chcesz, możesz "
            "spróbować wyrenderować body jako tekst, ale może to się nie udać.",
        AliceTranslationKey.callResponseBodyUnknownShow:
            "Pokaż nieobsługiwane body",
        AliceTranslationKey.callsListInspector: "Inspektor",
        AliceTranslationKey.callsListLogger: "Logger",
        AliceTranslationKey.callsListDeleteLogsDialogTitle: "Usuń logi",
        AliceTranslationKey.callsListDeleteLogsDialogDescription:
            "Czy chcesz usunąc logi?",
        AliceTranslationKey.callsListYes: "Tak",
        AliceTranslationKey.callsListNo: "Nie",
        AliceTranslationKey.callsListDeleteCallsDialogTitle: "Usuń połączenia",
        AliceTranslationKey.callsListDeleteCallsDialogDescription:
            "Czy chcesz usunąć zapisane połaczenia HTTP?",
        AliceTranslationKey.callsListSearchHint: "Szukaj połączenia HTTP...",
        AliceTranslationKey.callsListSort: "Sortuj",
        AliceTranslationKey.callsListDelete: "Usuń",
        AliceTranslationKey.callsListStats: "Statystyki",
        AliceTranslationKey.callsListSave: "Zapis",
        AliceTranslationKey.logsEmpty: "Brak rezultatów",
        AliceTranslationKey.logsError: "Problem z wyświetleniem logów.",
        AliceTranslationKey.logsItemError: "Błąd:",
        AliceTranslationKey.logsItemStackTrace: "Ślad stosu:",
        AliceTranslationKey.logsCopied: "Skopiowano do schowka.",
        AliceTranslationKey.sortDialogTitle: "Wybierz filtr",
        AliceTranslationKey.sortDialogAscending: 'Rosnąco',
        AliceTranslationKey.sortDialogDescending: "Malejąco",
        AliceTranslationKey.sortDialogAccept: "Akceptuj",
        AliceTranslationKey.sortDialogCancel: "Anuluj",
        AliceTranslationKey.sortDialogTime: "Czas utworzenia (domyślnie)",
        AliceTranslationKey.sortDialogResponseTime: "Czas odpowiedzi",
        AliceTranslationKey.sortDialogResponseCode: "Status odpowiedzi",
        AliceTranslationKey.sortDialogResponseSize: "Rozmiar odpowiedzi",
        AliceTranslationKey.sortDialogEndpoint: "Endpoint",
        AliceTranslationKey.statsTitle: "Statystyki",
        AliceTranslationKey.statsTotalRequests: "Razem żądań:",
        AliceTranslationKey.statsPendingRequests: "Oczekujące żądania:",
        AliceTranslationKey.statsSuccessRequests: "Poprawne żądania:",
        AliceTranslationKey.statsRedirectionRequests: "Żądania przekierowania:",
        AliceTranslationKey.statsErrorRequests: "Błędne żądania:",
        AliceTranslationKey.statsBytesSent: "Bajty wysłane:",
        AliceTranslationKey.statsBytesReceived: "Bajty otrzymane:",
        AliceTranslationKey.statsAverageRequestTime: "Średni czas żądania:",
        AliceTranslationKey.statsMaxRequestTime: "Maksymalny czas żądania:",
        AliceTranslationKey.statsMinRequestTime: "Minimalny czas żądania:",
        AliceTranslationKey.statsGetRequests: "Żądania GET:",
        AliceTranslationKey.statsPostRequests: "Żądania POST:",
        AliceTranslationKey.statsDeleteRequests: "Żądania DELETE:",
        AliceTranslationKey.statsPutRequests: "Żądania PUT:",
        AliceTranslationKey.statsPatchRequests: "Żądania PATCH:",
        AliceTranslationKey.statsSecuredRequests: "Żądania zabezpieczone:",
        AliceTranslationKey.statsUnsecuredRequests: "Żądania niezabezpieczone:",
        AliceTranslationKey.notificationLoading: "Oczekujące:",
        AliceTranslationKey.notificationSuccess: "Poprawne:",
        AliceTranslationKey.notificationRedirect: "Przekierowanie:",
        AliceTranslationKey.notificationError: "Błąd:",
        AliceTranslationKey.notificationTotalRequests:
            "Alice (razem [callCount] połączeń HTTP)",
        AliceTranslationKey.saveDialogPermissionErrorTitle: "Błąd pozwolenia",
        AliceTranslationKey.saveDialogPermissionErrorDescription:
            "Pozwolenie nieprzyznane. Nie można zapisać logów.",
        AliceTranslationKey.saveDialogEmptyErrorTitle:
            "Pusta historia połaczeń",
        AliceTranslationKey.saveDialogEmptyErrorDescription:
            "Nie ma połączeń do zapisania.",
        AliceTranslationKey.saveDialogFileSaveErrorTitle: "Błąd zapisu",
        AliceTranslationKey.saveDialogFileSaveErrorDescription:
            "Nie można zapisać danych do pliku.",
        AliceTranslationKey.saveSuccessTitle: "Logi zapisane",
        AliceTranslationKey.saveSuccessDescription: "Zapisano logi w [path].",
        AliceTranslationKey.saveSuccessView: "Otwórz plik",
        AliceTranslationKey.saveHeaderTitle: "Alice - Inspektor HTTP",
        AliceTranslationKey.saveHeaderAppName: "Nazwa aplikacji:",
        AliceTranslationKey.saveHeaderPackage: "Paczka:",
        AliceTranslationKey.saveHeaderVersion: "Wersja:",
        AliceTranslationKey.saveHeaderBuildNumber: "Numer buildu:",
        AliceTranslationKey.saveHeaderGenerated: "Wygenerowano:",
        AliceTranslationKey.saveLogId: "Id:",
        AliceTranslationKey.saveLogGeneralData: "Ogólne informacje",
        AliceTranslationKey.saveLogServer: "Serwer:",
        AliceTranslationKey.saveLogMethod: "Metoda:",
        AliceTranslationKey.saveLogEndpoint: "Endpoint:",
        AliceTranslationKey.saveLogClient: "Klient:",
        AliceTranslationKey.saveLogDuration: "Czas trwania:",
        AliceTranslationKey.saveLogSecured: "Połączenie zabezpieczone:",
        AliceTranslationKey.saveLogCompleted: "Zakończono:",
        AliceTranslationKey.saveLogRequest: "Żądanie",
        AliceTranslationKey.saveLogRequestTime: "Czas żądania:",
        AliceTranslationKey.saveLogRequestContentType:
            "Typ zawartości żądania:",
        AliceTranslationKey.saveLogRequestCookies: "Ciasteczka żądania:",
        AliceTranslationKey.saveLogRequestHeaders: "Heady żądania",
        AliceTranslationKey.saveLogRequestQueryParams:
            "Parametry query żądania",
        AliceTranslationKey.saveLogRequestSize: "Rozmiar żądania:",
        AliceTranslationKey.saveLogRequestBody: "Body żądania:",
        AliceTranslationKey.saveLogResponse: "Odpowiedź",
        AliceTranslationKey.saveLogResponseTime: "Czas odpowiedzi:",
        AliceTranslationKey.saveLogResponseStatus: "Status odpowiedzi:",
        AliceTranslationKey.saveLogResponseSize: "Rozmiar odpowiedzi:",
        AliceTranslationKey.saveLogResponseHeaders: "Headery odpowiedzi:",
        AliceTranslationKey.saveLogResponseBody: "Body odpowiedzi:",
        AliceTranslationKey.saveLogError: "Błąd",
        AliceTranslationKey.saveLogStackTrace: "Ślad stosu",
        AliceTranslationKey.saveLogCurl: "Curl",
        AliceTranslationKey.accept: "Akceptuj",
        AliceTranslationKey.parserFailed: "Problem z parsowaniem: ",
        AliceTranslationKey.unknown: "Nieznane",
      },
    );
  }

  /// Returns localized value for specific [languageCode] and [key]. If value
  /// can't be selected then [key] will be returned.
  static String get({
    required String languageCode,
    required AliceTranslationKey key,
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
