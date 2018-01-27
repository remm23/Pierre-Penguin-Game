import SpriteKit

class Background: SKSpriteNode {
    // movementMultiplier will store a float from 0-1 to indicate
    // how fast the background should move past
    // 0 is full adjustment, no movement as the world goes past
    // 1 is no adjustment, background passes at normal speed
    var movementMultiplier = CGFloat(0)
    // jumpAdjustment will store how many points of x position
    // this background has jumped forward
    var jumpAdjustment = CGFloat(0)
    let backgroundSize = CGSize(width: 1024, height: 768) // A constant for background node size
    var textureAtlas = SKTextureAtlas(named: "Backgrounds")
    
    func spawn(parentNode:SKNode, imageName:String, zPosition:CGFloat, movementMultiplier:CGFloat) {
        self.anchorPoint = CGPoint.zero // Position from the bottom left
        self.position = CGPoint(x: 0, y: 30) // Start backgrounds at the top of the ground (y: 30)
        self.zPosition = zPosition
        self.movementMultiplier = movementMultiplier
        parentNode.addChild(self)
        let texture = textureAtlas.textureNamed(imageName)
        
        // Build three child node instances of the texture,
        // Looping from -1 to 1 so the backgrounds cover both
        // forward and behind the player at position zero
        for i in -1...1 {
            let newBGNode = SKSpriteNode(texture: texture)
            newBGNode.size = backgroundSize
            newBGNode.anchorPoint = CGPoint.zero
            // Position this background node:
            newBGNode.position = CGPoint(x: i * Int(backgroundSize.width), y: 0)
            self.addChild(newBGNode)
        }
    }
    
    // Update the position every frame to reposition the background
    func updatePosition(playerProgress:CGFloat) {
        // Calculate a position adjustment after loops and
        // parallax multiplier
        let adjustedPosition = jumpAdjustment + playerProgress * (1 - movementMultiplier)
        // Check if we need to jump the background forward
        if playerProgress - adjustedPosition > backgroundSize.width {
            jumpAdjustment += backgroundSize.width
        }
        // Adjust this background forward as the world moves back so the background appears slower
        self.position.x = adjustedPosition
    }
}
