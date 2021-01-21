//
//  Ball.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/17/21.
//

import SpriteKit

class Ball: SKShapeNode {
	enum Color: Int {
		case red = 1
		case orange
		case yellow
		case green
		case blue
		case purple
	}
	
	var color: Color = .red
	
	init(radius: CGFloat) {
		super.init()
		name = "ball"
		let box = CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: 2 * radius, height: 2 * radius))
		path = CGPath.init(ellipseIn: box, transform: nil)
		lineWidth = 0
		physicsBody = SKPhysicsBody(circleOfRadius: radius)
		physicsBody!.restitution = 0.6
		physicsBody!.allowsRotation = false
		physicsBody!.categoryBitMask = 3
		physicsBody!.collisionBitMask = 3
		physicsBody!.contactTestBitMask = 0
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func paint() {
		switch color {
			case .red:
				fillColor = .systemRed
			case .orange:
				fillColor = .systemOrange
			case .yellow:
				fillColor = .systemYellow
			case .green:
				fillColor = .systemGreen
			case .blue:
				fillColor = .systemBlue
			case .purple:
				fillColor = .systemPurple
		}
	}
	
	func oneUp() {
		color = Color(rawValue: color.rawValue + 1)!
		paint()
	}
	
	func die() {
		color = Color(rawValue: color.rawValue - 1)!
		paint()
	}
}
