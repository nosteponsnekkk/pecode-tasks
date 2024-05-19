//
//  CustomTextfield.swift
//  Pecode-Tasks-Test
//
//  Created by Oleg on 19.05.2024.
//

import UIKit


public final class CustomTextfield: UITextField {
    
    //MARK: - Button
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .placeholderText
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Init
    init(){
        super.init(frame: .zero)
        tintColor = .mainColor
        font = .systemFont(ofSize: 14)
        layer.cornerRadius = 12
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        let view = UIView()
        rightView = view
        rightView?.frame.size = .init(width: 40, height: 30)
        rightViewMode = .whileEditing
        view.addSubview(clearButton)
        clearButton.frame = .init(x: 0, y: 0, width: view.bounds.height, height: view.bounds.height)
        leftView = UIView()
        leftView?.frame.size = .init(width: 20, height: 40)
        leftViewMode = .always

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc private func clearText(){
        if text?.isEmpty == true {
            resignFirstResponder()
        } else {
            text = ""
        }
    }
}
