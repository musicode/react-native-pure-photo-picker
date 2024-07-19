
import UIKit
import Photos

public class PhotoPickerViewController: UIViewController {
    
    @objc public var delegate: PhotoPickerDelegate!
    @objc public var configuration: PhotoPickerConfiguration!
    
    private var topBarHeightLayoutConstraint: NSLayoutConstraint!
    private var bottomBarHeightLayoutConstraint: NSLayoutConstraint!
    
    private var albumListHeightLayoutConstraint: NSLayoutConstraint!
    private var albumListBottomLayoutConstraint: NSLayoutConstraint!
    
    private var albumListVisible = false
    
    // 默认给 1，避免初始化 albumListView 时读取到的高度为 0，无法判断是显示还是隐藏状态
    private var albumListHeight: CGFloat = 1 {
        didSet {
            
            guard albumListHeight != oldValue, albumListHeightLayoutConstraint != nil else {
                return
            }
            
            albumListHeightLayoutConstraint.constant = albumListHeight
            
            if albumListBottomLayoutConstraint.constant > 0 {
                albumListBottomLayoutConstraint.constant = albumListHeight
            }
            
        }
    }
    
    // 当前选中的相册
    private var currentAlbum: PHAssetCollection? {
        didSet {
            
            guard currentAlbum !== oldValue else {
                return
            }
            
            let title: String
            let fetchResult: PHFetchResult<PHAsset>
            
            if let album = currentAlbum {
                title = album.localizedTitle!
                fetchResult = PhotoPickerManager.shared.fetchAssetList(
                    album: album,
                    configuration: configuration
                )
            }
            else {
                title = ""
                fetchResult = PHFetchResult<PHAsset>()
            }
            
            topBar.titleButton.title = title
            assetGridView.fetchResult = fetchResult

        }
    }

    private lazy var albumListView: AlbumList = {
        
        let albumListView = AlbumList(configuration: configuration)

        albumListView.onAlbumClick = { album in
            self.currentAlbum = album.collection
            self.toggleAlbumList()
        }
        
        albumListView.isHidden = true
        
        albumListView.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(albumListView, belowSubview: topBar)
        
        albumListBottomLayoutConstraint = NSLayoutConstraint(
            item: albumListView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: topBar,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        albumListHeightLayoutConstraint = NSLayoutConstraint(
            item: albumListView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: albumListHeight
        )
        
        view.addConstraints([
    
            NSLayoutConstraint(item: albumListView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: albumListView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            albumListBottomLayoutConstraint,
            albumListHeightLayoutConstraint
            
        ])
        
        return albumListView
        
    }()
    
    private lazy var assetGridView: AssetGrid = {
    
        let assetGridView = AssetGrid(configuration: configuration)
        
        assetGridView.translatesAutoresizingMaskIntoConstraints = false
        
        assetGridView.onSelectedAssetListChange = {
            self.bottomBar.selectedCount = assetGridView.selectedAssetList.count
        }
        
        view.insertSubview(assetGridView, belowSubview: albumListView)
        
        view.addConstraints([
            
            NSLayoutConstraint(item: assetGridView, attribute: .top, relatedBy: .equal, toItem: topBar, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: assetGridView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: assetGridView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: assetGridView, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0),
            
        ])
        
        return assetGridView
        
    }()
    
    private lazy var topBar: TopBar = {
        
        let topBar = TopBar(configuration: configuration)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        
        topBar.cancelButton.addTarget(self, action: #selector(onCancelClick), for: .touchUpInside)
        
        topBar.titleButton.addTarget(self, action: #selector(onTitleClick), for: .touchUpInside)
        
        view.addSubview(topBar)
        
        topBarHeightLayoutConstraint = NSLayoutConstraint(
            item: topBar,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: configuration.topBarHeight
        )
        
        view.addConstraints([
            NSLayoutConstraint(item: topBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: topBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: topBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            topBarHeightLayoutConstraint
        ])
        
        return topBar
        
    }()
    
    private lazy var bottomBar: BottomBar = {
       
        let bottomBar = BottomBar(configuration: configuration)
        
        bottomBar.isOriginalChecked = false
        bottomBar.selectedCount = 0
        
        bottomBar.submitButton.onClick = {
            self.onSubmitClick()
        }
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.insertSubview(bottomBar, belowSubview: albumListView)
        
        bottomBarHeightLayoutConstraint = NSLayoutConstraint(
            item: bottomBar,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: configuration.bottomBarHeight
        )
        
        view.addConstraints([
            NSLayoutConstraint(item: bottomBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            bottomBarHeightLayoutConstraint
        ])
        
        return bottomBar
        
    }()
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()

        // 在外面获取完权限再进来吧
        // 否则没权限一片漆黑，体验极差
        let manager = PhotoPickerManager.shared
        
        manager.onAlbumListChange = {
            self.updateAlbumList()
        }
        
        guard manager.scan() else {
            return
        }
        
        DispatchQueue.main.async {
            self.setup()
        }

    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard topBarHeightLayoutConstraint != nil else {
            return
        }
        
        var height = view.bounds.height
        
        if #available(iOS 11.0, *) {
            
            let top = view.safeAreaInsets.top
            let bottom = view.safeAreaInsets.bottom
            
            height -= bottom
            
            topBarHeightLayoutConstraint.constant = configuration.topBarHeight + top
            bottomBarHeightLayoutConstraint.constant = configuration.bottomBarHeight + bottom
            
        }
        
        height -= topBarHeightLayoutConstraint.constant
        
        albumListHeight = height
        
        view.setNeedsLayout()
        
    }
    
    private func setup() {

        updateAlbumList()
        
        let albumList = albumListView.albumList
        currentAlbum = albumList.count > 0 ? albumList[0].collection : nil
        
    }

    private func updateAlbumList() {
        
        albumListView.albumList = PhotoPickerManager.shared.fetchAlbumList(configuration: configuration)
        
    }
    
    private func toggleAlbumList() {
        
        let visible = !albumListVisible
        
        if visible {
            albumListView.isHidden = false
        }
        
        // 位移动画
        albumListBottomLayoutConstraint.constant = visible ? albumListHeight : 0
        
        // 旋转动画
        // - 0.01 可以让动画更舒服，不信可去掉试试
        let pi = CGFloat.pi - 0.01
        let transform = visible ? topBar.titleButton.arrowView.transform.rotated(by: -pi) : CGAffineTransform.identity

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.topBar.titleButton.arrowView.transform = transform
                self.view.layoutIfNeeded()
            },
            completion: { success in
                if !visible {
                    self.albumListView.isHidden = true
                }
            }
        )
        
        albumListVisible = visible
        
    }
    
    private func onSubmitClick() {

        var selectedList = [Asset]()
        
        // 先排序
        assetGridView.selectedAssetList.forEach { asset in
            selectedList.append(asset)
        }
        
        // 不计数就用照片原来的顺序
        if !configuration.countable {
            selectedList.sort { a, b in
                return a.index < b.index
            }
        }
        
        // 排序完成之后，转成 PickedAsset
        let isOriginalChecked = bottomBar.isOriginalChecked

        var result = [PickedAsset]()
        
        selectedList.forEach { asset in

            saveToSandbox(asset: asset, isOriginal: isOriginalChecked) { item in
                result.append(item)
                if result.count < selectedList.count {
                    return
                }
                
                DispatchQueue.main.async {
                    self.delegate.photoPickerDidSubmit(self, assetList: result)
                }
            }
            
        }
        
    }
    
    private func isAlphaImage(image: UIImage) -> Bool {
        guard let alphaInfo = image.cgImage?.alphaInfo else { return false }
        switch alphaInfo {
        case .none, .noneSkipLast, .noneSkipFirst:
          return false
        default:
          return true
        }
    }
    
    private func scaleImage(image: UIImage, size: CGSize, hasAlpha: Bool) -> Data? {
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let newImage = newImage else {
            return nil
        }
        if (hasAlpha) {
            return newImage.pngData()
        }
        return newImage.jpegData(compressionQuality: 1)
    }
    
    private func saveToSandbox(asset: Asset, isOriginal: Bool, callback: @escaping (PickedAsset) -> Void) {

        let nativeAsset = asset.asset
        let assetIsImage = nativeAsset.mediaType == .image
        
        let imageMaxWidth = configuration.imageMaxWidth
        let imageMaxHeight = configuration.imageMaxHeight
        let imageBase64Enabled = configuration.imageBase64Enabled

        let nativeResources = PHAssetResource.assetResources(for: nativeAsset)
        
        var outputResources = [PHAssetResource]()
        // 从 nativeResources 过滤出图片，因为 live photo 会包含 mov 视频
        nativeResources.forEach { item in
            let itemType = item.type
            if assetIsImage && (itemType != .photo && itemType != .fullSizePhoto) {
                return
            }
            outputResources.append(item)
        }
        
        guard outputResources.count > 0 else {
            return
        }
        guard let outputVersion = outputResources.last else {
            return
        }

        var dirname = NSTemporaryDirectory()
        if !dirname.hasSuffix("/") {
            dirname += "/"
        }
        
        var extname = URL(fileURLWithPath: outputVersion.originalFilename).pathExtension.lowercased()
        if !extname.isEmpty {
            extname = "." + extname
        }
        
        let path = dirname + UUID().uuidString + extname
        let url = URL(fileURLWithPath: path)
        
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
                
        PHAssetResourceManager.default().writeData(for: outputVersion, toFile: url, options: options) { error in
            if error != nil {
                return
            }
            
            var outputPath = path
            var outputBase64 = ""
            var outputSize = 0
            
            let originalWidth = asset.width
            let originalHeight = asset.height
            
            var outputWidth = originalWidth
            var outputHeight = originalHeight
            
            if assetIsImage {

                var needScaleImage = false
                if imageMaxWidth > 0 || imageMaxHeight > 0 {
                    let ratio = Float(originalWidth) / Float(originalHeight)
                    if imageMaxWidth > 0 && outputWidth > imageMaxWidth {
                        outputWidth = imageMaxWidth
                        outputHeight = Int(Float(outputWidth) / ratio)
                        needScaleImage = true
                    }
                    if imageMaxHeight > 0 && outputHeight > imageMaxHeight {
                        outputHeight = imageMaxHeight
                        outputWidth = Int(Float(outputHeight) * ratio)
                        needScaleImage = true
                    }
                }
                
                // 这 3 种情况需要处理图片
                if needScaleImage || extname == ".heif" || extname == ".heic" {
                    
                    guard let outputImage = UIImage(contentsOfFile: path) else {
                        return
                    }
                    
                    let isAlphaImage = self.isAlphaImage(image: outputImage)
                    
                    var outputData: Data?
                    if needScaleImage {
                        guard let newData = self.scaleImage(image: outputImage, size: CGSize(width: outputWidth, height: outputHeight), hasAlpha: isAlphaImage) else {
                            return
                        }
                        outputData = newData
                    }
                    else if isAlphaImage {
                        outputData = outputImage.pngData()
                    }
                    else {
                        outputData = outputImage.jpegData(compressionQuality: 1)
                    }
                    
                    guard let nsData = outputData as NSData? else {
                        return
                    }
                    outputPath = dirname + UUID().uuidString + (isAlphaImage ? ".png" : ".jpg")
                    if nsData.write(toFile: outputPath, atomically: true) {
                        if imageBase64Enabled {
                            outputBase64 = nsData.base64EncodedString()
                        }
                        outputSize = nsData.length
                    }
                    else {
                        return
                    }
                }
                else {
                    
                    guard let nsData = NSData(contentsOf: url) else {
                        return
                    }
                                              
                    if imageBase64Enabled {
                        outputBase64 = nsData.base64EncodedString()
                    }
                    outputSize = nsData.length
                    
                }
                
            }
            else {
                let info = try! FileManager.default.attributesOfItem(atPath: path)
                guard let size = info[FileAttributeKey.size] as? Int else {
                    return
                }
                outputSize = size
            }
                                              
                                              
            callback(
                PickedAsset(path: outputPath, base64: outputBase64, width: outputWidth, height: outputHeight, size: outputSize, isVideo: nativeAsset.mediaType == .video, isOriginal: isOriginal)
            )
            
        }
        
    }
    
    @objc private func onCancelClick() {
        delegate.photoPickerDidCancel(self)
    }

    @objc private func onTitleClick() {
        toggleAlbumList()
    }
    
    @objc public func show() {

        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        }
        
    }
    
}


