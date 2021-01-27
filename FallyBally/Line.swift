//
//  Line.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/17/21.
//

import SpriteKit

class Line: SKShapeNode {
	private var nodeColor: UIColor = .systemGray
	var scored = false
	
	init(width: CGFloat, height: CGFloat) {
		super.init()
		let box = CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height))
		path = CGPath.init(roundedRect: box, cornerWidth: 2, cornerHeight: 2, transform: nil)
		physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: box.maxY), to: CGPoint(x: box.maxX, y: box.maxY))
		physicsBody!.categoryBitMask = 1
		physicsBody!.collisionBitMask = 0
		physicsBody!.contactTestBitMask = 1
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func paint(_ color: UIColor) {
		nodeColor = color
		fillColor = color
		strokeColor = color
	}
	
	func paint() {
		(children.first! as! Heart).paint()
		paint(nodeColor)
	}
	
	func score(_ color: UIColor) {
		scored = true
		paint(color)
	}
	
	func reset() {
		scored = false
		paint(.systemGray)
	}
}
