//
//  Button.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/18/21.
//

import SpriteKit

class Button: ScaleableNode {
	func flash() {
		run(SKAction.fadeAlpha(to: 0.5, duration: 0.1)) {
			self.run(SKAction.fadeIn(withDuration: 0.1))
		}
	}
	
	func hide() {
		self.alpha = 1
		self.isHidden = false
		run(SKAction.fadeOut(withDuration: 0.5)) {
			self.isHidden = true
			self.alpha = 1
		}
	}
	
	func show() {
		self.alpha = 0
		self.isHidden = false
		run(SKAction.fadeIn(withDuration: 0.5)) {
			self.isHidden = false
		}
	}
}
