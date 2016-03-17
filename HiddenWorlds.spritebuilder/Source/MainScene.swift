import Foundation


class MainScene: CCNode {
    weak var levelNode: CCNode!
    var hero: CCSprite!
    var levelGen = WorldGen()
    var timeCounter : Int = 0
    
    func didLoadFromCCB() {
        levelGen.column = levelGen.level+10 //10 is the border size, 5 on each side
        levelGen.rows = levelGen.level+10 //same as column
        levelGen.horizontal = Int(((levelGen.level%10)/5)+levelGen.level/10) //alterations horizontal lines
        levelGen.vertical = Int(((levelGen.level%10)/7)+levelGen.level/10) //vertical lines
        levelGen.corner = Int(levelGen.level/10) //corner
        levelGen.square = Int(levelGen.level/15) //square
        levelGen.loadWorld()
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
    }
    
    override func touchBegan(touch: CCTouch!, withEvent: CCTouchEvent!) {
        var location = touch.locationInNode(levelNode)
    }
    
    override func touchMoved(touch: CCTouch!, withEvent: CCTouchEvent!) {
        var location = touch.locationInNode(levelNode)
    }
    
    override func touchEnded(touch: CCTouch!, withEvent: CCTouchEvent!) {
        var location = touch.locationInNode(levelNode)
    }
    
    func changeState(state: Int, block: CCNode) {
        if state == 1 {
            block.animationManager.runAnimationsForSequenceNamed("StateOne")
        }
        if state == 2 {
            block.animationManager.runAnimationsForSequenceNamed("StateTwo")
        }
    }
}

