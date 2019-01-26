
#import <React/RCTViewManager.h>
#import <React/RCTBridgeModule.h>

@interface RNTPhotoPickerModule : NSObject <RCTBridgeModule>

@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;

@end
