import SpriteKit

class Ground: SKSpriteNode, GameSprite {
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "Environment")
    var initialSize = CGSize.zero
    
    // Tiling variables
    var jumpWidth = CGFloat()
    var jumpCount = CGFloat(1)

    
    // This function tiles the ground texture across the width of the Ground node
    func createChildren() {
        self.anchorPoint = CGPoint(x: 0, y: 1)
        let texture = textureAtlas.textureNamed("ground")
        var tileCount:CGFloat = 0
        let tileSize = CGSize(width: 35, height: 300)
        
        // Build nodes until we cover the entire Ground width
        while tileCount * tileSize.width < self.size.width {
            let tileNode = SKSpriteNode(texture: texture)
            tileNode.size = tileSize
            tileNode.position.x = tileCount * tileSize.width
            tileNode.anchorPoint = CGPoint(x: 0, y: 1) // Position child nodes by their upper left corner
            self.addChild(tileNode)
            tileCount += 1
        }
        
        let pointTopLeft = CGPoint(x: 0, y: 0)
        let pointTopRight = CGPoint(x: size.width, y: 0)
        self.physicsBody = SKPhysicsBody(edgeFrom: pointTopLeft, to: pointTopRight)
        self.physicsBody?.categoryBitMask = PhysicsCategory.ground.rawValue
        
        // Save the width of one-third of the children nodes
        jumpWidth = tileSize.width * floor(tileCount / 3)
    }
    
    func checkForReposition(playerProgress:CGFloat) {
        // The ground needs to jump forward every time the player has moved this distance
        let groundJumpPosition = jumpWidth * jumpCount
        
        if playerProgress >= groundJumpPosition {
            // The player has moved past the jump position
            // Move the ground forward
            self.position.x += jumpWidth
            jumpCount += 1
        }
    }
    
    func onTap() {}
}
