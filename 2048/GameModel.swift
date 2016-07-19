//
//  GameModel.swift
//  2048
//
//  Created by Zhicong Zang on 7/19/16.
//  Copyright © 2016 Zhicong Zang. All rights reserved.
//

import UIKit

class GameModel {
    let dimension: Int
    let threshold: Int
    
    var score = 0 {
        didSet {
            
        }
    }
    
    var gameboard: SquareGameboard<TileObject>
    unowned var controller: GameViewController
    
    var queue: [MoveCommand]
    var timer: NSTimer
    
    let maxCommands = 100
    let queueDelay = 0.3
    
    var gameboardEmptySpots: [(Int, Int)] {
        var buffer = [(Int, Int)]()
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if case .Empty = gameboard[i,j] {
                    buffer.append((i, j))
                }
            }
        }
        return buffer
    }
    
    var userHasLost: Bool {
        guard gameboardEmptySpots.isEmpty else {
            return false
        }
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                switch gameboard[i, j] {
                case .Empty:
                    assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
                case let .Tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    var userHasWon: (Bool, (Int, Int)?) {
        for i in 0 ..< dimension {
            for j in 0 ..< dimension {
                if case let .Tile(v) = gameboard[i,j] where v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    init(dimension: Int, threshold: Int, controller: GameViewController) {
        self.dimension = dimension
        self.threshold = threshold
        self.controller = controller
        queue = []
        timer = NSTimer()
        gameboard = SquareGameboard(dimension: dimension, initialValue: .Empty)
    }
    
    func reset() {
        score = 0
        gameboard.setAll(.Empty)
        queue.removeAll()
        timer.invalidate()
    }
    
    func queueMove(direction: MoveDirection, completion: (Bool) -> ()) {
        guard queue.count <= maxCommands else {
            return
        }
        queue.append(MoveCommand(direction: direction, completion: completion))
        if !timer.valid {
            timerFired()
        }
    }
    
    @objc func timerFired() {
        if queue.count == 0 {
            return
        }
        var changed = false
        while queue.count > 0 {
            let command = queue.removeAtIndex(0)
            changed = performMove(command.direction)
            command.completion(changed)
            if changed {
                break
            }
        }
        if changed {
            timer = NSTimer.scheduledTimerWithTimeInterval(queueDelay, target: self, selector: #selector(GameModel.timerFired), userInfo: nil, repeats: false)
        }
    }
    
    func insertTile(position: (Int, Int), value: Int) {
        let (x, y) = position
        if case .Empty = gameboard[x,y] {
            gameboard[x, y] = TileObject.Tile(value)
            controller.insertTile(position, value: value)
        }
    }
    
    func insertTileAtRandomLocation(value: Int) {
        let openSpots = gameboardEmptySpots
        if openSpots.isEmpty {
            return
        }
        let idx = Int(arc4random_uniform(UInt32(openSpots.count - 1)))
        insertTile(openSpots[idx], value: value)
    }
    
    func tileBelowHasSameValue(location: (Int,Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }
        if case let .Tile(v) = gameboard[x, y + 1] {
            return v == value
        }
        return false
    }
    
    func tileToRightHasSameValue(location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard x != dimension - 1 else {
            return false
        }
        if case let .Tile(v) = gameboard[x+1, y] {
            return v == value
        }
        return false
    }
    
    func performMove(direction: MoveDirection) -> Bool {
        let coordinateGenerator: (Int) -> [(Int,Int)] = { (iteration: Int) -> [(Int, Int)] in
            var buffer = Array<(Int, Int)>(count:self.dimension, repeatedValue: (0, 0))
            for i in 0 ..< self.dimension {
                switch direction {
                case .Up:
                    buffer[i] = (i, iteration)
                case .Down:
                    buffer[i] = (self.dimension - i - 1, iteration)
                case .Left:
                    buffer[i] = (iteration, i)
                case .Right:
                    buffer[i] = (iteration, self.dimension - i - 1)
                }
            }
            return buffer
        }
        
        var atLeastOneMove = false
        for i in 0 ..< dimension {
            let coords = coordinateGenerator(i)
            
            let tiles = coords.map({ (x, y) -> TileObject in
                return self.gameboard[x, y]
            })
            let orders = merge(tiles)
            atLeastOneMove = orders.count > 0 ? true : atLeastOneMove
            
            for order in orders {
                switch order {
                case let MoveOrder.SingleMoveOrder(soucre, destination, value, wasMerge):
                    let (sx, sy) = coords[soucre]
                    let (dx, dy) = coords[destination]
                    if wasMerge {
                        score += value
                    }
                    gameboard[sx, sy] = TileObject.Empty
                    gameboard[dx, dy] = TileObject.Tile(value)
                    controller.moveOneTile(coords[soucre], to: coords[destination], value: value)
                case let MoveOrder.DoubleMoveOrder(soucre1, source2, destination, value):
                    let (s1x, s1y) = coords[soucre1]
                    let (s2x, s2y) = coords[source2]
                    let (dx, dy) = coords[destination]
                    score += value
                    gameboard[s1x, s1y] = TileObject.Empty
                    gameboard[s2x, s2y] = TileObject.Empty
                    gameboard[dx, dy] = TileObject.Tile(value)
                    controller.moveTwoTiles((coords[soucre1], coords[source2]), to: coords[destination], value: value)
                }
            }
            
        }
        
        return atLeastOneMove
    }
    
    func condense(group: [TileObject]) -> [ActionToken] {
        var tokenBuffer = [ActionToken]()
        for (idx, tile) in group.enumerate() {
            switch tile {
            case let .Tile(value) where tokenBuffer.count == idx:
                tokenBuffer.append(ActionToken.NoAction(source: idx, value: value))
            case let .Tile(value):
                tokenBuffer.append(ActionToken.Move(source: idx, value: value))
            default:
                break
            }
        }
        return tokenBuffer
    }
    
    class func quiescentTileStillQuiescent(inputPosition:Int, outputLength: Int, originalPosition: Int) -> Bool {
        return(inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    func collapse(group: [ActionToken]) -> [ActionToken] {
        var tokenBuffer = [ActionToken]()
        var skipNext = false
        for (idx, token) in group.enumerate() {
            if skipNext {
                skipNext = false
                continue
            }
            switch token {
            case .SingleCombine:
                assert(false, "Cannot have single combine token in input")
            case .DoubleCombine:
                assert(false, "Cannot have double combine token in input")
            case let .NoAction(source, value) where (idx < group.count - 1 && value == group[idx + 1].getValue() && GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: source)):
                let next = group[idx + 1]
                let nextValue = value + next.getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.SingleCombine(source: next.getSource(), value: nextValue))
            case let t where (idx < group.count - 1 && t.getValue() == group[idx + 1].getValue()):
                let next = group[idx + 1]
                let nextValue = t.getValue() + group[idx + 1].getValue()
                skipNext = true
                tokenBuffer.append(ActionToken.DoubleCombine(source: t.getSource(), second: next.getSource(), value: nextValue))
            case let .NoAction(source, value) where !GameModel.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: source):
                tokenBuffer.append(ActionToken.Move(source: source, value: value))
            case let .NoAction(source, value):
                tokenBuffer.append(ActionToken.NoAction(source: source, value: value))
            case let .Move(source, value):
                tokenBuffer.append(ActionToken.Move(source: source, value: value))
            default:
                break
            }
        }
        return tokenBuffer
    }
    
    func convert(group: [ActionToken]) -> [MoveOrder] {
        var moveBuffer = [MoveOrder]()
        for (idx, t) in group.enumerate() {
            switch t {
            case let .Move(source, value):
                moveBuffer.append(MoveOrder.SingleMoveOrder(soucre: source, destination: idx, value: value, wasMerge: false))
            case let .SingleCombine(source, value):
                moveBuffer.append(MoveOrder.SingleMoveOrder(soucre: source, destination: idx, value: value, wasMerge: true))
            case let .DoubleCombine(source1, source2, value):
                moveBuffer.append(MoveOrder.DoubleMoveOrder(firstSource: source1, secondSource: source2, destination: idx, value: value))
            default:
                break
            }
        }
        return moveBuffer
    }
    
    func merge(group: [TileObject]) -> [MoveOrder]{
        return convert(collapse(condense(group)))
    }
}








































