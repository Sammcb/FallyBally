//
//  Ball.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/17/21.
//

import SpriteKit
import SwiftUI

class Ball: SKShapeNode {
	enum Color: Int, Codable {
		case red = 1, orange, yellow, green, blue, purple

		var ui: SwiftUI.Color {
			switch self {
			case .red: .red
			case .orange: .orange
			case .yellow: .yellow
			case .green: .green
			case .blue: .blue
			case .purple: .purple
			}
		}
	}

	var color: Color = .red {
		didSet {
			guard oldValue != color else {
				return
			}
			paint()
		}
	}

	init(radius: CGFloat) {
		super.init()
		let box = CGRect(origin: CGPoint(x: -radius, y: -radius), size: CGSize(width: 2 * radius, height: 2 * radius))
		path = CGPath.init(ellipseIn: box, transform: nil)
		let circlePhysicsBody = SKPhysicsBody(circleOfRadius: radius - 1)
		circlePhysicsBody.restitution = 0.4
		circlePhysicsBody.friction = 0.25
		circlePhysicsBody.allowsRotation = false
		circlePhysicsBody.categoryBitMask = 3
		circlePhysicsBody.collisionBitMask = 3
		circlePhysicsBody.contactTestBitMask = 0
		physicsBody = circlePhysicsBody
		zPosition = 1
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func paint() {
		let ballColor: UIColor = switch color {
		case .red: .systemRed
		case .orange: .systemOrange
		case .yellow: .systemYellow
		case .green: .systemGreen
		case .blue: .systemBlue
		case .purple: .systemPurple
		}
		fillColor = ballColor
		strokeColor = ballColor
	}

	private func recolor(colorDelta: Int) {
		guard let newColor = Color(rawValue: color.rawValue + colorDelta) else {
			return
		}
		color = newColor
	}

	func oneUp() {
		recolor(colorDelta: 1)
	}

	func die() {
		recolor(colorDelta: -1)
	}
}
