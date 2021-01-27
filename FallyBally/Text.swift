//
//  Text.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/18/21.
//

import SpriteKit

class Text: SKLabelNode {
	var textColor: UIColor = .label
	override init() {
		super.init()
		fontColor = textColor
		fontName = "ArialRoundedMTBold"
		fontSize = 20
	}
	
	convenience init(_ text: String) {
		self.init()
		self.text = text
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func paint(_ color: UIColor) {
		textColor = color
		fontColor = color
	}
	
	func paint() {
		paint(textColor)
	}
}
