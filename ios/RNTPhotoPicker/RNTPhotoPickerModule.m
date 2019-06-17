
#import "RNTPhotoPickerModule.h"
#import "RNTPhotoPicker-Swift.h"

@interface RNTPhotoPickerModule()<PhotoPickerDelegate>

@end

@implementation RNTPhotoPickerModule

- (void)photoPickerDidCancel:(PhotoPickerViewController *)photoPicker {
    [photoPicker dismissViewControllerAnimated:true completion:nil];
    self.reject(@"-1", @"cancel", nil);
}

- (void)photoPickerDidSubmit:(PhotoPickerViewController *)photoPicker assetList:(NSArray<PickedAsset *> *)assetList {
    [photoPicker dismissViewControllerAnimated:true completion:nil];

    NSMutableArray *list = @[].mutableCopy;
    for (PickedAsset *item in assetList) {
        [list addObject:@{
                          @"path": item.path,
                          @"size": @(item.size),
                          @"width": @(item.width),
                          @"height": @(item.height),
                          @"isVideo": @(item.isVideo),
                          @"isRaw": @(item.isRaw)
                          }];
    }

    self.resolve(list);
}
- (void)photoPickerDidPermissionsNotGranted:(PhotoPickerViewController *)photoPicker {
    [photoPicker dismissViewControllerAnimated:true completion:nil];
    self.reject(@"1", @"has no permissions", nil);
}
- (void)photoPickerDidPermissionsDenied:(PhotoPickerViewController *)photoPicker {
    [photoPicker dismissViewControllerAnimated:true completion:nil];
    self.reject(@"2", @"you denied the requested permissions.", nil);
}
- (void)photoPickerDidPermissionsGranted:(PhotoPickerViewController *)photoPicker {

}

RCT_EXPORT_MODULE(RNTPhotoPicker);

RCT_EXPORT_METHOD(open:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    self.resolve = resolve;
    self.reject = reject;

    PhotoPickerViewController *controller = [PhotoPickerViewController new];

    PhotoPickerConfiguration *configuration = [PhotoPickerConfiguration new];

    configuration.countable = [RCTConvert BOOL:options[@"countable"]];
    configuration.maxSelectCount = [RCTConvert int:options[@"maxSelectCount"]];
    configuration.rawButtonVisible = [RCTConvert BOOL:options[@"rawButtonVisible"]];
    
    int imageMinWidth = [RCTConvert int:options[@"imageMinWidth"]];
    if (imageMinWidth > 0) {
        configuration.imageMinWidth = imageMinWidth;
    }
    
    int imageMinHeight = [RCTConvert int:options[@"imageMinHeight"]];
    if (imageMinHeight > 0) {
        configuration.imageMinHeight = imageMinHeight;
    }
    
    NSString *cancelButtonTitle = [RCTConvert NSString:options[@"cancelButtonTitle"]];
    if (cancelButtonTitle != nil) {
        configuration.cancelButtonTitle = cancelButtonTitle;
    }
    
    NSString *rawButtonTitle = [RCTConvert NSString:options[@"rawButtonTitle"]];
    if (rawButtonTitle != nil) {
        configuration.rawButtonTitle = rawButtonTitle;
    }
    
    NSString *submitButtonTitle = [RCTConvert NSString:options[@"submitButtonTitle"]];
    if (submitButtonTitle != nil) {
        configuration.submitButtonTitle = submitButtonTitle;
    }
    
    controller.delegate = self;
    controller.configuration = configuration;

    [controller show];

}

@end
