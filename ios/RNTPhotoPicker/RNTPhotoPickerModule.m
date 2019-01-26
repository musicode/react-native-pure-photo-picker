
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

- (void)photoPickerDidPermissionsDenied:(PhotoPickerViewController *)photoPicker {

}
- (void)photoPickerDidPermissionsGranted:(PhotoPickerViewController *)photoPicker {

}
- (void)photoPickerWillFetchWithoutPermissions:(PhotoPickerViewController *)photoPicker {

}

RCT_EXPORT_MODULE(RNTPhotoPicker);

RCT_EXPORT_METHOD(open:(int)maxSelectCount
                  countable:(BOOL)countable
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    self.resolve = resolve;
    self.reject = reject;

    PhotoPickerViewController *controller = [PhotoPickerViewController new];

    PhotoPickerConfiguration *configuration = [PhotoPickerConfiguration new];
    configuration.maxSelectCount = maxSelectCount;
    configuration.countable = countable;

    controller.delegate = self;
    controller.configuration = configuration;

    [controller show];

}

@end
