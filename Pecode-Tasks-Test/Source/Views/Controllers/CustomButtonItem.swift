//
//  CustomButtonItem.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public enum CustomButtonItemConfigurations {
    case create
    case clear
    case filter
    case clearRecent
}

public final class CustomButtonItem: UIBarButtonItem {
    
    private let type: CustomButtonItemConfigurations
    
    //MARK: - Subviews
    private lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    //MARK: - Lifecycle
    init(_ target: Any, selector: Selector, type: CustomButtonItemConfigurations) {
        self.type = type
        super.init()
        customView = button
        button.addTarget(target, action: selector, for: .touchUpInside)
        
        var config = UIImage.SymbolConfiguration(hierarchicalColor: type != .clear ? .mainColor : .mainRed)
        config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22)))
        
        switch type {
        case .create:
            button.setImage(.createIcon(withConfiguration: config), for: .normal)
        case .filter:
            button.setImage(.filterIcon(withConfiguration: config), for: .normal)
        case .clear:
            button.setImage(.deleteIcon(withConfiguration: config), for: .normal)
        case .clearRecent:
            button.setImage(.deleteIcon(withConfiguration: config), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Interfaces
    public func disable(animated: Bool = true){
        UIView.transition(with: button, duration: animated ? 0.3 : 0, options: .transitionCrossDissolve) { [weak self] in
            guard let self else { return }
            
            var config = UIImage.SymbolConfiguration(hierarchicalColor: .separatorColor)
            config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22)))
            
            switch type {
            case .create:
                button.setImage(.createIcon(withConfiguration: config), for: .normal)
            case .filter:
                button.setImage(.filterIcon(withConfiguration: config), for: .normal)
            case .clear:
                button.setImage(.deleteIcon(withConfiguration: config), for: .normal)
            case .clearRecent:
                button.setImage(.deleteIcon(withConfiguration: config), for: .normal)
            }
            button.isUserInteractionEnabled = false
        }
    }
    public func enable(animated: Bool = true){
        UIView.transition(with: button, duration: animated ? 0.3 : 0, options: .transitionCrossDissolve) { [weak self] in
            guard let self else { return }
            
            var config = UIImage.SymbolConfiguration(hierarchicalColor: type != .clear ? .mainColor : .mainRed)
            config = config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22)))
            
            switch type {
            case .create:
                button.setImage(.createIcon(withConfiguration: config), for: .normal)
            case .filter:
                button.setImage(.filterIcon(withConfiguration: config), for: .normal)
            case .clear:
                button.setImage(.deleteIcon(withConfiguration: config), for: .normal)
            case .clearRecent:
                button.setImage(.deleteIcon(withConfiguration: config), for: .normal)
            }
            button.isUserInteractionEnabled = true
        }
    }
}
