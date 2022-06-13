//
//  GameScene.swift
//  beach ball
//
//  Created by Zachary Crutchfield on 6/9/22.
//

import SpriteKit
import GameplayKit
struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
}
func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    // 1
    let player = SKSpriteNode(imageNamed: "Leg")

      
    override func didMove(to view: SKView) {
      // 2
      backgroundColor = SKColor.white
      // 3
        player.position = CGPoint(x: 20, y: 20)
        
//        player.position = CGPoint(x: size.width * 100, y: size.height * 100)
      // 4
      addChild(player)
    }

    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self))
            
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
    }

    func addMonster() {
      
      // Create sprite
      let monster = SKSpriteNode(imageNamed: "sand_castle")
      
      // Determine where to spawn the monster along the Y axis
      let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
      
      // Position the monster slightly off-screen along the right edge,
      // and along a random position along the Y axis as calculated above
      monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
      
      // Add the monster to the scene
      addChild(monster)
      
      // Determine speed of the monster
      let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
      
      // Create the actions
      let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),
                                     duration: TimeInterval(actualDuration))
      let actionMoveDone = SKAction.removeFromParent()
      monster.run(SKAction.sequence([actionMove, actionMoveDone]))
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5}
        
        func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      // 1 - Choose one of the touches to work with
      guard let touch = touches.first else {
        return
      }
      let touchLocation = touch.location(in: self)
      
      // 2 - Set up initial location of projectile
      let projectile = SKSpriteNode(imageNamed: "projectile")
      projectile.position = player.position
      
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
      // 3 - Determine offset of location to projectile
      let offset = touchLocation - projectile.position
      
      // 4 - Bail out if you are shooting down or backwards
      if offset.x < 0 { return }
      
      // 5 - OK to add now - you've double checked position
      addChild(projectile)
      
      // 6 - Get the direction of where to shoot
      let direction = offset.normalized()
      
      // 7 - Make it shoot far enough to be guaranteed off screen
      let shootAmount = direction * 1000
      
      // 8 - Add the shoot amount to the current position
      let realDest = shootAmount + projectile.position
      
      // 9 - Create the actions
      let actionMove = SKAction.move(to: realDest, duration: 2.0)
      let actionMoveDone = SKAction.removeFromParent()
      projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
        func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
          print("Hit")
          projectile.removeFromParent()
          monster.removeFromParent()
        }
        func didBegin(_ contact: SKPhysicsContact) {
          // 1
          var firstBody: SKPhysicsBody
          var secondBody: SKPhysicsBody
          if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
          } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
          }
         
          // 2
          if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
              (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
              let projectile = secondBody.node as? SKSpriteNode {
              projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
          }
        }

    
    }
    }

//extension GameScene: SKPhysicsContactDelegate {
//}


