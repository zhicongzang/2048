//
//  GameViewController.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
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
    
    init(dimension: Int, threshold: Int) {
        self.dimension = dimension > 2 ? dimension : 2
        self.threshold = threshold > 8 ? threshold : 8
        super.init(nibName: nil, bundle: nil)
        model = GameModel(dimension: dimension, threshold: threshold, controller: self)
        view.backgroundColor = UIColor.whiteColor()
        setupSwipeControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    func setupSwipeControls() {
        
    }
    
    func setupGame() {
        let vcHeight = view.bounds.size.height
        let vcWidth = view.bounds.size.width
        
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
        
        let padding = dimension > 5 ? thinPadding : thickPadding
        
        let v1 = boardWidth - padding * (CGFloat(dimension + 1))
        let width = CGFloat(floorf(Float(v1))) / CGFloat(dimension)
        let gameboard = GameboardView(dimension: dimension, tileWidth: width, tilePadding: padding, cornerRadius: 6, backgroundColor: UIColor.blackColor(), foregroundColor: UIColor.darkGrayColor())
        
        let views = [scoreView, gameboard]
        
        scoreView.frame.origin = CGPoint(x: xPositionToCenterView(scoreView), y: yPositionForViewAtPosition(0, views: views))
        gameboard.frame.origin = CGPoint(x: xPositionToCenterView(gameboard), y: yPositionForViewAtPosition(1, views: views))
        
        self.view.addSubview(gameboard)
        self.board = gameboard
        self.view.addSubview(scoreView)
        self.scoreView = scoreView
        
        if let model = self.model {
            model.insertTileAtRandomLocation(2)
            model.insertTileAtRandomLocation(2)
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