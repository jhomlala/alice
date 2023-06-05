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
* Changed default sort filter of create time from ascending to descending. This will show latest HTTP calls on top of the list.

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
* Prepare for 1.0.0 version of sensors and package_info. ([dart_lsc](https://github.com/amirh/dart_lsc))

## 0.0.23
* Updated to dart 2.6.0
* Added AliceHttpExtensions, AliceHttpClientExtensions

## 0.0.22
* Updated dependencies
* Refactored response page. If response is image or video, Alice will show it in response page. Large
body outputs will be not shown by default. There is a "Show body" button to show large output.

## 0.0.21
* Added Chopper support
* Added AndroidX support

## 0.0.20
* Updated dependencies

## 0.0.19
* Updated dependencies

## 0.0.18
* Added share option in call details. Share allows user to share curl of the request. (by: Praveenkumar Ramasamy https://github.com/pravinarr)

## 0.0.17
* Added shake option to open inspector from everywhere (by https://github.com/MattisBrizard MattisBrizard)
* Fixed double-encoding of request body if request body is a minified json (by https://github.com/knaeckeKami knaeckeKami)
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
