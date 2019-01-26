

import UIKit

class TitleButton: UIControl {

    var title = "" {
        didSet {
            titleView.text = title
            titleView.sizeToFit()
        }
    }
    
    lazy var titleView: UILabel = {
        
        let view = UILabel()
        
        view.font = configuration.titleButtonTitleTextFont
        view.textColor = configuration.titleButtonTitleTextColor
        
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.preferredMaxLayoutWidth = 150
        
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: configuration.titleButtonPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: arrowView, attribute: .left, multiplier: 1, constant: -configuration.titleButtonTitleMarginRight),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: configuration.titleButtonPaddingVertical),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -configuration.titleButtonPaddingVertical),
        ])
        
        return view
        
    }()
    
    lazy var arrowView: UIImageView = {
       
        let view = UIImageView()
        
        view.image = configuration.titleButtonArrow
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -configuration.titleButtonPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        return view
        
    }()
    
    private var configuration: PhotoPickerConfiguration!
    
    convenience init(configuration: PhotoPickerConfiguration) {
        
        self.init()
        self.configuration = configuration

    }
    
}

