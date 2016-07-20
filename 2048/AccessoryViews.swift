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
    private var record: Int = 0 {
        didSet {
            recordLabel.text = "SCORE: \(record)"
        }
    }
    
    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 140)
    let labelFrame = CGRect(x: 0, y: 0, width: 140, height: 70)
    let recordLabelFrame = CGRect(x: 0, y: 70, width: 140, height: 70)
    var label: UILabel
    var recordLabel: UILabel
    
    init(backgroundColor: UIColor, textColor: UIColor, font: UIFont, radius: CGFloat) {
        label = UILabel(frame: labelFrame)
        label.textAlignment = NSTextAlignment.Center
        recordLabel = UILabel(frame: recordLabelFrame)
        recordLabel.textAlignment = NSTextAlignment.Center
        super.init(frame: defaultFrame)
        self.backgroundColor = backgroundColor
        label.textColor = textColor
        label.font = font
        recordLabel.textColor = textColor
        recordLabel.font = font
        layer.cornerRadius = radius
        self.addSubview(label)
        self.addSubview(recordLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(score: Int) {
        self.score = score
    }
    
    func setRecord(record: Int) {
        self.record = record
    }
    
}
