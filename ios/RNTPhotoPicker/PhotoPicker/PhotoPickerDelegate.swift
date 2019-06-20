
import UIKit

@objc public protocol PhotoPickerDelegate {
    
    // 点击取消按钮
    func photoPickerDidCancel(_ photoPicker: PhotoPickerViewController)
    
    // 点击确定按钮
    func photoPickerDidSubmit(_ photoPicker: PhotoPickerViewController, assetList: [PickedAsset])
    
}
