//
//  Heart.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/18/21.
//

import SpriteKit

class Heart: ScaleableNode {
	convenience init() {
		self.init(symbolName: "heart.circle", width: 20)
		name = "heart"
		physicsBody = SKPhysicsBody(circleOfRadius: 10)
		physicsBody!.isDynamic = false
		physicsBody!.categoryBitMask = 0
		physicsBody!.collisionBitMask = 0
		collect()
		paint(.systemPink)
	}
	
	func collect() {
		isHidden = true
		physicsBody!.contactTestBitMask = 0
	}
	
	func spawn() {
		isHidden = false
		physicsBody!.contactTestBitMask = 1
	}
}
