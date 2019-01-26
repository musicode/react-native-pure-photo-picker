
import UIKit

public class TopBar: UIView {
    
    private var configuration: PhotoPickerConfiguration!
    
    lazy var titleButton: TitleButton = {
        
        let view = TitleButton(configuration: configuration)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: cancelButton, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        return view
        
    }()
    
    lazy var cancelButton: UIButton = {
        
        let view = UIButton()
        
        view.titleLabel?.font = configuration.cancelButtonTitleTextFont
        
        view.setTitle(configuration.cancelButtonTitle, for: .normal)
        view.setTitleColor(configuration.cancelButtonTitleTextColor, for: .normal)

        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: configuration.topBarPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: bottomBorder, attribute: .top, multiplier: 1, constant: -(configuration.topBarHeight - configuration.cancelButtonHeight) / 2),
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.cancelButtonWidth),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.cancelButtonHeight),
        ])
        
        return view
        
    }()
    
    private lazy var bottomBorder: UIView = {
       
        let view = UIView()
        
        view.backgroundColor = configuration.topBarBorderColor
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.topBarBorderWidth),
        ])
        
        return view
        
    }()

    public convenience init(configuration: PhotoPickerConfiguration) {
        
        self.init()
        self.configuration = configuration
        
        backgroundColor = configuration.topBarBackgroundColor
        
    }
    
}
