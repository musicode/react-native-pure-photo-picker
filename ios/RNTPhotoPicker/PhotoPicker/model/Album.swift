
import UIKit
import Photos

public class Album {
    
    public static func build(collection: PHAssetCollection, assetList: [Asset]) -> Album {
        
        return Album(
            collection: collection,
            poster: assetList.count > 0 ? assetList[0] : nil,
            count: assetList.count
        )
        
    }
    
    public var title: String? {
        get {
            return collection.localizedTitle
        }
    }

    public var collection: PHAssetCollection
    
    public var poster: Asset?
    
    public var count: Int
    
    public init(collection: PHAssetCollection, poster: Asset?, count: Int) {
        self.collection = collection
        self.poster = poster
        self.count = count
    }
    
}


