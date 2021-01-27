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
	
	var ui: UI?
	var color: Color = .red {
		didSet {
			guard oldValue != color else {
				return
			}
			paint()
			ui!.scoreXLabel.text = "x\(color.rawValue)"
			ui!.scoreXLabel.paint(fillColor)
		}
	}
	
	init(radius: CGFloat) {
		super.init()
		name = "ball"
		let box = CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: 2 * radius, height: 2 * radius))
		path = CGPath.init(ellipseIn: box, transform: nil)
		physicsBody = SKPhysicsBody(circleOfRadius: radius - 1)
		physicsBody!.restitution = 0.4
		physicsBody!.friction = 0.25
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
				strokeColor = .systemRed
			case .orange:
				fillColor = .systemOrange
				strokeColor = .systemOrange
			case .yellow:
				fillColor = .systemYellow
				strokeColor = .systemYellow
			case .green:
				fillColor = .systemGreen
				strokeColor = .systemGreen
			case .blue:
				fillColor = .systemBlue
				strokeColor = .systemBlue
			case .purple:
				fillColor = .systemPurple
				strokeColor = .systemPurple
		}
	}
	
	func oneUp() {
		color = Color(rawValue: color.rawValue + 1)!
	}
	
	func die() {
		color = Color(rawValue: color.rawValue - 1)!
	}
}
