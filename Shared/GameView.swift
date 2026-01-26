//
//  GameView.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SwiftUI
import SwiftData
import SpriteKit

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
		scene.scaleMode = .fill
		return scene
	}
	
	var body: some View {
		ZStack {
			Color(.systemBackground)

			GeometryReader { geometry in
				SpriteView(scene: scene, options: [.allowsTransparency])
					.onAppear {
						scene.size = geometry.size
					}
					.onChange(of: colorScheme) {
						scene.paint()
					}
					.onChange(of: gameData.state) {
						scene.setState(gameData.state)
					}
					.onChange(of: gameData.currentGame.score) {
						guard gameData.currentGame.score > gameData.highScore else {
							return
						}
						gameData.highScore = gameData.currentGame.score
					}
			}
			.edgesIgnoringSafeArea(.all)

			GameUIView(gameData: gameData, gameScene: gameScene)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.statusBar(hidden: true)
		.animation(.easeIn(duration: 0.1), value: gameData.state)
	}
}
