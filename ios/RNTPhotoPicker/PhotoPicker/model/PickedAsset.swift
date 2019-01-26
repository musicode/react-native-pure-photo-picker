
import Foundation
import Photos

@objc public class PickedAsset: NSObject {
    
    @objc public var path: String
    
    @objc public var width: Int
    
    @objc public var height: Int
    
    @objc public var size: Int
    
    @objc public var isVideo: Bool
    
    @objc public var isRaw: Bool
    
    public init(path: String, width: Int, height: Int, size: Int, isVideo: Bool, isRaw: Bool) {
        self.path = path
        self.width = width
        self.height = height
        self.size = size
        self.isVideo = isVideo
        self.isRaw = isRaw
    }
    
}
