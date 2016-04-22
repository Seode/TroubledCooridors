import Foundation


class MainScene: CCNode {
    weak var levelNode: CCNode!
    var camera: CCNode!
    var hero: CCSprite!
    var exit: CCSprite!
    var levelGen = WorldGen()
    var timeCounter : Int = 0
    var xMovement : CGFloat = 0
    var yMovement : CGFloat = 0
    var velocity = 2
    var moveSwitch = 0
    var level = 1
    
    func didLoadFromCCB() {
        levelGen.columns = 60 //each room will be 60x60
        levelGen.rows = 60
        /*levelGen.horizontal = Int(((levelGen.level%10)/5)+levelGen.level/10) //alterations horizontal lines
        levelGen.vertical = Int(((levelGen.level%10)/7)+levelGen.level/10) //vertical lines
        levelGen.corner = Int(levelGen.level/10) //corner
        levelGen.square = Int(levelGen.level/15) //square*/
        levelGen.loadWorld()
        loadTiles()
        //hero.opacity = 0
        userInteractionEnabled = true
        multipleTouchEnabled = true
    }
    
    func loadTiles() {
        //world generation pseudocode
        for item in 0...levelGen.blocks.blockList.count-1 {
            spawnTile(item)
        }
        heroSpawn()
        exitSpawn()
    }
    
    func spawnTile(timer: Int) {
        //after map is loaded, begin spawning tiles with images and positions cooresponding to text map
        //TO-DO: Be able to call back to individual tiles
        var tile = CCBReader.load("Tile")
        levelNode.addChild(tile)
        var tileFiller = levelGen.blocks.blockList[timer]
        var x: CGFloat = CGFloat(tileFiller.columnNum)
        var y: CGFloat = CGFloat(tileFiller.rowNum)
        tile.position = ccp(x * 16, y * 16)
        //tile.room = level
        //tile.columnLocation = tileFiller.columnNum
        //tile.rowLocation = tileFiller.rowNum
        changeState(tileFiller.imageType, block: tile)
    }
    
    func unloadTiles() {
        //removes all tiles from scene and textmap
        levelNode.removeAllChildren()
        levelGen.blocks.blockList.removeAll()
    }
    
    func spawnRoom() {
        
    }
    
    override func update(delta: CCTime) {
        /*while timeCounter < levelGen.blocks.blockList.count {
            spawnTile()
            timeCounter++
        }
        if timeCounter == levelGen.blocks.blockList.count {
            heroSpawn()
            exitSpawn()
            //hero.opacity = 1
            timeCounter++
        }*/
        if moveSwitch == 1 {
            moveHero(xMovement, y: yMovement)
        }
    }
    
    override func touchBegan(touch : CCTouch, withEvent: CCTouchEvent) {
        var location = touch.locationInNode(camera)
        println("Touch - X: \(location.x) Y: \(location.y)")
        println("Player - X: \(hero.position.x) Y: \(hero.position.y)")
        var xDifference = location.x - hero.position.x
        var yDifference = location.y - hero.position.y
        var xDirection : CGFloat = 0
        var yDirection : CGFloat = 0
        if xDifference < 0 {
            xDirection = -1
        }
        else {
            xDirection = 1
        }
        
        if yDifference < 0 {
            yDirection = -1
        }
        else {
            yDirection = 1
        }
        var angle = atan(abs(yDifference/xDifference))
        xMovement = CGFloat(velocity)*CGFloat(cos(Double(angle)))*xDirection
        yMovement = CGFloat(velocity)*CGFloat(sin(Double(angle)))*yDirection
        moveSwitch = 1
    }
    
    override func touchMoved(touch : CCTouch, withEvent: CCTouchEvent) {
        var location = touch.locationInNode(camera)
        println("Touch - X: \(location.x) Y: \(location.y)")
        println("Player - X: \(hero.position.x) Y: \(hero.position.y)")
        var xDifference = location.x - hero.position.x
        var yDifference = location.y - hero.position.y
        var xDirection : CGFloat = 0
        var yDirection : CGFloat = 0
        if xDifference < 0 {
            xDirection = -1
        }
        else {
            xDirection = 1
        }
        
        if yDifference < 0 {
            yDirection = -1
        }
        else {
            yDirection = 1
        }
        var angle = atan(abs(yDifference/xDifference))
        xMovement = CGFloat(velocity)*CGFloat(cos(Double(angle)))*xDirection
        yMovement = CGFloat(velocity)*CGFloat(sin(Double(angle)))*yDirection
    }
    
    override func touchEnded(touch : CCTouch, withEvent: CCTouchEvent) {
        println("Touch Ended")
        xMovement = 0
        yMovement = 0
        moveSwitch = 0
    }
    
    func changeState(state: Int, block: CCNode) {
        if state == 1 {
            block.animationManager.runAnimationsForSequenceNamed("StateOne")
        }
        if state == 2 {
            block.animationManager.runAnimationsForSequenceNamed("StateTwo")
        }
    }
    
    func heroSpawn(){
        var currentBlock = levelGen.blocks.blockList[0]
        for row in 0...levelGen.rows - 1 {
            for column in 0...levelGen.columns - 1 {
                if levelGen.blocks.blockList[(row * levelGen.rows) + column].imageType == 0 {
                    currentBlock = levelGen.blocks.blockList[(row * levelGen.rows) + column]
                    hero.position = ccp(CGFloat(currentBlock.columnNum * 16), CGFloat(currentBlock.rowNum * 16))
                    println("Spawn Column: \(currentBlock.columnNum)")
                    println("Spawn Row: \(currentBlock.rowNum)")
                    break;
                }
            }
        }
        camera.position = ccp(284 - hero.position.x, 160 - hero.position.y)
    }
    
    func moveHero(x: CGFloat, y: CGFloat) {
        hero.position = ccp(hero.position.x + xMovement, hero.position.y + yMovement)
        checkLocation()
        checkWalls()
        checkExit()
    }
    
    func exitSpawn() {
        var currentBlock = levelGen.blocks.blockList[0]
        var columnArray : [Int] = []
        var rowArray : [Int] = []
        for row in 0...levelGen.rows - 1 {
            for column in 0...levelGen.columns - 1 {
                currentBlock = levelGen.blocks.blockList[(row * levelGen.rows) + column]
                if currentBlock.imageType == 0 {
                    columnArray.append(currentBlock.columnNum)
                    rowArray.append(currentBlock.rowNum)
                }
            }
        }
        var random = arc4random_uniform(UInt32(columnArray.count))
        exit.position = ccp(CGFloat(columnArray[Int(random)] * 16), CGFloat(rowArray[Int(random)] * 16))
    }
    
    func checkLocation() {
        if hero.position.y + camera.position.y > 240 || hero.position.y + camera.position.y < 80 {
            camera.position = ccp(camera.position.x, camera.position.y - yMovement)
        }
        if hero.position.x + camera.position.x > 488 || hero.position.x + camera.position.x < 80 {
            camera.position = ccp(camera.position.x - xMovement, camera.position.y)
        }
    }
    
    func checkWalls() {
        //Find blocks hero is located
        var columnLocation = (hero.position.x)/16
        var rowLocation = (hero.position.y)/16
        var columnError = (columnLocation)%1 //checks distance from the .00 mark
        var rowError = (rowLocation)%1
        var lowerColumn = columnLocation - columnError
        var higherColumn = lowerColumn + 1
        var lowerRow = rowLocation - rowError
        var higherRow = lowerRow + 1
        //Check for walls
        // -----
        // |2|3|
        // |1|4|
        // -----
        var blockOneWall = 0
        var blockTwoWall = 0
        var blockThreeWall = 0
        var blockFourWall = 0
        //fillers are use to shorten the if statements below. They use the same searching function as BoxBuilder.swift
        var blockOneFiller = (Int(lowerRow) * levelGen.columns) + Int(lowerColumn)
        var blockTwoFiller = (Int(higherRow) * levelGen.columns) + Int(lowerColumn)
        var blockThreeFiller = (Int(higherRow) * levelGen.columns) + Int(higherColumn)
        var blockFourFiller = (Int(lowerRow) * levelGen.columns) + Int(higherColumn)
        /*println("BlockOne: Column - \(lowerColumn) Row - \(lowerRow)")
        println("BlockTwo: Column - \(lowerColumn) Row - \(higherRow)")
        println("BlockThree: Column - \(higherColumn) Row - \(higherRow)")
        println("BlockFour: Column - \(higherColumn) Row - \(lowerRow)")*/
        if levelGen.blocks.blockList[blockOneFiller].imageType == 1 {
            blockOneWall = 1
        }
        if levelGen.blocks.blockList[blockTwoFiller].imageType == 1 {
            blockTwoWall = 1
        }
        if levelGen.blocks.blockList[blockThreeFiller].imageType == 1 {
            blockThreeWall = 1
        }
        if levelGen.blocks.blockList[blockFourFiller].imageType == 1 {
            blockFourWall = 1
        }
        //wallSum checks which collision function to use
        var wallSum = blockOneWall + blockTwoWall + blockThreeWall + blockFourWall
        println("wallSum: \(wallSum)")
        println("blockOneWall: \(blockOneWall)")
        println("blockTwoWall: \(blockTwoWall)")
        println("blockThreeWall: \(blockThreeWall)")
        println("blockFourWall: \(blockFourWall)")
        if wallSum == 1 {
            //finds wall
            if blockOneWall == 1 {
                if (1 - columnError) < (1 - rowError) {
                    hero.position.x = higherColumn * 16 //if y position is lodged more into wall, move x position to .00 mark
                }
                else {
                    hero.position.y = higherRow * 16 //otherwise move y position
                }
            }
            else if blockTwoWall == 1 {
                if (1 - columnError) < rowError {
                    hero.position.x = higherColumn * 16
                }
                else {
                    hero.position.y = lowerRow * 16
                }
            }
            else if blockThreeWall == 1 {
                if columnError < rowError {
                    hero.position.x = lowerColumn * 16
                }
                else {
                    hero.position.y = lowerRow * 16
                }
            }
            else {
                if columnError < (1 - rowError) {
                    hero.position.x = lowerColumn * 16
                }
                else {
                    hero.position.y = higherRow * 16
                }
            }
        }
        else if wallSum == 2 {
            if blockOneWall == 1 {
                if blockTwoWall == 1 { //if walls are on the same column, move the x position
                    hero.position.x = higherColumn * 16
                }
                else { //if walls are on the same row, move the y position
                    hero.position.y = higherRow * 16
                }
            }
            else if blockTwoWall == 1 {
                hero.position.y = lowerRow * 16
            }
            else {
                hero.position.x = lowerColumn * 16
            }
        }
        else if wallSum == 3 {
            //move hero to open tile
            if blockOneWall == 0 {
                hero.position.x = lowerColumn * 16
                hero.position.y = lowerRow * 16
            }
            else if blockTwoWall == 0 {
                hero.position.x = lowerColumn * 16
                hero.position.y = higherRow * 16
            }
            else if blockThreeWall == 0 {
                hero.position.x = higherColumn * 16
                hero.position.y = higherRow * 16
            }
            else {
                hero.position.x = higherColumn * 16
                hero.position.y = lowerRow * 16
            }
        }
        println("Column: \(columnLocation)")
        println("Row: \(rowLocation)")
    }
    
    func checkExit() {
        //if hero is on exit, load new level
        var xDifference = hero.position.x - exit.position.x
        var yDifference = hero.position.y - exit.position.y
        var fullDifference = sqrt(xDifference * xDifference + yDifference * yDifference)
        if fullDifference < 8 {
            unloadTiles()
            levelGen.loadWorld()
            loadTiles()
        }
    }
}

