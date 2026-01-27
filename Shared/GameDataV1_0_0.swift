//
//  GameDataV1_0_0.swift
//  FallyBally
//
//  Created by Sam McBroom on 8/7/25.
//

import SwiftData
import SwiftUI

extension SchemaV1_0_0 {
	@Model
	final class GameData {
		enum State: String, Codable {
			case menu, playing, paused, over
		}

		struct CurrentGame: Codable {
			var score = 0
		}

		@Attribute(.ephemeral) var state = State.menu
		@Attribute(.ephemeral) var ballColor = Ball.Color.red
		// Wrapper struct required because when using a regular Int value is randomly reset to 0 when ephemeral
		@Attribute(.ephemeral) var currentGame = CurrentGame()
		var highScore = 0

		init() {}
	}
}
