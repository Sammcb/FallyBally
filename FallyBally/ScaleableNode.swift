//
//  ScaleableNode.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/18/21.
//

import SpriteKit

class ScaleableNode: SKSpriteNode {
	var image: UIImage?
	var symbolColor: UIColor = .label
	
	override init(texture: SKTexture?, color: UIColor, size: CGSize) {
		super.init(texture: texture, color: color, size: size)
	}

	convenience init(imageNamed name: String) {
		let image = UIImage(named: name)!
		self.init(texture: SKTexture(image: image), color: .white, size: image.size)
		self.image = image
	}
	
	convenience init(imageNamed name: String, width: CGFloat, height: CGFloat?) {
		let image = UIImage(named: name)!
		self.init(texture: SKTexture(image: image), color: .white, size: image.size)
		let aspectRatio = image.size.width / image.size.height
		scale(to: CGSize(width: width, height: height ?? width / aspectRatio))
		self.image = image
	}
	
	convenience init(symbolName name: String) {
		let image = UIImage(systemName: name)!
		self.init(texture: SKTexture(image: image), color: .label, size: image.size)
		self.image = image
	}
	
	convenience init(symbolName name: String, width: CGFloat) {
		let image = UIImage(systemName: name)!.applyingSymbolConfiguration(.init(pointSize: width))!.withTintColor(.label)
		self.init(texture: SKTexture(image: UIImage(data: image.pngData()!)!), color: .label, size: image.size)
		self.image = image
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func paint(_ color: UIColor) {
		symbolColor = color
		texture = SKTexture(image: UIImage(data: image!.withTintColor(color).pngData()!)!)
	}
	
	func paint() {
		paint(symbolColor)
	}
}
