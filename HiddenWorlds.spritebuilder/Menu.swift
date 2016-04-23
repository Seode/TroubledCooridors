//
//  Menu.swift
//  HiddenWorlds
//
//  Created by Jacob Apenes on 4/22/16.
//  Copyright (c) 2016 Apportable. All rights reserved.
//

import Foundation

class Menu: CCScene {
    var title : CCLabelTTF!
    var playButton : CCButton!
    var helpButton : CCButton!
    var creditButton : CCButton!
    
    func didLoadFromCCB() {
        
    }
    
    override func update(delta: CCTime) {
        
    }
    
    func play() {
        let mainScene: CCScene = CCBReader.loadAsScene("MainScene")
        CCDirector.sharedDirector().replaceScene(mainScene);
    }
    
    func help() {
        
    }
    
    func credits() {
        
    }
}