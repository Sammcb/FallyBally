//
//  GameView.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
	private let gameWidth = UIScreen.main.bounds.width
	private let gameHeight = UIScreen.main.bounds.height
	private var scene: SKScene {
		let scene = GameScene()
		scene.size = CGSize(width: gameWidth, height: gameHeight)
		scene.scaleMode = .fill
		return scene
	}
	
	var body: some View {
		SpriteView(scene: scene)
			.edgesIgnoringSafeArea(.all)
			.frame(width: gameWidth, height: gameHeight)
	}
}
