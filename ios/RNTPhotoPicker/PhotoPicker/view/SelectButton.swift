
import UIKit

class SelectButton: UIControl {
    
    var checked = false {
        didSet {
            
            guard checked != oldValue else {
                return
            }
            
            if checked {
                if configuration.countable {
                    image = configuration.selectButtonImageCheckedCountable
                }
                else {
                    image = configuration.selectButtonImageChecked
                }
            }
            else {
                image = configuration.selectButtonImageUnchecked
            }
            
        }
    }
    
    var order = 0 {
        didSet {
            
            guard order != oldValue else {
                return
            }
            
            if order > 0 {
                if oldValue <= 0 {
                    titleView.isHidden = false
                }
                titleView.text = "\(order)"
                titleView.sizeToFit()
            }
            else {
                if oldValue > 0 {
                    titleView.isHidden = true
                }
            }
            
        }
    }
    
    private var configuration: PhotoPickerConfiguration!
    
    private var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    private lazy var imageView: UIImageView = {
        
        let view = UIImageView()
        
        view.image = configuration.selectButtonImageUnchecked
        view.translatesAutoresizingMaskIntoConstraints = false
        
        insertSubview(view, at: 0)
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: configuration.selectButtonImageMarginTop),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -configuration.selectButtonImageMarginRight)
        ])
        
        return view
        
    }()
    
    private lazy var titleView: UILabel = {
       
        let view = UILabel()
        
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: imageView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: imageView, attribute: .centerY, multiplier: 1, constant: 0)
        ])
        
        return view
        
    }()
    
    convenience init(configuration: PhotoPickerConfiguration) {
        
        self.init()
        self.configuration = configuration
        
        image = configuration.selectButtonImageUnchecked
        titleView.font = configuration.selectButtonTextFont
        titleView.textColor = configuration.selectButtonTextColor
        
    }
    
}
