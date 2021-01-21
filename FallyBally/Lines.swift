//
//  Lines.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/17/21.
//

import SpriteKit

class Lines: SKNode {
	let distance: CGFloat = 60
	var nextY: CGFloat = 0
	var maxX: CGFloat = 0
	var midY: CGFloat = 0
	
	override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func set(frame: CGRect) {
		maxX = frame.maxX
		midY = frame.midY
	}
	
	// Place a new line below the screen
	private func move(_ line: SKNode) {
		line.position = CGPoint(x: CGFloat.random(in: 0...maxX - 60), y: nextY)
		nextY -= distance
		(line as! Line).reset()
		guard Int.random(in: 0...100) > 95 else {
			(line.children.first! as! Heart).collect()
			return
		}
		(line.children.first! as! Heart).spawn()
	}
	
	func place() {
		for line in children {
			move(line)
		}
	}
	
	func wrap(center: CGFloat) {
		for line in children {
			if (line.position.y > center + midY + 10) {
				move(line)
				break
			}
		}
	}
	
	func paint() {
		for line in children {
			(line as! Line).paint()
		}
	}
}
