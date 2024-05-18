//
//  PlaceholderLabel.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 17.05.2024.
//

import UIKit

public final class PlaceholderLabel: UILabel {
    
    init(firstPart: String, icon: UIImage?, secondPart: String){
        super.init(frame: .zero)
        
        let imageAttachment = NSTextAttachment(image: icon ?? .add)
        let fullString = NSMutableAttributedString(string: firstPart)
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: secondPart))

        attributedText = fullString
        textColor = .placeholderText
        font = .systemFont(ofSize: 24)
        textAlignment = .center
        numberOfLines = 0
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
