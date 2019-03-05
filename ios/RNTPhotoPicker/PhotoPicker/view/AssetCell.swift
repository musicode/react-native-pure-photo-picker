
import UIKit
import Photos

class AssetCell: UICollectionViewCell {
    
    var onToggleChecked: (() -> Void)?
    
    var configuration: PhotoPickerConfiguration!
    
    private var size = CGSize.zero
    
    private var asset: Asset! {
        didSet {

            let nativeAsset = asset.asset
            let cacheThumbnail = asset.thumbnail
            
            assetIdentifier = nativeAsset.localIdentifier
            
            if cacheThumbnail == nil {
                imageRequestID = PhotoPickerManager.shared.requestImage(
                    asset: nativeAsset,
                    size: size,
                    options: configuration.assetThumbnailRequestOptions
                ) { [weak self] image, info in
                    
                    guard let _self = self, _self.assetIdentifier == nativeAsset.localIdentifier else {
                        return
                    }
                    
                    // 此回调会连续触发，这里只缓存高清图
                    if let degraded = info?[PHImageResultIsDegradedKey] as? NSNumber, degraded == 0 {
                        _self.asset.thumbnail = image
                    }
                    
                    _self.imageRequestID = nil
                    _self.thumbnail = image
                    
                }
            }
            else {
                thumbnail = cacheThumbnail
            }
            
        }
    }
    
    private var assetIdentifier: String!
    private var imageRequestID: PHImageRequestID?
    
    private var checked = false {
        didSet {
            
            // 这里有 checked 和 order 两个操作
            // 因此不能加 guard checked != oldValue else { return }
            
            selectButton.checked = checked
            
            selectButton.order = configuration.countable && asset.order >= 0 ? asset.order + 1 : -1
            
        }
    }
    
    private var thumbnail: UIImage? {
        didSet {
            if let thumbnail = thumbnail {
                if asset.selectable {
                    selectButton.isHidden = thumbnail == configuration.assetThumbnailLoadingPlaceholder
                }
                thumbnailView.image = thumbnail
            }
            else {
                thumbnailView.image = configuration.assetThumbnailErrorPlaceholder
            }
        }
    }
    
    private lazy var thumbnailView: UIImageView = {
        
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        view.image = configuration.assetThumbnailLoadingPlaceholder
        
        contentView.insertSubview(view, at: 0)
        
        contentView.addConstraints([
            
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
            
        ])
        
        return view
        
    }()
    
    private lazy var selectButton: SelectButton = {
        
        let view = SelectButton(configuration: configuration)

        view.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(view)
        
        contentView.addConstraints([
            
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.selectButtonWidth),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.selectButtonHeight),
            
        ])
        
        view.addTarget(self, action: #selector(onToggleCheckedClick), for: .touchUpInside)
        
        return view
        
    }()
    
    // 角标，如 live、gif、webp
    private lazy var badgeView: UIImageView = {
       
        let view = UIImageView()
        
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        
        contentView.addConstraints([
            
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -configuration.assetBadgeMarginBottom),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -configuration.assetBadgeMarginRight),
            
        ])
        
        return view
        
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()

        if let requestID = imageRequestID {
            PhotoPickerManager.shared.cancelImageRequest(requestID)
            imageRequestID = nil
        }
        checked = false

        thumbnail = configuration.assetThumbnailLoadingPlaceholder
        badgeView.isHidden = true

    }
    
    @objc private func onToggleCheckedClick() {
        onToggleChecked?()
    }
    
    func bind(asset: Asset, size: CGSize) {
        
        self.size = size
        self.asset = asset

        var badgeImage: UIImage? = nil
        
        if asset.type == .gif {
            badgeImage = configuration.assetBadgeGifIcon
        }
        else if asset.type == .live {
            badgeImage = configuration.assetBadgeLiveIcon
        }
        else if asset.type == .webp {
            badgeImage = configuration.assetBadgeWebpIcon
        }
        
        if let image = badgeImage {
            badgeView.image = image
            badgeView.isHidden = false
        }
        
        checked = asset.order >= 0
        
        selectButton.isHidden = !asset.selectable
        
    }
    
}
