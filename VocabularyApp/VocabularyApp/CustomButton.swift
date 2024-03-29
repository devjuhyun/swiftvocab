//
//  CustomButton.swift
//  VocabularyApp
//
//  Created by Juhyun Yun on 11/9/23.
//

import UIKit

class FloatingBtn: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        configuration = .filled()
        tintColor = .appColor
        layer.cornerRadius = frame.height / 2
        clipsToBounds = true
        
        let image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)).withTintColor(.white, renderingMode: .alwaysOriginal)
        setImage(image, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                UIView.animate(withDuration: 0.1, delay: 0, options:.curveEaseIn , animations: {
                    self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.alpha = 0.5
                }, completion: nil)
            }
            else {
                UIView.animate(withDuration: 0.1, delay: 0, options:.curveEaseIn , animations: {
                    self.transform = CGAffineTransform.identity
                    self.alpha = 1
                }, completion: nil)
            }
            super.isHighlighted = newValue
        }
    }
}

class CustomButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        setTitleColor(.label, for: .normal)
        let image = UIImage(systemName: "chevron.right")?.withTintColor(.label, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(weight: .bold))
        setImage(image, for: .highlighted)
        setImage(image, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title! + " ", for: state)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        semanticContentAttribute = .forceRightToLeft
    }
}
