## Unreleased

* Fixed Flutter Web Wasm compatibility by isolating `flutter_local_notifications` behind conditional imports.

## 1.8.0

* Enforced strict public API by moving internal logic to lib/src.
* Renamed Utils to AliceUtils.

## 1.7.1

* Updated README with new screenshots and structure.

## 1.7.0

* Added an interactive Gantt chart Timeline tab to visually inspect staggered HTTP calls over time.
* Added unit tests for the Timeline screen.
* Restructured the project to adopt a cleaner architecture:
    * Moved side-effect driven operations (logger, storage, notification, logcat) to `lib/services`.
    * Moved platform abstractions (shake detector, package info) to `lib/services`.
    * Extracted export-related logic (Text, HAR, Export Manager) to a dedicated `lib/export` directory.
    * Moved pure functions and utilities to `lib/utils`.
    * Cleaned up `lib/core` to strictly contain central orchestration and core configuration.
    * Renamed all `Helper` classes (Permission, Replay, Share, Export, FileSave, Notification) to `Service` (or `Utils` where appropriate) for consistency.
    * Migrated unit tests to match the new project structure.
* Added Request Replay feature allowing developers to resend logged HTTP calls directly from the Alice call details view, with replay indication badges and interceptor bypass.
* Revamped the Stats screen into a modern, actionable dashboard:
    * Replaced the text-heavy list with a grid of high-level metrics (Total Calls, Avg Time, Data Transferred, Pending).
    * Introduced visual Ratio Bars for Status Codes and HTTP Methods distribution.
    * Added actionable insight lists for "Top 3 Slowest", "Recent Errors", and "Largest Payloads" with direct navigation to call details.
    * Removed non-actionable metrics (Min Time, Secured vs Unsecured).

## 1.6.0

* Fixed Flutter Web WASM compatibility by isolating `share_plus` behind conditional imports.
* Added clipboard fallback for sharing logs on Web platforms.
* Added advanced search filters in inspector UI (e.g. `status:200`, `method:GET`, `host:google.com`, `client:dio`, `duration:100`).
* Added search help dialog explaining advanced filter syntax.
* Added unit tests for advanced search filters and translations.
* Refactored search filter logic into a separate `AliceSearchFilter` class.
* Added HAR (HTTP Archive 1.2) export support.
* Refactored `AliceExportHelper` to support multiple export formats via `AliceExporter` interface.
* Added `AliceExportFormatDialog` to allow users to choose between TXT and HAR export formats.
* Added `AliceLoadingDialog` to show progress during export and share operations.

## 1.5.0

* Added comprehensive unit tests for `AliceCookie` and platform-specific logger behavior.
* Removed dart:io dependencies to support Flutter Web.
* Added interactive tree-based JSON viewer for request and response bodies.

## 1.4.0

* Fixed destructive mutation of HTTP calls list when searching in inspector UI (by @tiwariritesh1700).
* Added `notificationLargeIcon` support to `AliceConfiguration` (by @husainazkas).
* Added SelectionArea to Alice screens (by @JanArlukiewicz).
* Hardcoded `presentBanner: false` for iOS notifications to prevent intrusive banners on every HTTP request.

## 1.3.0

* Added Retrofit support and example project.
* Added GraphQL support and example project.
* Migrated to `material_ui` package.
* Migrated documentation to Docusaurus for better search and structure.

## 1.2.0

* Updated Excluded media directory from package publication.
* Updated Replaced open_filex with open_file (^4.0.0) (by @kostadin-damyanov-prime).
* Added support for share curl option (by @thanhnt-mdev).
* Added sharePositionOrigin support for iOS (by @thanhnt-mdev).
* Added FAB menu for share and share curl.
* Added support for Linux, macOS, Windows, and Web.

## 1.1.2

* Updated dependencies.

## 1.1.1

* Updated dependencies.

# 1.0.0

* [BREAKING_CHANGE] Set minimal supported Flutter version 3.29 and Dart 3.7.
* Updated dependencies.

# 1.0.0-dev.12

* Fixed build context issues (by Enguerrand ARMINJON https://github.com/EArminjon)
* Fixed AliceCallsListPage String? unwrap.
* Fixed Navigator issues (by Enguerrand ARMINJON https://github.com/EArminjon)
* Fixed updates dependencies.

# 1.0.0-dev.11

* Fixed issue with invalid count of error calls in stats page.
* Added lint for trailing commas.
* General refactor of code base.

# 1.0.0-dev.10

* [BREAKING_CHANGE] Removed `maxCallsCount`. To change call count, use `storage` constructor
  parameter
  with call count.
* [BREAKING_CHANGE] Replaced configuration parameter of Alice with `AliceConfiguration`.
* Fixed issue with invalid count of calls in notification.
* Added payload to notification.
* General refactor of code base.
* Updated documentation.

# 1.0.0-dev.9

* Fixed saving issue with Android 13 onwards.
* Added unit tests.
* Updated CI/CD task for tests.
* General refactor of code base.
* Updated metadata.

# 1.0.0-dev.8

* Added storage abstractions (by Klemen Tusar https://github.com/techouse).
* Added in memory storage implementation (by Klemen Tusar https://github.com/techouse).
* Added translations.

# 1.0.0-dev.7

* Refactored UI code.

# 1.0.0-dev.6

* [BREAKING_CHANGE] Bumped minimal Flutter version to 3.10.0.
* Changed lint from very good analysis to flutter lints (by Klemen
  Tusar https://github.com/techouse).
* General refactor of code base (by Klemen Tusar https://github.com/techouse).
* Added stacktrace to logs (by Klemen Tusar https://github.com/techouse).

# 1.0.0-dev.5

* Updated readme.
* Updated examples configuration (by Klemen Tusar https://github.com/techouse).

# 1.0.0-dev.4

* Updated metadata.

# 1.0.0-dev.3

* Updated links.
* Updated readme.

# 1.0.0-dev.2

* Updated links.
* Updated readme.

# 1.0.0-dev.1

* [BREAKING_CHANGE] Extracted http clients interceptors to separate packages.
* [BREAKING_CHANGE] Removed
  methods: `getChopperInterceptor`, `onHttpResponse`, `onHttpClientResponse`, `getDioInterceptor`
  from `Alice` class.
* Updated example.
* Updated dependencies.

# 0.4.2

* [BREAKING_CHANGE] Changed type of library from plugin to package. This means native (
  android/iOS/macOS/...) implementations have been removed.
* Added notifications permissions request on Alice startup. This is needed for latest OS releases.
* Updated dependencies (by Jamie Astley https://github.com/jamieastley).
* Recreated example project.
* Fixed deprecated material properties.
* Fixed lints.

# 0.4.1

* Updated dependencies.
* Alice requires now min sdk version 22, and compile sdk version 34 for android.

# 0.4.0

* [BREAKING_CHANGE] Updated dart min version to 3.0.0.
* [BREAKING_CHANGE] Removed `darkTheme` parameter. Alice will now automatically detect the color
  scheme.
* [BREAKING_CHANGE] Alice will now return chopper interceptor instance instead of list with that
  interceptor.
* Added `isInspectorOpened` method to check inspector state.
* Added support for macOS.
* Fixed issue with the same http call not properly handled with chopper. Alice will add "
  alice_token" to the headers of the request to identify given http call.
* Fixed lints.
* Updated dependencies.
* Updated example.

# 0.3.3

* Updated dependencies
* Added fix for call time for http package (by itsara-odds https://github.com/itsara-odds)

# 0.3.2

* Removed video player.
* Link to the video will be displayed instead of video player.

# 0.3.1

* Fixed flutter version upper bound

# 0.3.0

* Added logger feature (by Bartosz Gasztych https://github.com/bgasztych)
* Updated Android configuration (by Bartosz Gasztych https://github.com/bgasztych)
* Updated Flutter configuration (by Bartosz Gasztych https://github.com/bgasztych)
* Updated dependencies (by Bartosz Gasztych https://github.com/bgasztych)
* Updated chopper extension
* Changed open_file to open_filex
* General refactor

# 0.2.5

* Added showShareButton in Alice constructor.
* Added support for Android 12 (by Igor Kurek https://github.com/ikurek )
* Updated dependencies.
* Updated color scheme of Alice widgets.
* Fixed issue with saving logs to file on Android.
* Fixed lint

## 0.2.4

* Updated dependencies

## 0.2.3

* Updated dependencies

## 0.2.2

* Updated dependencies
* Changed default sort filter of create time from ascending to descending. This will show latest
  HTTP calls on top of the list.

## 0.2.1

* Added directionality support (by Abdol Hussain Mozaffari https://github.com/mozaffari)
* Updated dependencies (by https://github.com/Nyan274)

## 0.2.0

* Migrate to null safety (by https://github.com/ARIFCSE10)
* Updated Dio interceptor
* Updated dependencies

## 0.1.12

* Fixed query parameter issue not handled properly (by https://github.com/shreyas18jan).
* Removed shake dependency and added sensors dependency. Shake will be detected with sensors.
* Updated other dependencies.
* Added maxCallsCount which handles max number of calls stored in memory.
* Refactored notification text.
* Added sorting in inspector UI.
* Added additional chopper request error handling.

## 0.1.11

* Updated dependencies
* Lint fixes

## 0.1.10

* Lint update
* General refactor
* Dart format

## 0.1.9

* Lint update

## 0.1.8

* Lint update

## 0.1.7

* Updated dependencies

## 0.1.6

* Updated dependencies
* Removed unused android/ios native code
* Migrated example to v2 android

## 0.1.5

* Changed video_player and Chewie to Better Player. Better Player will be used to display videos.

## 0.1.4

* Updated texts in call details to be selectable
* Fixed general bugs
* Fixed video not disposed properly

## 0.1.3

* Updated documentation

## 0.1.2

* Updated dependencies
* Added documentation
* General refactor

## 0.1.1

* Removed sound in ios notification
* Upgraded local notification library

## 0.1.0

* Promoted to 0.1.0
* Added Android/iOS dummy classes for pubdev score fix

## 0.0.33

* Fixed share issue

## 0.0.32

* Code style refactor

## 0.0.31

* Fixed file save path of iOS
* Fixed Stream request body

## 0.0.30

* Added better duration and bytes formatting

## 0.0.29

* Added possibility to add generic http call
* Refactored rendering of invalid body in application/json response

## 0.0.28

* Fixed rendering body responses of unknown content-type

## 0.0.27

* UI polishing
* File & email content polishing

## 0.0.26

* Added search support in calls screen
* Disabled notifications sound (by https://github.com/itsJoKr Josip Krnjic)

## 0.0.25

* Added notificationIcon parameter
* Added better notification handling
* Refactored codebase
* Added setNavigatorKey method
* Added FormData support for Dio requests

## 0.0.24

* Updated dependencies
* Prepare for 1.0.0 version of sensors and
  package_info. ([dart_lsc](https://github.com/amirh/dart_lsc))

## 0.0.23

* Updated to dart 2.6.0
* Added AliceHttpExtensions, AliceHttpClientExtensions

## 0.0.22

* Updated dependencies
* Refactored response page. If response is image or video, Alice will show it in response page.
  Large
  body outputs will be not shown by default. There is a "Show body" button to show large output.

## 0.0.21

* Added Chopper support
* Added AndroidX support

## 0.0.20

* Updated dependencies

## 0.0.19

* Updated dependencies

## 0.0.18

* Added share option in call details. Share allows user to share curl of the request. (by:
  Praveenkumar Ramasamy https://github.com/pravinarr)

## 0.0.17

* Added shake option to open inspector from everywhere (by https://github.com/MattisBrizard
  MattisBrizard)
* Fixed double-encoding of request body if request body is a minified json (
  by https://github.com/knaeckeKami knaeckeKami)
* Added dark theme (idea by: https://github.com/Agondev Agondev)

## 0.0.16

* Fixed server text overflow

## 0.0.15

* Updated dependencies

## 0.0.14

* Fixed Dio API breaking change

## 0.0.13

* Updated dependencies
* Notification won't init when showNotification is off

## 0.0.12

* Updated flutter local notification dependency version
* Refactor

## 0.0.11

* Fixed iOS version issues (fixed by https://github.com/britannio Britannio Jarrett)

## 0.0.10

* Added stats feature
* Added save feature
* Added secured/not secured connection indicator in call list item
* Query parameters feature (Dio only)
* Fix for Uint8List SDK breaking change
* Updated dependencies
* Refactored code

## 0.0.6

* Fixed http/http package requests

## 0.0.5

* Updated dependencies
* Navigator key can be provided now from application (instead of using Alice's navigator key)

## 0.0.4

* Updated Kotlin version

## 0.0.3

* Removed gif from package

## 0.0.2

* Bug fixes

## 0.0.1

* Initial release
