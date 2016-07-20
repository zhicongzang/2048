//
//  GameViewController.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class GameController: UIView {
    
    var dimension: Int
    var threshold: Int
    
    var board: GameboardView?
    var model: GameModel?
    
    var scoreView: AccessoryViews?
    
    let boardWidth: CGFloat = 230.0
    let thinPadding: CGFloat = 3.0
    let thickPadding: CGFloat = 6.0

    let viewPadding: CGFloat = 10.0
    
    let verticalViewOffset: CGFloat = 0.0
    
    init(frame: CGRect, dimension: Int, threshold: Int) {
        self.dimension = dimension > 2 ? dimension : 2
        self.threshold = threshold > 8 ? threshold : 8
        super.init(frame: frame)
        model = GameModel(dimension: dimension, threshold: threshold, controller: self)
        backgroundColor = UIColor ( red: 0.9925, green: 0.8713, blue: 0.4939, alpha: 1.0 )
        
        setupSwipeControls()
        setupGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSwipeControls() {
        let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameController.upCommand(_:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameController.downCommand(_:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameController.leftCommand(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(GameController.rightCommand(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        addGestureRecognizer(rightSwipe)
    }
    
    func setupGame() {
        let vcHeight = bounds.size.height
        let vcWidth = bounds.size.width
        
        func xPositionToCenterView(view: UIView) -> CGFloat {
            let viewWidth = view.bounds.size.width
            let tentativeX = (vcWidth - viewWidth) / 2
            return tentativeX >= 0 ? tentativeX : 0
        }
        
        func yPositionForViewAtPosition(order: Int, views: [UIView]) -> CGFloat {
            assert(views.count > 0)
            assert(order >= 0 && order < views.count)
            let totalHeight = CGFloat(views.count - 1) * viewPadding + views.map({ $0.bounds.size.height }).reduce(verticalViewOffset, combine: { $0 + $1 })
            let viewsTop = (vcHeight - totalHeight) / 2 >= 0 ? (vcHeight - totalHeight) / 2 : 0
            var acc: CGFloat = 0.0
            for i in 0 ..< order {
                acc += viewPadding + views[i].bounds.size.height
            }
            return viewsTop + acc
        }
        
        let scoreView = AccessoryViews(backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFontOfSize(16.0), radius: 6)
        scoreView.scoreChanged(0)
        scoreView.setRecord(model!.record)
        
        let padding = dimension > 5 ? thinPadding : thickPadding
        
        let v1 = boardWidth - padding * (CGFloat(dimension + 1))
        let width = CGFloat(floorf(Float(v1))) / CGFloat(dimension)
        let gameboard = GameboardView(dimension: dimension, tileWidth: width, tilePadding: padding, cornerRadius: 6, backgroundColor: UIColor.blackColor(), foregroundColor: UIColor.darkGrayColor())
        
        let views = [scoreView, gameboard]
        
        scoreView.frame.origin = CGPoint(x: xPositionToCenterView(scoreView), y: yPositionForViewAtPosition(0, views: views))
        gameboard.frame.origin = CGPoint(x: xPositionToCenterView(gameboard), y: yPositionForViewAtPosition(1, views: views))
        
        addSubview(gameboard)
        self.board = gameboard
        addSubview(scoreView)
        self.scoreView = scoreView
        
        if let model = self.model {
            model.insertTileAtRandomLocation(2)
            model.insertTileAtRandomLocation(2)
        }
        
    }
    
    func reset() {
        if let model = self.model,let board = self.board {
            if NSUserDefaults.standardUserDefaults().objectForKey("Record") == nil {
                NSUserDefaults.standardUserDefaults().setObject(0, forKey: "Record")
            }
            if let record = NSUserDefaults.standardUserDefaults().objectForKey("Record") as? Int where model.record > record {
                NSUserDefaults.standardUserDefaults().setObject(model.record, forKey: "Record")
            }
            model.reset()
            board.reset()
            model.insertTileAtRandomLocation(2)
            model.insertTileAtRandomLocation(2)
        }
    }
    
    func followUp() {
        if let model = self.model {
            if !model.continueGame {
                let (userWon, _) = model.userHasWon
                if userWon {
                    let alert = UIAlertController(title: "Victory", message: "You won!", preferredStyle: UIAlertControllerStyle.Alert)
                    let action1 = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { (_) in
                        model.continueGame = true
                    })
                    let action2 = UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { (_) in
                        self.reset()
                    })
                    alert.addAction(action1)
                    alert.addAction(action2)
                    self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
                    return
                }
            }
            let randomVal = Int(arc4random_uniform(10))
            model.insertTileAtRandomLocation(randomVal == 5 ? 4 : 2)
            if model.userHasLost {
                let alert = UIAlertController(title: "Defeat", message: "You lost...", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default, handler: { (_) in
                    self.reset()
                })
                alert.addAction(action)
                self.parentViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @objc func upCommand(r: UIGestureRecognizer!) {
        if let model = self.model {
            model.queueMove(MoveDirection.Up, completion: { (changed) in
                if changed {
                    self.followUp()
                }
            })
        }
    }
    
    @objc func downCommand(r: UIGestureRecognizer!) {
        if let model = self.model {
            model.queueMove(MoveDirection.Down, completion: { (changed) in
                if changed {
                    self.followUp()
                }
            })
        }
    }
    
    @objc func leftCommand(r: UIGestureRecognizer!) {
        if let model = self.model {
            model.queueMove(MoveDirection.Left, completion: { (changed) in
                if changed {
                    self.followUp()
                }
            })
        }
    }
    
    @objc func rightCommand(r: UIGestureRecognizer!) {
        if let model = self.model {
            model.queueMove(MoveDirection.Right, completion: { (changed) in
                if changed {
                    self.followUp()
                }
            })
        }
    }
    
    func scoreChanged(score: Int) {
        if let scoreView = self.scoreView {
            scoreView.scoreChanged(score)
        }
    }
    
    func setRecord(record: Int) {
        if let scoreView = self.scoreView {
            scoreView.setRecord(record)
        }
    }
    
    
    
    func insertTile(position: (Int, Int), value: Int) {
        if let board = self.board {
            board.insertTile(position, value: value)
        }
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        if let board = self.board {
            board.moveOneTile(from, to: to, value: value)
        }
    }
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        if let board = self.board {
            board.moveTwoTiles(from, to: to, value: value)
        }
    }
}