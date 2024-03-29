//
//  CustomLabel.swift
//  VocabularyApp
//
//  Created by Juhyun Yun on 10/23/23.
//

import UIKit

class CustomLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.font = UIFont.boldSystemFont(ofSize: 19)
        self.textColor = .appColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
