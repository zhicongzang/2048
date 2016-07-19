//
//  AccessoryViews.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class AccessoryViews: UIView {
    private var score: Int = 0 {
        didSet {
            label.text = "SCORE: \(score)"
        }
    }
    
    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 140)
    var label: UILabel
    
    init(backgroundColor: UIColor, textColor: UIColor, font: UIFont, radius: CGFloat) {
        label = UILabel(frame: defaultFrame)
        label.textAlignment = NSTextAlignment.Center
        super.init(frame: defaultFrame)
        self.backgroundColor = backgroundColor
        label.textColor = textColor
        label.font = font
        layer.cornerRadius = radius
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(score: Int) {
        self.score = score
    }
    
}
