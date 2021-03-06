import SpriteKit

class EncounterManager {
    
    let encounterNames:[String] = [
        "EncounterA",
        "EncounterB",
        "EncounterC"
    ]

    var encounters:[SKNode] = []
    // Variables to track the encounters currently on the screen
    var currentEncounterIndex:Int?
    var previousEncounterIndex:Int?
    
    init() {

        for encounterFileName in encounterNames {
            let encounterNode = SKNode()
            
            if let encounterScene = SKScene(fileNamed: encounterFileName) {
                // Loop through each child node in the SKScene
                for child in encounterScene.children {
                    // Create a copy of the scene's child node to add to encounter node
                    let copyOfNode = type(of: child).init()
                    // Save the scene node’s position to the copy
                    copyOfNode.position = child.position
                    // Save the scene node’s name to the copy
                    copyOfNode.name = child.name
                    encounterNode.addChild(copyOfNode)
                }
            }
            
            // Add the populated encounter node to the array
            encounters.append(encounterNode)
            // Save initial sprite positions for this encounter
            saveSpritePositions(node: encounterNode)
            // Turn golden coins gold!
            encounterNode.enumerateChildNodes(withName: "gold") {
                (node: SKNode, stop: UnsafeMutablePointer) in
                (node as? Coin)?.turnToGold()
            }
        }
    }
    
    //    called from GameScene
    func addEncountersToScene(gameScene:SKNode) {
        var encounterPosY = 1000
        for encounterNode in encounters {
            // Spawn the encounters behind the action, with increasing height so they do not collide
            encounterNode.position = CGPoint(x: -2000, y: encounterPosY)
            gameScene.addChild(encounterNode)
            // Double the Y pos for the next encounter:
            encounterPosY *= 2
        }
    }
    
    func placeNextEncounter(currentXPos:CGFloat) {
        // Count the encounters in a random ready type (Uint32)
        let encounterCount = UInt32(encounters.count)
        // The game requires at least 3 encounters to function
        if encounterCount < 3 { return }
        //Pick an encounter that is not currently displayed on the screen.
        var nextEncounterIndex:Int?
        var trulyNew:Bool?
        
        // Pick until we get a new encounter
        while trulyNew == false || trulyNew == nil {
            // Pick a random encounter to set next:
            nextEncounterIndex = Int(arc4random_uniform(encounterCount))
            trulyNew = true
            // Test if it is instead the current encounter
            if let currentIndex = currentEncounterIndex {
                if (nextEncounterIndex == currentIndex) {
                    trulyNew = false
                }
            }
            
            // Test if it is the directly previous encounter
            if let previousIndex = previousEncounterIndex {
                if (nextEncounterIndex == previousIndex) {
                    trulyNew = false
                }
            }
        }
        
        // Keep track of the current encounter
        previousEncounterIndex = currentEncounterIndex
        currentEncounterIndex = nextEncounterIndex
        
        // Reset the new encounter and position it ahead of the player
        let encounter = encounters[currentEncounterIndex!]
        encounter.position = CGPoint(x: currentXPos + 1000, y: 300)
        resetSpritePositions(node: encounter)
    }
    
    // Store the initial positions of the children of a node
    func saveSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                let initialPositionValue = NSValue.init(cgPoint: sprite.position)
                spriteNode.userData = ["initialPosition": initialPositionValue]
                // Save the positions for children of this node
                saveSpritePositions(node: spriteNode)
            }
        }
    }
    
    // Reset all children nodes to their original position
    func resetSpritePositions(node:SKNode) {
        for sprite in node.children {
            if let spriteNode = sprite as? SKSpriteNode {
                // Remove any linear or angular velocity
                spriteNode.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                spriteNode.physicsBody?.angularVelocity = 0
                // Reset the rotation of the sprite
                spriteNode.zRotation = 0
                // If this is a Crate, call its reset function
                if let crateTest = spriteNode as? Crate {
                    crateTest.reset()
                }
                
                if let initialPositionVal = spriteNode.userData?.value(forKey:
                    "initialPosition") as? NSValue {
                    // Reset the position of the sprite
                    spriteNode.position = initialPositionVal.cgPointValue
                }
                
                // Reset positions on this node's children
                resetSpritePositions(node: spriteNode)
            }
        }
    }
}
