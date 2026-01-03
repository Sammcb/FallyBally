//
//  GameUIView.swift
//  FallyBally
//
//  Created by Sam McBroom on 8/7/25.
//

import SwiftUI

struct GameUIView: View {
	var gameData: GameData

	private func startGame() {
		gameData.state = .playing
		gameData.startTime = Date()
	}

	private func pauseGame() {
		gameData.state = .paused
	}

	var body: some View {
		HStack {
			Button(action: startGame) {
				Label("Play", systemImage: "play")
					.symbolVariant(.fill)
					.labelStyle(.iconOnly)
					.font(.title)
					.disabled(gameData.state != .menu && gameData.state != .paused)
					.opacity(gameData.state != .menu && gameData.state != .paused ? 0 : 1)
			}

			Button(action: pauseGame) {
				Label("Pause", systemImage: "pause")
					.symbolVariant(.fill)
					.labelStyle(.iconOnly)
					.font(.title)
					.disabled(gameData.state != .playing)
					.opacity(gameData.state != .playing ? 0 : 1)
			}
		}
		.edgesIgnoringSafeArea(.all)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
