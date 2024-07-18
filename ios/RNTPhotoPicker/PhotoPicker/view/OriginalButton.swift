

import UIKit

class OriginalButton: UIControl {

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    private var configuration: PhotoPickerConfiguration!
    
    private lazy var imageView: UIImageView = {
       
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: configuration.originalButtonPaddingVertical),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -configuration.originalButtonPaddingVertical),
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: configuration.originalButtonPaddingHorizontal),
        ])
        
        return view
        
    }()
    
    private lazy var titleView: UILabel = {
        
        let view = UILabel()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: imageView, attribute: .right, multiplier: 1, constant: configuration.originalButtonTitleMarginLeft),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -configuration.originalButtonPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        return view
        
    }()
    
    convenience init(configuration: PhotoPickerConfiguration) {
        
        self.init()
        self.configuration = configuration

        titleView.font = configuration.originalButtonTextFont
        titleView.textColor = configuration.originalButtonTextColor
        
        titleView.text = configuration.originalButtonTitle

    }
    
}

