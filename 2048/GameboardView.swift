//
//  GameboardView.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class GameboardView: UIView {
    
    var dimension: Int
    var tileWidth: CGFloat
    var tilePadding: CGFloat
    var cornerRadius: CGFloat
    var tiles: [NSIndexPath: TileView]
    
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopDelay: NSTimeInterval = 0.05
    let tileExpandTime: NSTimeInterval = 0.18
    let tileContractTime: NSTimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: NSTimeInterval = 0.08
    let tileMergeContractTime: NSTimeInterval = 0.08
    
    let perSquareSlideDuration: NSTimeInterval = 0.08
    
    init(dimension: Int, tileWidth: CGFloat, tilePadding: CGFloat, cornerRadius: CGFloat, backgroundColor: UIColor, foregroundColor: UIColor) {
        assert(dimension > 0)
        self.dimension = dimension
        self.tileWidth = tileWidth
        self.tilePadding = tilePadding
        self.cornerRadius = cornerRadius
        self.tiles = [:]
        let sideLength = tilePadding + CGFloat(dimension) * (tileWidth + tilePadding)
        super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
        layer.cornerRadius = cornerRadius
        setupBackground(backgroundColor: backgroundColor, tileColor: foregroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground(backgroundColor backgroundColor: UIColor, tileColor: UIColor) {
        self.backgroundColor = backgroundColor
        var xCursor = tilePadding
        var yCursor: CGFloat
        let backgroundRadius = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        for _ in 0 ..< dimension {
            yCursor = tilePadding
            for _ in 0 ..< dimension {
                let background = UIView(frame: CGRect(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))
                background.layer.cornerRadius = backgroundRadius
                background.backgroundColor = tileColor
                addSubview(background)
                yCursor += tilePadding + tileWidth
                
            }
            xCursor += tilePadding + tileWidth
        }
    }
    
    func reset() {
        tiles.forEach { (_, tile) in
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepCapacity: true)
    }
    
    func positionIsValid(pos:(Int, Int)) -> Bool {
        return (pos.0 >= 0 && pos.0 < dimension && pos.1 >= 0 && pos.1 < dimension)
    }
    
    func insertTile(pos: (Int, Int), value: Int) {
        assert(positionIsValid(pos))
        let (row, col) = pos
        let x = tilePadding + CGFloat(col) * (tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row) * (tileWidth + tilePadding)
        let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        let tile = TileView(position: CGPoint(x: x, y: y), width: tileWidth, value: value, radius: r)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopStartScale, self.tilePopStartScale))
        
        addSubview(tile)
        bringSubviewToFront(tile)
        
        tiles[NSIndexPath(forRow: row, inSection: col)] = tile
        
        UIView.animateWithDuration(tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions.TransitionNone, animations: {
            tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
        }, completion: { finished in
            UIView.animateWithDuration(self.tileContractTime, animations: { () -> Void in
                tile.layer.setAffineTransform(CGAffineTransformIdentity)
            })
        })
    }
    
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(positionIsValid(from) && positionIsValid(to))
        let (fromRow, fromCol) = from
        let (toRow, toCol) = to
        let fromKey = NSIndexPath(forRow: fromRow, inSection: fromCol)
        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
        guard let tile = tiles[fromKey] else {
            assert(false, "placeholder error")
        }
        let endTile = tiles[toKey]
        
        var finalFrame = tile.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol) * (tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow) * (tileWidth + tilePadding)
        
        tiles.removeValueForKey(fromKey)
        tiles[toKey] = tile
        
        let shouldPop = endTile != nil
        UIView.animateWithDuration(perSquareSlideDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            tile.frame = finalFrame
            }, completion: { (finished: Bool) -> Void in
                tile.value = value
                endTile?.removeFromSuperview()
                if !shouldPop || !finished {
                    return
                }
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                UIView.animateWithDuration(self.tileMergeExpandTime, animations: {
                    tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    }, completion: { finished in  UIView.animateWithDuration(self.tileMergeContractTime) {
                        tile.layer.setAffineTransform(CGAffineTransformIdentity)
                    }
                })
        })
    }
    
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
        let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "placeholder error")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "placeholder error")
        }
        
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol) * (tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow) * (tileWidth + tilePadding)
        
        let oldTile = tiles[toKey]
        oldTile?.removeFromSuperview()
        tiles.removeValueForKey(fromKeyA)
        tiles.removeValueForKey(fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animateWithDuration(perSquareSlideDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { 
            tileA.frame = finalFrame
            tileB.frame = finalFrame
            }) { (finished) in
                tileA.value = value
                tileB.removeFromSuperview()
                if !finished {
                    return
                }
                tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                UIView.animateWithDuration(self.tileMergeExpandTime, animations: { 
                    tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    }, completion: { (finished) in
                        UIView.animateWithDuration(self.tileMergeContractTime, animations: { 
                            tileA.layer.setAffineTransform(CGAffineTransformIdentity)
                        })
                })
        }
        
    }
    

    
    
    
}