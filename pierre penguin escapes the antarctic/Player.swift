import SpriteKit

class Player : SKSpriteNode, GameSprite {
    var initialSize = CGSize(width: 64, height: 64)
    var textureAtlas:SKTextureAtlas = SKTextureAtlas(named:"Pierre")
    
    var flyAnimation = SKAction()
    var soarAnimation = SKAction()
    var damageAnimation = SKAction()
    var dieAnimation = SKAction()
    
    var flapping = false
    let maxFlappingForce:CGFloat = 57000 // Set a maximum upward force
    let maxHeight:CGFloat = 1000
    
    var health:Int = 3
    let maxHealth = 3
    var invulnerable = false
    var damaged = false
    var forwardVelocity:CGFloat = 200

    let powerupSound = SKAction.playSoundFileNamed("Sound/Powerup.aif",
        waitForCompletion: false)
    let hurtSound = SKAction.playSoundFileNamed("Sound/Hurt.aif", waitForCompletion: false)

    init() {
        super.init(texture: nil, color: UIColor.clear, size: initialSize)
        
        createAnimations()
        self.run(soarAnimation, withKey: "soarAnimation")
        
        
        let bodyTexture = textureAtlas.textureNamed("pierre-flying-3")
        self.physicsBody = SKPhysicsBody(texture: bodyTexture,size: self.size)
        self.physicsBody?.linearDamping = 0.9 // Pierre will lose momentum quickly with a high linearDamping:
        self.physicsBody?.mass = 30 // Adult penguins weigh around 30kg:
        self.physicsBody?.allowsRotation = false
        
        self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
        self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        self.physicsBody?.contactTestBitMask =
            PhysicsCategory.enemy.rawValue |
            PhysicsCategory.ground.rawValue |
            PhysicsCategory.powerup.rawValue |
            PhysicsCategory.coin.rawValue |
            PhysicsCategory.crate.rawValue
        
        
        // Grant a momentary reprieve from gravity
        self.physicsBody?.affectedByGravity = false
        // Add some slight upward velocity
        self.physicsBody?.velocity.dy = 80
        // Create a SKAction to start gravity after a small delay
        let startGravitySequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.6), SKAction.run {
                self.physicsBody?.affectedByGravity = true
            }])
        self.run(startGravitySequence)
    }
    
    func createAnimations() {
        let rotateUpAction = SKAction.rotate(toAngle: 0, duration: 0.475)
        rotateUpAction.timingMode = .easeOut
        let rotateDownAction = SKAction.rotate(toAngle: -1, duration: 0.8)
        rotateDownAction.timingMode = .easeIn
        
        // Create the flying animation
        let flyFrames:[SKTexture] = [
            textureAtlas.textureNamed("pierre-flying-1"),
            textureAtlas.textureNamed("pierre-flying-2"),
            textureAtlas.textureNamed("pierre-flying-3"),
            textureAtlas.textureNamed("pierre-flying-4"),
            textureAtlas.textureNamed("pierre-flying-3"),
            textureAtlas.textureNamed("pierre-flying-2")
        ]
        let flyAction = SKAction.animate(with: flyFrames, timePerFrame: 0.03)
        
        flyAnimation = SKAction.group([ SKAction.repeatForever(flyAction), rotateUpAction])
        
        let soarFrames:[SKTexture] = [textureAtlas.textureNamed("pierre-flying-1")]
        let soarAction = SKAction.animate(with: soarFrames, timePerFrame: 1)
        soarAnimation = SKAction.group([SKAction.repeatForever(soarAction), rotateDownAction ])
        
        // --- Create the taking damage animation ---
        let damageStart = SKAction.run {
            // Allow the penguin to pass through enemies
            self.physicsBody?.categoryBitMask = PhysicsCategory.damagedPenguin.rawValue
        }
        
        // Opacity pulse
        let slowFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.35),
            SKAction.fadeAlpha(to: 0.7, duration: 0.35)
            ])
        let fastFade = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 0.7, duration: 0.2)
            ])
        let fadeOutAndIn = SKAction.sequence([
            SKAction.repeat(slowFade, count: 2),
            SKAction.repeat(fastFade, count: 5),
            SKAction.fadeAlpha(to: 1, duration: 0.15)
            ])
        
        // Return the penguin to normal
        let damageEnd = SKAction.run {
            self.physicsBody?.categoryBitMask = PhysicsCategory.penguin.rawValue
            // Turn off the newly damaged flag
            self.damaged = false
        }
        
        // Damage animation sequence
        self.damageAnimation = SKAction.sequence([damageStart, fadeOutAndIn, damageEnd])
        
        /* --- Death Animation --- */
        let startDie = SKAction.run {
            self.texture = self.textureAtlas.textureNamed("pierre-dead")
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            // Make the penguin pass through everything except the ground:
            self.physicsBody?.collisionBitMask = PhysicsCategory.ground.rawValue
        }
        
        let endDie = SKAction.run {
            self.physicsBody?.affectedByGravity = true
        }
        
        self.dieAnimation = SKAction.sequence([
            startDie,
            SKAction.scale(to: 1.3, duration: 0.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.rotate(toAngle: 3, duration: 1.5),
            SKAction.wait(forDuration: 0.5),
            endDie
            ])
    }
    
    func update() {
        // If flapping, apply a new force to push Pierre higher.
        if self.flapping {
            var forceToApply = maxFlappingForce
            
            // Apply less force if Pierre is above position 600
            if position.y > 600 {
                // The higher Pierre goes, the more force to remove
                let percentageOfMaxHeight = position.y / maxHeight
                let flappingForceSubtraction = percentageOfMaxHeight * maxFlappingForce
                forceToApply -= flappingForceSubtraction
            }
            // Apply force
            self.physicsBody?.applyForce(CGVector(dx: 0, dy: forceToApply))
        }
        
        // Limit Pierre's top speed as he climbs the y-axis.
        if self.physicsBody!.velocity.dy > CGFloat(300) {
            self.physicsBody!.velocity.dy = 300
        }
        
        // Set a constant velocity to the right
        self.physicsBody?.velocity.dx = self.forwardVelocity
    }
    
    // Begin the flap animation, set flapping to true
    func startFlapping() {
        if self.health <= 0 { return }
        self.removeAction(forKey: "soarAnimation")
        self.run(flyAnimation, withKey: "flapAnimation")
        self.flapping = true
    }
    
    // Stop the flap animation, set flapping to false
    func stopFlapping() {
        if self.health <= 0 { return }
        self.removeAction(forKey: "flapAnimation")
        self.run(soarAnimation, withKey: "soarAnimation")
        self.flapping = false
    }
    
    func starPower() {
        // Remove any existing star power-up animation, if the player is already under the power of star
        self.removeAction(forKey: "starPower")
        self.forwardVelocity = 400
        self.invulnerable = true
        let starSequence = SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.3),
            SKAction.wait(forDuration: 8),
            SKAction.scale(to: 1, duration: 1),
            SKAction.run {
                self.forwardVelocity = 200
                self.invulnerable = false
            }
            ])
        // Execute the sequence
        self.run(starSequence, withKey: "starPower")
        // Play the powerup sound
        self.run(powerupSound)
    }
    
    func takeDamage() {
        if self.invulnerable || self.damaged { return }
        self.damaged = true
        
        self.health -= 1
        if self.health == 0 {
            // Die
            die()
        } else {
            // Take damage
            self.run(self.damageAnimation)
        }
        // Play the hurt sound
        self.run(hurtSound)
    }
    
    func die() {
        self.alpha = 1
        self.removeAllActions()
        self.run(self.dieAnimation)
        self.flapping = false
        self.forwardVelocity = 0
        // Alert the GameScene:
        if let gameScene = self.parent as? GameScene {
            gameScene.gameOver()
        }

    }
    
    func onTap() {}
    
    // Satisfy the NSCoder required init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
