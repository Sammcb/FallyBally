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
	var bounds: CGRect = CGRect.zero
	var shouldSpawnHeart: Double = 10
	var camSpeed: Double = 0
	
	override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private func move(_ line: SKNode) {
		line.position = CGPoint(x: CGFloat.random(in: 0...bounds.maxX - 60), y: nextY)
		nextY -= distance
		(line as! Line).reset()
		shouldSpawnHeart -= 1 / camSpeed
		if shouldSpawnHeart < 0 && Bool.random() {
			shouldSpawnHeart = 25
			(line.children.first! as! Heart).spawn()
		} else {
			(line.children.first! as! Heart).collect()
		}
	}
	
	func place() {
		for line in children {
			move(line)
		}
	}
	
	func wrap(center: CGFloat) {
		for line in children {
			if (line.position.y > center + bounds.midY + 10) {
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
