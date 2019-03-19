//
//  CATextLayer+Default.swift
//  iCharts
//
//  Created by Volodymyr Hryhoriev on 3/19/19.
//  Copyright © 2019 Volodymyr Hryhoriev. All rights reserved.
//

extension CATextLayer {
    
    convenience init(string: String, textColor: CGColor, fontSize: CGFloat = 12) {
        self.init()
        
        backgroundColor = UIColor.clear.cgColor
        
        let fontSize: CGFloat = 12.0
        let attributedString = NSAttributedString(string: string, attributes: [
            .font: UIFont.systemFont(ofSize: fontSize),
            .foregroundColor: UIColor(cgColor: textColor)
            ])
        
        self.string = attributedString
        alignmentMode = .left
        contentsScale = UIScreen.main.scale
        
        frame = (string as NSString).boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: fontSize), options: .usesLineFragmentOrigin, attributes: nil, context: nil)
    }
}
