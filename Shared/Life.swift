//
//  Life.swift
//  Fally Bally
//
//  Created by Sam McBroom on 1/3/26.
//

import SpriteKit

class Life: SKShapeNode {
	private let fillAlpha: Double

	init(radius: CGFloat, fillAlpha: Double) {
		self.fillAlpha = fillAlpha
		super.init()
		let box = CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: 2 * radius, height: 2 * radius))
		path = CGPath.init(ellipseIn: box, transform: nil)
		let circlePhysicsBody = SKPhysicsBody(circleOfRadius: radius)
		circlePhysicsBody.isDynamic = false
		circlePhysicsBody.categoryBitMask = 0
		circlePhysicsBody.collisionBitMask = 0
		circlePhysicsBody.contactTestBitMask = 0
		physicsBody = circlePhysicsBody
		isHidden = true
	}

	required init?(coder aDecoder: NSCoder) {
		self.fillAlpha = 0
		super.init(coder: aDecoder)
	}

	func paint(ballColor: Ball.Color) {
		let color = Ball.Color(rawValue: ballColor.rawValue + 1)
		let lifeColor: UIColor = switch color {
		case .orange: .systemOrange
		case .yellow: .systemYellow
		case .green: .systemGreen
		case .blue: .systemBlue
		case .purple: .systemPurple
		default: .systemGray
		}
		fillColor = lifeColor.withAlphaComponent(fillAlpha)
		strokeColor = lifeColor.withAlphaComponent(fillAlpha)
	}

	func collect() {
		isHidden = true

		guard let physicsBody else {
			return
		}

		physicsBody.contactTestBitMask = 0
	}

	func spawn() {
		isHidden = false

		guard let physicsBody else {
			return
		}

		physicsBody.contactTestBitMask = 1
	}
}

