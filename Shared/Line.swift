//
//  Line.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/17/21.
//

import SpriteKit

class Line: SKShapeNode {
	private static let defaultColor: UIColor = .systemGray
	private var nodeColor: UIColor = defaultColor
	private(set) var scored = false

	init(width: CGFloat, height: CGFloat) {
		super.init()
		let box = CGRect(origin: .zero, size: CGSize(width: width, height: height))
		path = CGPath.init(roundedRect: box, cornerWidth: 2, cornerHeight: 2, transform: nil)
		let linePhysicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: box.maxY), to: CGPoint(x: box.maxX, y: box.maxY))
		linePhysicsBody.categoryBitMask = 1
		linePhysicsBody.collisionBitMask = 0
		linePhysicsBody.contactTestBitMask = 1
		physicsBody = linePhysicsBody
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	func paint(_ color: UIColor) {
		nodeColor = color
		fillColor = color
		strokeColor = color
	}

	func paint(ballColor: Ball.Color) {
		paint(nodeColor)
		for child in children {
			guard let life = child as? Life else {
				continue
			}

			life.paint(ballColor: ballColor)
		}
	}

	func score(_ color: UIColor) {
		scored = true
		paint(color)
	}

	func setup() {
		scored = false
		paint(Self.defaultColor)
	}
}
