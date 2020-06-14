#import "Alice.h"
#if __has_include(<alice/alice-Swift.h>)
#import <alice/alice-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "alice-Swift.h"
#endif

@implementation Alice
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAlice registerWithRegistrar:registrar];
}
@end
