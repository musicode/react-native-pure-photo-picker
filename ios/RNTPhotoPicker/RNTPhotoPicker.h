#import <React/RCTBridgeModule.h>

@interface RNTPhotoPicker : NSObject <RCTBridgeModule>

@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;

@end
