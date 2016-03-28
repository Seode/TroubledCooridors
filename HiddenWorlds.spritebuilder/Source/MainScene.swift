import Foundation


class MainScene: CCNode {
    weak var levelNode: CCNode!
    var hero: CCSprite!
    var levelGen = WorldGen()
    var timeCounter : Int = 0
    var xMovement : CGFloat = 0
    var yMovement : CGFloat = 0
    var velocity = 2
    
    func didLoadFromCCB() {
        levelGen.column = levelGen.level+10 //10 is the border size, 5 on each side
        levelGen.rows = levelGen.level+10 //same as column
        levelGen.horizontal = Int(((levelGen.level%10)/5)+levelGen.level/10) //alterations horizontal lines
        levelGen.vertical = Int(((levelGen.level%10)/7)+levelGen.level/10) //vertical lines
        levelGen.corner = Int(levelGen.level/10) //corner
        levelGen.square = Int(levelGen.level/15) //square
        levelGen.loadWorld()
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
        moveHero(xMovement, y: yMovement)
    }
    
    override func touchBegan(touch : CCTouch, withEvent: CCTouchEvent) {
        var location = touch.locationInNode(levelNode)
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
    
    override func touchMoved(touch : CCTouch, withEvent: CCTouchEvent) {
        var location = touch.locationInNode(levelNode)
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
    }
    
    func changeState(state: Int, block: CCNode) {
        if state == 1 {
            block.animationManager.runAnimationsForSequenceNamed("StateOne")
        }
        if state == 2 {
            block.animationManager.runAnimationsForSequenceNamed("StateTwo")
        }
    }
    
    func moveHero(x: CGFloat, y: CGFloat) {
        hero.position = ccp(hero.position.x + xMovement, hero.position.y + yMovement)
    }
}

