//
//  GameView.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SwiftUI
import SwiftData
import SpriteKit
import GameKit

struct GameView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.modelContext) private var context
	@Query private var gameDatas: [GameData]

	private var gameData: GameData {
		// Skip if there is already a game data
		guard let gameData = gameDatas.first else {
			let newGameData = GameData()
			context.insert(newGameData)
			try? context.save()
			return newGameData
		}

		// Remove extra game datas
		let expectedGameDatas = 1
		if gameDatas.count > expectedGameDatas {
			gameDatas[expectedGameDatas...].forEach({ extraData in context.delete(extraData) })
		}
		
		return gameData
	}

	private let gameScene = GameScene()
	private var scene: GameScene {
		let scene = gameScene
		scene.gameData = gameData
		scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
		scene.scaleMode = .fill
		return scene
	}
	
	var body: some View {
		ZStack {
			SpriteView(scene: scene)
				.onChange(of: colorScheme) {
					scene.ui.paint()
				}
				.onChange(of: gameData.state) {
					scene.setState(gameData.state)
				}
				.onAppear {
					GameCenter.setup(gameData: gameData)
				}

			GameUIView(gameData: gameData)
		}
		.edgesIgnoringSafeArea(.all)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.statusBar(hidden: true)
	}
}
