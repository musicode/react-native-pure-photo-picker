
import UIKit

public class BottomBar: UIView {
    
    public var isOriginalChecked = false {
        didSet {

            if isOriginalChecked {
                originalButton.image = configuration.originalButtonImageChecked
            }
            else {
                originalButton.image = configuration.originalButtonImageUnchecked
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
    
    lazy var originalButton: OriginalButton = {
       
        let view = OriginalButton(configuration: configuration)
        
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
        
        view.titleLabel?.font = configuration.submitButtonTextFont

        if configuration.submitButtonBorderRadius > 0 {
            view.layer.cornerRadius = configuration.submitButtonBorderRadius
            view.clipsToBounds = true
        }
        
        view.setTitleColor(configuration.submitButtonTextColor, for: .normal)
        
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
        
        if configuration.showOriginalButton {
            originalButton.addTarget(self, action: #selector(onOriginalClick), for: .touchUpInside)
        }
        else {
            originalButton.isHidden = true
        }
        
    }
    
    @objc private func onOriginalClick() {
        isOriginalChecked = !isOriginalChecked
    }
    
}
