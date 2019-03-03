#import "AlicePlugin.h"
#import <alice/alice-Swift.h>

@implementation AlicePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAlicePlugin registerWithRegistrar:registrar];
}
@end
