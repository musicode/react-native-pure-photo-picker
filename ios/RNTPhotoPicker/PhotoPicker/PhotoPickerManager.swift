
import Foundation
import Photos

// https://www.jianshu.com/p/6f051fe88717
// http://kayosite.com/ios-development-and-detail-of-photo-framework-part-two.html
// http://blog.imwcl.com/2017/01/11/iOS%E5%BC%80%E5%8F%91%E8%BF%9B%E9%98%B6-Photos%E8%AF%A6%E8%A7%A3%E5%9F%BA%E4%BA%8EPhotos%E7%9A%84%E5%9B%BE%E7%89%87%E9%80%89%E6%8B%A9%E5%99%A8/

@objc public class PhotoPickerManager: NSObject {
    
    @objc public static let shared: PhotoPickerManager = PhotoPickerManager()

    var onAlbumListChange: (() -> Void)?
    
    var albumList: [Album]!
    
    private var isDirty = false
    
    // 所有照片
    private var allPhotos: PHFetchResult<PHAssetCollection>!

    // 收藏
    private var favorites: PHFetchResult<PHAssetCollection>!
    
    // 截图
    private var screenshots: PHFetchResult<PHAssetCollection>?
    
    // 动图
    private var animations: PHFetchResult<PHAssetCollection>?
    
    // 自拍
    private var selfPortraints: PHFetchResult<PHAssetCollection>?

    // 实景
    private var livePhotos: PHFetchResult<PHAssetCollection>?

    // 全景
    private var panoramas: PHFetchResult<PHAssetCollection>!
    
    // 延时
    private var timelapses: PHFetchResult<PHAssetCollection>!

    // 视频
    private var videos: PHFetchResult<PHAssetCollection>!
    
    // 用户创建的相册
    private var userAlbums: PHFetchResult<PHCollection>!
    
    // 缓存器
    private lazy var cacheManager: PHCachingImageManager = {
       
        let manager = PHCachingImageManager()
        
        // 需要快速滚动，最好设置为 false
        manager.allowsCachingHighQualityImages = false
        
        return manager
        
    }()
    
    deinit {
        guard albumList != nil else {
            return
        }
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func scan() -> Bool {
        
        guard albumList == nil else {
            return false
        }
        
        allPhotos = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        favorites = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        
        panoramas = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: nil)
        
        timelapses = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumTimelapses, options: nil)
        
        videos = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: nil)
        
        if #available(iOS 9.0, *) {
            selfPortraints = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: nil)
            screenshots = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil)
        }
        
        if #available(iOS 10.3, *) {
            livePhotos = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumLivePhotos, options: nil)
        }
        
        if #available(iOS 11.0, *) {
            animations = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumAnimated, options: nil)
        }
        
        userAlbums = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        PHPhotoLibrary.shared().register(self)
        
        return true
        
    }
    
    // 获取所有照片
    func fetchAssetList(album: PHAssetCollection, configuration: PhotoPickerConfiguration) -> PHFetchResult<PHAsset> {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: configuration.assetSortField, ascending: configuration.assetSortAscending)]
        
        return PHAsset.fetchAssets(in: album, options: options)
        
    }
    
    // 获取相册列表
    func fetchAlbumList(configuration: PhotoPickerConfiguration) -> [Album] {
        
        var albumList = [PHAssetCollection]()
        
        let appendAlbum = { (album: PHAssetCollection?) in
            if let album = album {
                albumList.append(album)
            }
        }
        
        appendAlbum(allPhotos.firstObject)
        appendAlbum(favorites.firstObject)
        
        appendAlbum(screenshots?.firstObject)
        appendAlbum(animations?.firstObject)
        appendAlbum(selfPortraints?.firstObject)
        appendAlbum(livePhotos?.firstObject)
        
        appendAlbum(panoramas.firstObject)
        appendAlbum(timelapses.firstObject)
        
        appendAlbum(videos.firstObject)

        userAlbums.enumerateObjects { album, _, _ in
            appendAlbum(album as? PHAssetCollection)
        }
        
        var result = [Album]()
        
        albumList.forEach { album in
            
            let fetchResult = fetchAssetList(album: album, configuration: configuration)
            let assetList = fetchResult2List(fetchResult: fetchResult, configuration: configuration)
            
            let album = Album.build(collection: album, assetList: assetList)
            if configuration.filter(album: album) {
                result.append(album)
            }
            
        }
        
        return result
        
    }
    
    func fetchResult2List(fetchResult: PHFetchResult<PHAsset>, configuration: PhotoPickerConfiguration) -> [Asset] {
        
        var list = [Asset]()
        
        fetchResult.enumerateObjects { asset, _, _ in
            let asset = Asset.build(asset: asset)
            if configuration.filter(asset: asset) {
                list.append(asset)
            }
        }
        
        return list
        
    }

    func getPixelSize(size: CGSize) -> CGSize {
        // https://stackoverflow.com/questions/31037859/phimagemanager-requestimageforasset-returns-nil-sometimes-for-icloud-photos
        let scale = UIScreen.main.scale
        let width = size.width * scale
        let height = size.height * scale
        return CGSize(width: width, height: height)
    }
    
    // size 是像素单位
    func requestImage(asset: PHAsset, size: CGSize, options: PHImageRequestOptions, completion: @escaping (UIImage?, [AnyHashable: Any]?) -> Void) -> PHImageRequestID {
        return cacheManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: completion)
    }
    
    func requestImageAsset(asset: PHAsset, size: CGSize, options: PHImageRequestOptions, completion: @escaping (UIImage?, [AnyHashable: Any]?) -> Void) -> PHImageRequestID {
        return cacheManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: completion)
    }
    
    func cancelImageRequest(_ requestID: PHImageRequestID) {
        cacheManager.cancelImageRequest(requestID)
    }
    
}

extension PhotoPickerManager: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            
            isDirty = false
            
            allPhotos = updateChange(changeInstance: changeInstance, fetchResult: allPhotos)
            favorites = updateChange(changeInstance: changeInstance, fetchResult: favorites)
            screenshots = updateChange(changeInstance: changeInstance, fetchResult: screenshots)
            animations = updateChange(changeInstance: changeInstance, fetchResult: animations)
            selfPortraints = updateChange(changeInstance: changeInstance, fetchResult: selfPortraints)
            livePhotos = updateChange(changeInstance: changeInstance, fetchResult: livePhotos)
            panoramas = updateChange(changeInstance: changeInstance, fetchResult: panoramas)
            timelapses = updateChange(changeInstance: changeInstance, fetchResult: timelapses)
            userAlbums = updateChange(changeInstance: changeInstance, fetchResult: userAlbums)
            
            if isDirty {
                onAlbumListChange?()
            }
            
        }
    }
}

extension PhotoPickerManager {
    
    private func updateChange(changeInstance: PHChange, fetchResult: PHFetchResult<PHAssetCollection>?) -> PHFetchResult<PHAssetCollection>? {
        
        if let fetchResult = fetchResult, let changeDetails = changeInstance.changeDetails(for: fetchResult) {
            isDirty = true
            return changeDetails.fetchResultAfterChanges
        }
        
        return fetchResult
        
    }
    
    private func updateChange(changeInstance: PHChange, fetchResult: PHFetchResult<PHCollection>?) -> PHFetchResult<PHCollection>? {
        
        if let fetchResult = fetchResult, let changeDetails = changeInstance.changeDetails(for: fetchResult) {
            isDirty = true
            return changeDetails.fetchResultAfterChanges
        }
        
        return fetchResult
        
    }
    
}
