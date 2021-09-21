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
	
	override func paint() {
		super.paint()
		
		if !children.isEmpty {
			(children.first! as! Text).paint()
		}
	}
	
	func score(_ amount: Int) {
		let scoreLabel = Text("+\(amount)")
		scoreLabel.zPosition = 2
		addChild(scoreLabel)
		let oldSize = size
		size = CGSize.zero
		physicsBody!.contactTestBitMask = 0
		scoreLabel.position = CGPoint(x: 0, y: frame.maxY + 5)
		scoreLabel.run(.fadeOut(withDuration: 1))
		Task {
			await scoreLabel.run(.move(by: CGVector(dx: 0, dy: 20), duration: 1))
			removeAllChildren()
			size = oldSize
			isHidden = true
		}
	}
}
