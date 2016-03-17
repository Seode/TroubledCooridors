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
    var level : Int = 27
    /*
    var column : Int = level+10 //10 is the border size, 5 on each side
    var rows : Int = level+10 //same as column
    var horizontal = Int(((level%10)/5)+level/10) //alterations horizontal lines
    var vertical = Int(((level%10)/7)+level/10) //vertical lines
    var corner = Int(level/10) //corner
    var square = Int(level/15) //square
    var someInts = [Int](count:rows*column, repeatedValue:0) */
    var column : Int = 0
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
        init(rowNum: Int, columnNum: Int,imageType: Int)
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
        for i in 0...rows-1
        {
            for j in 0...column-1
            {
                blocks.blockList.append(Block(rowNum: i, columnNum: j, imageType: 0))
            }
        }
        
        for items in 0...(level+10)*(level+10)
        {
            someInts.append(0)
        }
            
        //creating the border
        for i in 0...rows-1
        {
            for j in 0...column-1
            {
                if i <= 4 || i >= rows-5 || j <= 4 || j >= column-5 //if it fits one of the cases, make 1
                {
                    someInts[i*column + j] = 1 // i is the row the changed number is in. j is the column number the changed number is in.
                    blocks.blockList[i*column + j].imageType = 1
                }
            }
        }
        
        //creating alterations
        for var h = 0; h < horizontal; h++
        { //horizontal
            let rowChosen = Int.random(0...level-1) //choose row within playable area
            for var j = 0; j < column; j++ //make line
            {
                someInts[(rowChosen+5)*column + j] = 1 //each j is in the next column (right 1)
                blocks.blockList[(rowChosen+5)*column + j].imageType = 1
            }
        }

        for var v = 0; v < vertical; v++
        { //vertical
            let columnChosen = Int.random(0...level-1) //choose column within playable area
            for var i = 0; i < rows; i++ //make line
            {
                someInts[i*column+(columnChosen+5)] = 1 //each i is the next row (down 1)
                blocks.blockList[i*column + (columnChosen+5)].imageType = 1
            }
        }
        
        for var c = 0; c < corner; c++
        { //corner
            let leftOrRight = Int.random(0...1) //0 is left, 1 is right
            let topOrBottom = Int.random(0...1) //0 is top, 1 is bottom
            let xPosition = Int.random(0...level-1)
            let yPosition = Int.random(0...level-1)
            for var j = 0; j <= xPosition; j++
            {//r is x position. goes from 0 to xposition or column to column-xposition
                someInts[abs(((level+4)*topOrBottom)-yPosition)*column + abs(((level+4)*leftOrRight)-j)] = 1 //level+3 makes the numbers start at bottom of the playable area and go up (n,n-1,n-2...) *column makes number chosen be on next row
                blocks.blockList[abs(((level+4)*topOrBottom)-yPosition)*column + abs(((level+4)*leftOrRight)-j)].imageType = 1
            }
            for var i = 0; i <= yPosition; i++
            {
                someInts[abs(((level+4)*topOrBottom)-i)*column + abs(((level+4)*leftOrRight)-xPosition)] = 1  //same as r but for y position
                blocks.blockList[abs(((level+4)*topOrBottom)-i)*column + abs(((level+4)*leftOrRight)-xPosition)].imageType = 1
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
                    someInts[(i+5)*column + (j+5)] = 1
                    blocks.blockList[(i+5)*column + (j+5)].imageType = 1
                }
            }
        }
        
        for var w = 0; w < 1; w++
        { //winning block
            var side = Int.random(0...3) //0 is left, 1 is up, 2 is right, 3 is down
            var position = Int.random(0...level-1)
            if side == 0 {
                someInts[(position+4)*column + 4] = 2
                blocks.blockList[(position+5)*column + 4].imageType = 2
            }
            if side == 1 {
                someInts[4*column + position+4] = 2
                blocks.blockList[4*column + position+4].imageType = 2
            }
            if side == 2 {
                someInts[(position+4)*column + level+5] = 2
                blocks.blockList[(position+4)*column + level+5].imageType = 2
            }
            if side == 3 {
                someInts[(level+5)*column + position+4] = 2
                blocks.blockList[(level+5)*column + position+4].imageType = 2
            }
        }
        
        for var p = 0; p < 1; p++
        { //player block
            var side = Int.random(0...3) //0 is left, 1 is up, 2 is right, 3 is down
            var position = Int.random(0...level-1)
            if side == 0 {
                someInts[(position+4)*column + 4] = 2
                blocks.blockList[(position+5)*column + 4].imageType = 2
            }
            if side == 1 {
                someInts[4*column + position+4] = 2
                blocks.blockList[4*column + position+4].imageType = 2
            }
            if side == 2 {
                someInts[(position+4)*column + level+5] = 2
                blocks.blockList[(position+4)*column + level+5].imageType = 2
            }
            if side == 3 {
                someInts[(level+5)*column + position+4] = 2
                blocks.blockList[(level+5)*column + position+4].imageType = 2
            }
        }


        //generating floor
        for i in 0...rows-1
        {
            for j in 0...column-1
            {
                //print("\(someInts[i*column+j]) ")
                print("\(blocks.blockList[i*column+j].imageType) ")
            }
            println()
        }
    }
}