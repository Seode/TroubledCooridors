import Foundation


class MainScene: CCNode {
    weak var levelNode: CCNode!
    var camera: CCNode!
    var hero: CCSprite!
    var levelGen = WorldGen()
    var timeCounter : Int = 0
    var xMovement : CGFloat = 0
    var yMovement : CGFloat = 0
    var velocity = 2
    var moveSwitch = 0
    
    func didLoadFromCCB() {
        levelGen.columns = levelGen.level+10 //10 is the border size, 5 on each side
        levelGen.rows = levelGen.level+10 //same as columns
        levelGen.horizontal = Int(((levelGen.level%10)/5)+levelGen.level/10) //alterations horizontal lines
        levelGen.vertical = Int(((levelGen.level%10)/7)+levelGen.level/10) //vertical lines
        levelGen.corner = Int(levelGen.level/10) //corner
        levelGen.square = Int(levelGen.level/15) //square
        levelGen.loadWorld()
        //hero.opacity = 0
        userInteractionEnabled = true
        multipleTouchEnabled = true
    }
    
    func spawnTile() {
        var tile = CCBReader.load("Tile")
        levelNode.addChild(tile)
        var tileFiller = levelGen.blocks.blockList[timeCounter]
        var x: CGFloat = CGFloat(tileFiller.columnNum)
        var y: CGFloat = CGFloat(tileFiller.rowNum)
        tile.position = ccp(x * 16, y * 16)
        changeState(tileFiller.imageType, block: tile)
    }
    
    override func update(delta: CCTime) {
        while timeCounter < levelGen.blocks.blockList.count {
            spawnTile()
            timeCounter++
        }
        if timeCounter == levelGen.blocks.blockList.count {
            heroSpawn()
            //hero.opacity = 1
            timeCounter++
        }
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
    }
    
    func checkLocation() {
        if hero.position.y + camera.position.y > 280 || hero.position.y + camera.position.y < 40 {
            camera.position = ccp(camera.position.x, camera.position.y - yMovement)
        }
        if hero.position.x + camera.position.x > 528 || hero.position.x + camera.position.x < 40 {
            camera.position = ccp(camera.position.x - xMovement, camera.position.y)
        }
    }
    
    func checkWalls() {
        //Find blocks hero is located
        var columnLocation = (hero.position.x)/16
        var rowLocation = (hero.position.y)/16
        var columnError = (columnLocation)%1
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
        var blockOneFiller = (Int(lowerRow) * levelGen.rows) + Int(lowerColumn)
        var blockTwoFiller = (Int(higherRow) * levelGen.rows) + Int(lowerColumn)
        var blockThreeFiller = (Int(higherRow) * levelGen.rows) + Int(higherColumn)
        var blockFourFiller = (Int(lowerRow) * levelGen.rows) + Int(higherColumn)
        println("blockOneWall: \(blockOneFiller)")
        println("blockTwoWall: \(blockTwoFiller)")
        println("blockThreeWall: \(blockThreeFiller)")
        println("blockFourWall: \(blockFourFiller)")
        if levelGen.blocks.blockList[blockOneFiller].imageType == 1 {
            blockOneWall = 1
        }
        if levelGen.blocks.blockList[blockTwoFiller].imageType == 1 {
            blockTwoWall = 1
        }
        if levelGen.blocks.blockList[blockThreeFiller].imageType == 1 {
            blockTwoWall = 1
        }
        if levelGen.blocks.blockList[blockFourFiller].imageType == 1 {
            blockTwoWall = 1
        }
        var wallSum = blockOneWall + blockTwoWall + blockThreeWall + blockFourWall
        if wallSum == 1 {
            if blockOneWall == 1 {
                if (1 - columnError) < (1 - rowError) {
                    hero.position.x = higherColumn * 16
                }
                else {
                    hero.position.y = higherRow * 16
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
                if blockTwoWall == 1 {
                    hero.position.x = higherColumn * 16
                }
                else {
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
}

