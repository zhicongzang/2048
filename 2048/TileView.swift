//
//  TileView.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class TileView: UIView {
    var value: Int = 0 {
        didSet {
            backgroundColor = AppearanceProvider.tileColor(value)
            numberLabel.textColor = AppearanceProvider.numberColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    let numberLabel: UILabel
    
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat) {
        
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
        numberLabel.textAlignment = .Center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = AppearanceProvider.fontForNumbers
        
        super.init(frame: CGRectMake(position.x, position.y, width, width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        
        self.value = value
        backgroundColor = AppearanceProvider.tileColor(value)
        numberLabel.textColor = AppearanceProvider.numberColor(value)
        numberLabel.text = "\(value)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

