
import UIKit
import Photos

class AlbumCell: UITableViewCell {

    var configuration: PhotoPickerConfiguration!

    private var index = -1

    private var posterIdentifier: String!
    private var imageRequestID: PHImageRequestID?
    
    private var separatorHeightLayoutConstraint: NSLayoutConstraint!
    
    private lazy var separatorView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = configuration.albumSeparatorColor
        
        // 只能随便找个地方写这句了...
        selectionStyle = .none
        indicatorView.image = configuration.albumIndicatorIcon
        
        contentView.addSubview(view)
        
        separatorHeightLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        
        contentView.addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: configuration.albumPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -configuration.albumPaddingHorizontal),
            separatorHeightLayoutConstraint
        ])
        
        return view
        
    }()
    
    private var poster: UIImage? {
        didSet {
            if let poster = poster {
                posterView.image = poster
            }
            else {
                posterView.image = configuration.albumPosterErrorPlaceholder
            }
        }
    }

    private lazy var posterView: UIImageView = {
        
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        
        view.image = configuration.albumPosterLoadingPlaceholder
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        
        let bottomLayoutConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -configuration.albumPaddingVertical)
        
        bottomLayoutConstraint.priority = .defaultLow
        
        contentView.addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: separatorView, attribute: .bottom, multiplier: 1, constant: configuration.albumPaddingVertical),
            bottomLayoutConstraint,
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: configuration.albumPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.albumPosterWidth),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.albumPosterHeight),
        ])
        
        return view
        
    }()
    
    private lazy var titleView: UILabel = {
        
        let view = UILabel()
        
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.preferredMaxLayoutWidth = 200
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = configuration.albumTitleTextFont
        view.textColor = configuration.albumTitleTextColor
        view.textAlignment = .left
        
        contentView.addSubview(view)
        
        contentView.addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: posterView, attribute: .right, multiplier: 1, constant: configuration.albumTitleMarginLeft),
        ])
        
        return view
        
    }()
    
    private lazy var countView: UILabel = {
        
        let view = UILabel()
        
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.font = configuration.albumCountTextFont
        view.textColor = configuration.albumCountTextColor
        view.textAlignment = .left
        
        contentView.addSubview(view)
        
        contentView.addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: titleView, attribute: .right, multiplier: 1, constant: configuration.albumCountMarginLeft),
        ])
        
        return view
        
    }()
    
    private lazy var indicatorView: UIImageView = {
    
        let view = UIImageView()
    
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        
        contentView.addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -configuration.albumPaddingHorizontal),
        ])
        
        return view
    
    }()
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            backgroundColor = configuration.albumBackgroundColorPressed
        }
        else {
            backgroundColor = .clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if let requestID = imageRequestID {
            PhotoPickerManager.shared.cancelImageRequest(requestID)
            imageRequestID = nil
        }
        poster = configuration.albumPosterLoadingPlaceholder
    }
    
    func bind(index: Int, album: Album, posterSize: CGSize) {
        
        if let poster = album.poster {
            
            let asset = poster.asset
            posterIdentifier = asset.localIdentifier
            
            if poster.thumbnail == nil {
                imageRequestID = PhotoPickerManager.shared.requestImage(
                    asset: asset,
                    size: posterSize,
                    options: configuration.albumPosterRequestOptions
                ) { [weak self] image, info in
                    
                    guard let _self = self, _self.posterIdentifier == asset.localIdentifier else {
                        return
                    }
                    
                    // 此回调会连续触发，这里只缓存高清图
                    if let degraded = info?[PHImageResultIsDegradedKey] as? NSNumber, degraded == 0 {
                        album.poster?.thumbnail = image
                    }
                    
                    _self.imageRequestID = nil
                    _self.poster = image
                    
                }
            }
            else {
                posterView.image = poster.thumbnail
            }
        }
        else {
            posterView.image = configuration.albumEmptyPlaceholder
        }
        
        titleView.text = album.title
        countView.text = "\(album.count)"
        
        if index == 0 {
            if self.index > 0 {
                separatorHeightLayoutConstraint.constant = 0
                setNeedsLayout()
            }
        }
        else {
            if self.index <= 0 {
                separatorHeightLayoutConstraint.constant = configuration.albumSeparatorThickness
                setNeedsLayout()
            }
        }
        self.index = index
        
    }
    
}
