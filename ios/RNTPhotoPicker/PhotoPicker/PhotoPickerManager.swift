
import Foundation
import Photos

// https://www.jianshu.com/p/6f051fe88717
// http://kayosite.com/ios-development-and-detail-of-photo-framework-part-two.html
// http://blog.imwcl.com/2017/01/11/iOS%E5%BC%80%E5%8F%91%E8%BF%9B%E9%98%B6-Photos%E8%AF%A6%E8%A7%A3%E5%9F%BA%E4%BA%8EPhotos%E7%9A%84%E5%9B%BE%E7%89%87%E9%80%89%E6%8B%A9%E5%99%A8/

class PhotoPickerManager: NSObject {
    
    static let shared: PhotoPickerManager = PhotoPickerManager()
    
    var onPermissionsGranted: (() -> Void)?
    
    var onPermissionsDenied: (() -> Void)?
    
    var onFetchWithoutPermissions: (() -> Void)?
    
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
    
    // 所有操作之前必须先确保拥有权限
    public func requestPermissions(callback: @escaping () -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            callback()
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == PHAuthorizationStatus.authorized {
                    callback()
                    self.onPermissionsGranted?()
                }
                else {
                    self.onPermissionsDenied?()
                }
            }
            break
        default:
            // denied 和 restricted 都表示没有权限访问相册
            onFetchWithoutPermissions?()
            break
        }
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
            
            guard let title = album.localizedTitle else {
                return
            }
            
            let fetchResult = fetchAssetList(album: album, configuration: configuration)
            let assetList = fetchResult2List(fetchResult: fetchResult, configuration: configuration)
            
            if configuration.filterAlbum(title: title, count: assetList.count) {
                result.append(
                    Album.build(collection: album, assetList: assetList)
                )
            }
            
        }
        
        return result
        
    }
    
    func fetchResult2List(fetchResult: PHFetchResult<PHAsset>, configuration: PhotoPickerConfiguration) -> [Asset] {
        
        var list = [Asset]()
        
        fetchResult.enumerateObjects { asset, _, _ in
            let asset = Asset.build(asset: asset)
            if configuration.filterAsset(width: asset.width, height: asset.height, type: asset.type) {
                list.append(asset)
            }
        }
        
        return list
        
    }

    func getPixelSize(size: CGSize) -> CGSize {
        // https://stackoverflow.com/questions/31037859/phimagemanager-requestimageforasset-returns-nil-sometimes-for-icloud-photos
        // 如果是 3，有时会拉取不到高清图片，所以求值之后减掉几个像素
        let scale = UIScreen.main.scale
        let width = size.width * scale - 5
        let height = size.height * scale - 5
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
    
    // size 是像素单位
    func startCachingImages(assets: [PHAsset], size: CGSize, options: PHImageRequestOptions) {
        cacheManager.startCachingImages(for: assets, targetSize: size, contentMode: .aspectFill, options: options)
    }
    
    // size 是像素单位
    func stopCachingImages(assets: [PHAsset], size: CGSize, options: PHImageRequestOptions) {
        cacheManager.stopCachingImages(for: assets, targetSize: size, contentMode: .aspectFill, options: options)
    }
    
    func stopAllCachingImages() {
        cacheManager.stopCachingImagesForAllAssets()
    }
    
    func getAssetURL(asset: PHAsset, callback: @escaping (URL?) -> Void) {
        if asset.mediaType == .image {
            let options = PHContentEditingInputRequestOptions()
            asset.requestContentEditingInput(with: options) { contentEditingInput, _ in
                callback(contentEditingInput?.fullSizeImageURL)
            }
        }
        else if asset.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            cacheManager.requestAVAsset(forVideo: asset, options: options) { asset, _, _ in
                if let urlAsset = asset as? AVURLAsset {
                    callback(urlAsset.url)
                }
                else {
                    callback(nil)
                }
            }
        }
    }
    
}

extension PhotoPickerManager: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
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
