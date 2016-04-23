//
//  NumberBuilding.swift
//  HiddenWorlds
//
//  Created by Nicolai Apenes on 2/22/16.
//  Copyright (c) 2016 Apportable. All rights reserved.
//

import Foundation

import UIKit

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}
class WorldGen {
    var level : Int = 50
    /*
    var columns : Int = level+10 //10 is the border size, 5 on each side
    var rows : Int = level+10 //same as columns
    var horizontal = Int(((level%10)/5)+level/10) //alterations horizontal lines
    var vertical = Int(((level%10)/7)+level/10) //vertical lines
    var corner = Int(level/10) //corner
    var square = Int(level/15) //square
    var someInts = [Int](count:rows*columns, repeatedValue:0) */
    var columns : Int = 0
    var rows : Int = 0
    var horizontal = 0
    var vertical = 0
    var corner = 0
    var square = 0
    var someInts : [Int] = []
    //class for a single tile/block
    class Block
    {
        var rowNum: Int = 0
        var columnNum: Int = 0
        var imageType: Int = 0
        init(rowNum: Int, columnNum: Int, imageType: Int)
        {
            self.rowNum = rowNum
            self.columnNum = columnNum
            self.imageType = imageType
        }
    }
    //a class with all Block classes within an array
    class Blocks
    {
        var blockList: [Block] = []
    }
    //an instance of the class
    var blocks = Blocks()
    
    func loadWorld()
    {
        var roomChance = arc4random_uniform(2)
        for i in 0...rows-1
        {
            for j in 0...columns-1
            {
                blocks.blockList.append(Block(rowNum: i, columnNum: j, imageType: 0))
            }
        }
        
        generateBorder(5)
        switch(roomChance) {
        case 0:
            generatePillars(10, ySpacing: 6, minRadius: 1, maxRadius: 3, buildChance: 80)
            break;
            
        case 1:
            generateMound(Int(arc4random_uniform(10))+30, yCenter: Int(arc4random_uniform(10))+30, maxRadius: 15, litterChance: 10)
            break;
            
        default:
            println("Something went wrong :(")
            break;
        }
        
        for items in 0...(level+10)*(level+10)
        {
            someInts.append(0)
        }
        /*
        //creating the border
        for i in 0...rows-1
        {
            for j in 0...columns-1
            {
                if i <= 4 || i >= rows-5 || j <= 4 || j >= columns-5 //if it fits one of the cases, make 1
                {
                    // i is the row the changed number is in. j is the columns number the changed number is in.
                    blocks.blockList[i*columns + j].imageType = 1
                }
            }
        }
        
        //creating alterations
        for var h = 0; h < horizontal; h++
        { //horizontal
            let rowChosen = Int.random(0...level-1) //choose row within playable area
            for var j = 0; j < columns; j++ //make line
            {
                someInts[(rowChosen+5)*columns + j] = 1 //each j is in the next columns (right 1)
                blocks.blockList[(rowChosen+5)*columns + j].imageType = 1
            }
        }

        for var v = 0; v < vertical; v++
        { //vertical
            let columnsChosen = Int.random(0...level-1) //choose columns within playable area
            for var i = 0; i < rows; i++ //make line
            {
                someInts[i*columns+(columnsChosen+5)] = 1 //each i is the next row (down 1)
                blocks.blockList[i*columns + (columnsChosen+5)].imageType = 1
            }
        }
        
        for var c = 0; c < corner; c++
        { //corner
            let leftOrRight = Int.random(0...1) //0 is left, 1 is right
            let topOrBottom = Int.random(0...1) //0 is top, 1 is bottom
            let xPosition = Int.random(0...level-1)
            let yPosition = Int.random(0...level-1)
            for var j = 0; j <= xPosition; j++
            {//r is x position. goes from 0 to xposition or columns to columns-xposition
                someInts[abs(((level+4)*topOrBottom)-yPosition)*columns + abs(((level+4)*leftOrRight)-j)] = 1 //level+3 makes the numbers start at bottom of the playable area and go up (n,n-1,n-2...) *columns makes number chosen be on next row
                blocks.blockList[abs(((level+4)*topOrBottom)-yPosition)*columns + abs(((level+4)*leftOrRight)-j)].imageType = 1
            }
            for var i = 0; i <= yPosition; i++
            {
                someInts[abs(((level+4)*topOrBottom)-i)*columns + abs(((level+4)*leftOrRight)-xPosition)] = 1  //same as r but for y position
                blocks.blockList[abs(((level+4)*topOrBottom)-i)*columns + abs(((level+4)*leftOrRight)-xPosition)].imageType = 1
            }
        }
        
        for var s = 0; s < square; s++
        { //block
            var yPosition = Int.random(0...level-10)
            var xPosition = Int.random(0...level-10)
            var length = Int.random(1...10) //up and down lines
            var width = Int.random(1...10) //left and right lines
            for var i = yPosition; i < (yPosition+length); i++
            {
                for var j = xPosition; j < (xPosition+width); j++
                {
                    someInts[(i+5)*columns + (j+5)] = 1
                    blocks.blockList[(i+5)*columns + (j+5)].imageType = 1
                }
            }
        }
        
        for var w = 0; w < 1; w++
        { //winning block
            var side = Int.random(0...3) //0 is left, 1 is up, 2 is right, 3 is down
            var position = Int.random(0...level-1)
            if side == 0 {
                someInts[(position+4)*columns + 4] = 2
                blocks.blockList[(position+5)*columns + 4].imageType = 2
            }
            if side == 1 {
                someInts[4*columns + position+4] = 2
                blocks.blockList[4*columns + position+4].imageType = 2
            }
            if side == 2 {
                someInts[(position+4)*columns + level+5] = 2
                blocks.blockList[(position+4)*columns + level+5].imageType = 2
            }
            if side == 3 {
                someInts[(level+5)*columns + position+4] = 2
                blocks.blockList[(level+5)*columns + position+4].imageType = 2
            }
        }
        
        for var p = 0; p < 1; p++
        { //player block
            var side = Int.random(0...3) //0 is left, 1 is up, 2 is right, 3 is down
            var position = Int.random(0...level-1)
            if side == 0 {
                someInts[(position+4)*columns + 4] = 2
                blocks.blockList[(position+5)*columns + 4].imageType = 2
            }
            if side == 1 {
                someInts[4*columns + position+4] = 2
                blocks.blockList[4*columns + position+4].imageType = 2
            }
            if side == 2 {
                someInts[(position+4)*columns + level+5] = 2
                blocks.blockList[(position+4)*columns + level+5].imageType = 2
            }
            if side == 3 {
                someInts[(level+5)*columns + position+4] = 2
                blocks.blockList[(level+5)*columns + position+4].imageType = 2
            }
        }*/


        //generating floor
        for i in 0...rows-1
        {
            for j in 0...columns-1
            {
                //print("\(someInts[i*columns+j]) ")
                //using (rows-1-i) prints the world in the orientation of the map on the phone
                print("\(blocks.blockList[(rows-1-i)*columns+j].imageType) ")
            }
            println()
        }
    }
    
    func fillArea(startRow: Int, startColumn: Int, endRow: Int, endColumn: Int, toImage: Int) {
        //go through columns and rows cooresponding to the inputs and fills it with toImage
        for i in startRow...endRow {
            for j in startColumn...endColumn {
                blocks.blockList[(i*columns)+j].imageType = toImage
            }
        }
    }
    
    func fillCircle(centerRow: Int, centerColumn: Int, radius: Double, toImage: Int) {
        //go through entire map and checks to see if distance from tile to center is less than radius
        var tileRadius = 0.00
        var currentTile = blocks.blockList[0]
        var columnDifference = 0
        var rowDifference = 0
        for tile in blocks.blockList {
            columnDifference = tile.columnNum - centerColumn
            rowDifference = tile.rowNum - centerRow
            tileRadius = sqrt(Double(columnDifference * columnDifference) + Double(rowDifference * rowDifference))
            //Output: println("Column: \(tile.columnNum) | Row: \(tile.rowNum) | Radius: \(tileRadius)")
            if tileRadius < radius {
                tile.imageType = toImage
            }
        }
    }
    
    func generateBorder(size: Int) {
        fillArea(0, startColumn: 0, endRow: size-1, endColumn: columns-1, toImage: 1)
        fillArea(size, startColumn: columns-size, endRow: rows-1, endColumn: columns-1, toImage: 1)
        fillArea(rows-size, startColumn: 0, endRow: rows-1, endColumn: columns-size, toImage: 1)
        fillArea(size, startColumn: 0, endRow: rows-size, endColumn: size-1, toImage: 1)
    }
    
    func generatePillars(xSpacing: Int, ySpacing: Int, minRadius: Int, maxRadius: Int, buildChance: UInt32) {
        //buildChance is the percentage of a pillar to spawn
        //xSpacing and ySpacing is the distance between each pillar
        //minRadius and maxRadius are the ranges of pillar size
        var xPillars = Int(columns/xSpacing)
        var yPillars = Int(rows/ySpacing)
        var radiusDifference = maxRadius - minRadius
        var currentRadius = 0
        var spawnChance = arc4random_uniform(100)
        for row in 1...yPillars-1 {
            for column in 1...xPillars-1 {
                spawnChance = arc4random_uniform(100)
                currentRadius = Int(arc4random_uniform(UInt32(radiusDifference))) + minRadius
                if spawnChance < buildChance {
                    if row%2 == 1 {
                        fillArea((row*ySpacing)-currentRadius, startColumn: (column*xSpacing)-currentRadius, endRow: (row*ySpacing)+currentRadius, endColumn: (column*xSpacing)+currentRadius, toImage: 1)
                    }
                    else {
                        fillArea((row*ySpacing)-currentRadius, startColumn: (column*xSpacing)-currentRadius-(xSpacing/2), endRow: (row*ySpacing)+currentRadius, endColumn: (column*xSpacing)+currentRadius-(xSpacing/2), toImage: 1)
                    }
                }
            }
        }
    }
    
    func generateMound(xCenter: Int, yCenter: Int, maxRadius: Double, litterChance: UInt32) {
        var spawnChance = arc4random_uniform(100)
        fillCircle(yCenter, centerColumn: xCenter, radius: maxRadius, toImage: 1)
        for tile in blocks.blockList {
            spawnChance = arc4random_uniform(100)
            if spawnChance < litterChance {
                tile.imageType = 1
            }
        }
    }
}