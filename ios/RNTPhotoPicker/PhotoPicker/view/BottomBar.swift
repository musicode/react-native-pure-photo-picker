
import UIKit

public class BottomBar: UIView {
    
    public var isRawChecked = false {
        didSet {

            if isRawChecked {
                rawButton.image = configuration.rawButtonImageChecked
            }
            else {
                rawButton.image = configuration.rawButtonImageUnchecked
            }
            
        }
    }
    
    public var selectedCount = -1 {
        didSet {
            guard selectedCount != oldValue else {
                return
            }
            var title = configuration.submitButtonTitle
            if selectedCount > 0 {
                submitButton.isEnabled = true
                submitButton.alpha = 1
                if configuration.maxSelectCount > 1 {
                    title = "\(configuration.submitButtonTitle)(\(selectedCount)/\(configuration.maxSelectCount))"
                }
            }
            else {
                submitButton.isEnabled = false
                submitButton.alpha = 0.5
            }
            submitButton.setTitle(title, for: .normal)
        }
    }
    
    private var configuration: PhotoPickerConfiguration!
    
    lazy var rawButton: RawButton = {
       
        let view = RawButton(configuration: configuration)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: submitButton, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        return view
        
    }()
    
    lazy var submitButton: SimpleButton = {
    
        let view = SimpleButton()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = configuration.submitButtonBackgroundColorNormal
        view.backgroundColorPressed = configuration.submitButtonBackgroundColorPressed
        
        view.titleLabel?.font = configuration.submitButtonTitleTextFont

        if configuration.submitButtonBorderRadius > 0 {
            view.layer.cornerRadius = configuration.submitButtonBorderRadius
            view.clipsToBounds = true
        }
        
        view.setTitleColor(configuration.submitButtonTitleTextColor, for: .normal)
        
        addSubview(view)
        
        addConstraints([
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: (configuration.bottomBarHeight - configuration.submitButtonHeight) / 2),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -configuration.bottomBarPaddingHorizontal),
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.submitButtonWidth),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.submitButtonHeight),
        ])
        
        return view
        
    }()
    
    public convenience init(configuration: PhotoPickerConfiguration) {
        
        self.init()
        self.configuration = configuration

        backgroundColor = configuration.bottomBarBackgroundColor
        
        if configuration.rawButtonVisible {
            rawButton.addTarget(self, action: #selector(onRawClick), for: .touchUpInside)
        }
        else {
            rawButton.isHidden = true
        }
        
    }
    
    @objc private func onRawClick() {
        isRawChecked = !isRawChecked
    }
    
}
