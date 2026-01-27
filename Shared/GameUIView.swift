//
//  GameUIView.swift
//  FallyBally
//
//  Created by Sam McBroom on 8/7/25.
//

import SwiftUI

struct GameUIView: View {
	let gameData: GameData
	let gameScene: GameScene

	private func playGame() {
		gameData.state = .playing
	}

	private func pauseGame() {
		gameData.state = .paused
	}

	private func restartGame() {
		gameData.state = .menu
	}

	var body: some View {
		ZStack {
			HStack(spacing: 0) {
				Button {
					gameScene.moveBall(left: true)
				} label: {
					Color(.clear)
				}
				.disabled(gameData.state != .playing)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

				Button {
					gameScene.moveBall(left: false)
				} label: {
					Color(.clear)
				}
				.disabled(gameData.state != .playing)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			}

			VStack {
				HStack {
					Label("\(gameData.highScore)", systemImage: "crown")
						.symbolVariant(.fill)
						.fontWeight(.bold)
						.padding()
						.glassEffect()

					Spacer()
						.frame(maxWidth: .infinity)

					VStack {
						Text("\(gameData.currentGame.score)")
							.fontWeight(.bold)
						Text("x\(gameData.ballColor.rawValue)")
							.foregroundStyle(gameData.ballColor.ui)
					}
					.padding()
					.glassEffect()
					.opacity(gameData.state == .menu ? 0 : 1)
				}
				.padding()

				Spacer()
					.frame(maxHeight: .infinity)

				ZStack {
					Button(action: playGame) {
						Label("Play", systemImage: "play")
							.symbolVariant(.circle.fill)
							.labelStyle(.iconOnly)
							.font(.title)
					}
					.foregroundStyle(.primary)
					.disabled(gameData.state != .menu && gameData.state != .paused)
					.padding()
					.glassEffect()
					.opacity(gameData.state != .menu && gameData.state != .paused ? 0 : 1)

					Button(action: restartGame) {
						Label("Restart", systemImage: "arrow.clockwise.circle.fill")
							.symbolVariant(.circle.fill)
							.labelStyle(.iconOnly)
							.font(.title)
					}
					.foregroundStyle(.primary)
					.disabled(gameData.state != .over)
					.padding()
					.glassEffect()
					.opacity(gameData.state != .over ? 0 : 1)
				}

				Spacer()
					.frame(maxHeight: .infinity)

				HStack {
					Spacer()
						.frame(maxWidth: .infinity)

					Button(action: pauseGame) {
						Label("Pause", systemImage: "pause")
							.symbolVariant(.circle.fill)
							.labelStyle(.iconOnly)
							.font(.title)
					}
					.foregroundStyle(.primary)
					.disabled(gameData.state != .playing)
					.padding()
					.glassEffect()
					.opacity(gameData.state != .playing ? 0 : 1)
				}
				.padding()
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}
