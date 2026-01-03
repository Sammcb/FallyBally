//
//  GameStateV1_0_0.swift
//  FallyBally
//
//  Created by Sam McBroom on 8/7/25.
//

import SwiftData
import GameKit

extension SchemaV1_0_0 {
	@Model
	final class GameData {
		enum State: String, Codable {
			case menu, playing, paused, over
		}

		private static let minScore = 0
		private static let minProgress: Double = 0
		private static let maxProgress: Double = 100

		var highScore = minScore
		var achievements = [
			GameCenter.AchievementId.firstGame: minProgress
		]
		
		// Can these be @Transient? Currently that makes them unobservable
		@Attribute(.ephemeral) var score = minScore
		@Attribute(.ephemeral) var state = State.menu
		@Transient var startTime = Date()
		@Transient var didUpgrade = false

		init() {}

		func achieve(achievementId: GameCenter.AchievementId, progress: Double = maxProgress) {
			guard let achievementProgress = achievements[achievementId], achievementProgress < Self.maxProgress else {
				return
			}

			achievements[achievementId] = progress

			Task {
				await GameCenter.achieve(achievementId: achievementId, progress: progress, gameData: self)
			}
		}
	}
}

struct GameCenter {
	private static let idPrefix = "com.sammcb.FallyBally"
	private static let idSeparator = "."

	enum AchievementId: String, Codable {
		case firstGame
		
		var fullId: String {
			"\(idPrefix)\(idSeparator)\(rawValue)"
		}
		
		init?(fullId: String) {
			let trimmedId = String(fullId.dropFirst(idPrefix.count + idSeparator.count))
			self.init(rawValue: trimmedId)
		}
	}
	
	enum LeaderboardId: String, Codable {
		case score
		
		var fullId: String {
			"\(idPrefix)\(idSeparator)\(rawValue)"
		}
	}

	private static func syncGameCenterHighScore(for gameData: GameData) async {
		guard let highScoreLeaderboard = try? await GKLeaderboard.loadLeaderboards(IDs: [LeaderboardId.score.fullId]).first else {
			return
		}

		guard let (leaderboardHighScoreEntry, _) = try? await highScoreLeaderboard.loadEntries(for: [GKLocalPlayer.local], timeScope: .allTime) else {
			return
		}

		let initialHighScore = 0
		let leaderboardHighScore = leaderboardHighScoreEntry?.score ?? initialHighScore

		// High score is already synced
		guard gameData.highScore != leaderboardHighScore else {
			return
		}

		// GameCenter high score should be set to better local high score
		guard gameData.highScore < leaderboardHighScore else {
			// update gamecenter high score
			return
		}

		// Local high score should be set to better GameCenter high score
		gameData.highScore = leaderboardHighScore
	}

	private static func syncGameCenterAchievements(for gameData: GameData) async {
		guard let gameCenterAchievements = try? await GKAchievement.loadAchievements() else {
			return
		}

		let initialAchievementProgress = 0.0

		// Ensure reported achievements are synced
		for gameCenterAchievement in gameCenterAchievements {
			guard let achievementId = AchievementId(fullId: gameCenterAchievement.identifier) else {
				continue
			}

			let achievementProgress = gameData.achievements[achievementId] ?? initialAchievementProgress

			// Achievement progress is already synced
			guard achievementProgress != gameCenterAchievement.percentComplete else {
				continue
			}

			// GameCenter achievement progress should be set to better local achievement progress
			guard achievementProgress < gameCenterAchievement.percentComplete else {
				// update gamecenter high score
				continue
			}

			// Local achievement progress should be set to better GameCenter achievement progress
			gameData.achievements[achievementId] = gameCenterAchievement.percentComplete
		}

		let reportedAchievementIds = gameCenterAchievements.map({ gameCenterAchievement in AchievementId(fullId: gameCenterAchievement.identifier) })
		let unsyncedAchievements = gameData.achievements.filter({ achievementId, achievementProgress in achievementProgress > 0 && !reportedAchievementIds.contains(achievementId) })

		for (achievementId, achievementProgress) in unsyncedAchievements {
			// report achievement progress
			print(achievementId, achievementProgress)
		}
	}

	@MainActor
	static func setup(gameData: GameData) {
		GKAccessPoint.shared.location = .topLeading
		GKAccessPoint.shared.showHighlights = false
		GKAccessPoint.shared.isActive = true
		GKLocalPlayer.local.authenticateHandler = { _, error in
			// Always enable the access point so users can log in
			GKAccessPoint.shared.location = .topLeading
			GKAccessPoint.shared.showHighlights = false
			GKAccessPoint.shared.isActive = true

			guard error == nil else {
				return
			}

			Task {
				await syncGameCenterHighScore(for: gameData)
				await syncGameCenterAchievements(for: gameData)
			}
		}
	}

//	func achievementLocked(_ achievementId: AchievementId) -> Bool {
//		guard GKLocalPlayer.local.isAuthenticated else {
//			return false
//		}
//
//		return !GKAchievement
//
//		return !GameData.achievements[identifier]!.isCompleted
//	}

	static func achieve(achievementId: AchievementId, progress: Double = 100, gameData: GameData) async {
		guard GKLocalPlayer.local.isAuthenticated else {
			return
		}

		guard let gameCenterAchievements = try? await GKAchievement.loadAchievements() else {
			return
		}

		let achievement = achievements["\(idPrefix).\(identifier)"]!
		achievement.percentComplete = progress
		GKAchievement.report([achievement]) { error in
			guard error == nil else {
				return
			}
		}
	}
}
