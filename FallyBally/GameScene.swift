//
//  GameScene.swift
//  FallyBally
//
//  Created by Samuel McBroom on 1/15/21.
//

import SpriteKit
import GameKit

class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
	// MARK: - Game objects
	let ballOffset: CGFloat = 100
	let ball = Ball(radius: 10)
	let cam = SKCameraNode()
	let lines = Lines()
	let ui = UI()
	
	// MARK: - Score tracking
	var score = 0 {
		didSet {
			guard oldValue != score else {
				return
			}
			ui.scoreLabel.text = "\(score)"
		}
	}
	var highscore = 0 {
		didSet {
			guard oldValue != highscore else {
				return
			}
			ui.highscoreLabel.text = "\(highscore)"
		}
	}
	
	// MARK: - Pausing
	var playing = false
	override var isPaused: Bool {
		didSet {
			guard playing else {
				return
			}

			if isPaused {
				ui.showPause()
				pause()
			}
		}
	}
	
	// MARK: - Camera speed
	var camSpeedDelta: CGFloat = 0
	let minCamSpeed: CGFloat = 1.5
	let maxCamSpeed: CGFloat = 3
	var camSpeed: CGFloat = 0
	
	// MARK: - Achievements
	var didUpgrade = false
	var startTime = Date()
	
	// MARK: - Game Center
	let localPlayer = GKLocalPlayer.local
	let idPrefix = "com.sammcb.FallyBally"
	var achievements: [String: GKAchievement] = [:]
	var loginSuccess = false
	
	// MARK: - Local save data
	let localStorage = UserDefaults.standard
	
	func setupGKAccessPoint() {
		GKAccessPoint.shared.location = .topLeading
		GKAccessPoint.shared.showHighlights = false
		GKAccessPoint.shared.isActive = !ui.playButton.isHidden
	}
	
	func loadHighscore() async {
		let leaderboards = try? await GKLeaderboard.loadLeaderboards(IDs: ["\(idPrefix).scores"])
		
		guard let mainLeaderboard = leaderboards?.first else {
			return
		}
		
		let leaderboardEntries = try? await mainLeaderboard.loadEntries(for: [localPlayer], timeScope: .allTime)
		
		guard let entries = leaderboardEntries?.1 else {
			return
		}
		
		guard let leaderboardHighScore = entries.first?.score, leaderboardHighScore > highscore else {
			return
		}
		
		highscore = leaderboardHighScore
		localStorage.set(highscore, forKey: "highscore")
	}
	
	func loadAchievements() async {
		let loadedAchievements = try? await GKAchievement.loadAchievements()
		
		for achievement in loadedAchievements ?? [] {
			achievement.showsCompletionBanner = true
			achievements[achievement.identifier] = achievement
		}
		
		let descriptions = try? await GKAchievementDescription.loadAchievementDescriptions()
		
		for achievementDescription in descriptions ?? [] {
			if achievements[achievementDescription.identifier] == nil {
				let achievement = GKAchievement(identifier: achievementDescription.identifier)
				achievement.showsCompletionBanner = true
				achievements[achievementDescription.identifier] = achievement
			}
		}
	}
	
	func authenticateHandler(viewController: UIViewController?, error: Error?) {
		guard viewController == nil else {
			return
		}
		
		guard error == nil else {
			return
		}
		
		setupGKAccessPoint()
		loginSuccess = true
		Task {
			await loadHighscore()
			await loadAchievements()
		}
	}
	
	override func didMove(to view: SKView) {
		view.ignoresSiblingOrder = true
		
		physicsWorld.contactDelegate = self
		
		camSpeedDelta = 1.5 / CGFloat(6 * 60 * view.preferredFramesPerSecond)
		camera = cam
		addChild(cam)
		
		localPlayer.authenticateHandler = authenticateHandler
		
		ball.zPosition = 1
		ball.ui = ui
		addChild(ball)
		
		lines.bounds = frame
		for _ in stride(from: size.height, to: -ballOffset, by: -lines.distance) {
			let line = Line(width: 60, height: 4)
			let heart = Heart()
			line.addChild(heart)
			heart.position = CGPoint(x: line.frame.midX, y: line.frame.maxY + 15)
			lines.addChild(line)
		}
		addChild(lines)
		
		form()
		
		cam.addChild(ui)
		ui.world = self
		ui.bounds = frame
		ui.paint()
		ui.form()
		NotificationCenter.default.addObserver(ui, selector: #selector(ui.paint), name: NSNotification.Name(rawValue: colorModeKey), object: nil)
		
		pause()
	}
	
	// Detect if a node was tapped
	func pressed(button: ScaleableNode, at touch: UITouch) -> Bool {
		nodes(at: touch.location(in: self)).contains(button)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if isPaused {
			return
		}
		
		if pressed(button: ui.playButton, at: touches.first!) {
			startTime = Date()
			ui.showPlay()
			resume()
			return
		}
		
		if pressed(button: ui.pauseButton, at: touches.first!) {
			ui.showPause()
			pause()
			return
		}
		
		if pressed(button: ui.resumeButton, at: touches.first!) {
			ui.showPlay()
			resume()
			return
		}

		if pressed(button: ui.restartButton, at: touches.first!) {
			form()
			ui.form()
			return
		}
		
		// Absorbe taps when paused
		guard playing else {
			return
		}
		
		// Move the ball left or right
		ball.physicsBody!.applyImpulse(CGVector(dx: touches.first!.location(in: self).x < frame.midX ? -2 : 2, dy: 0))
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		let otherNode = contact.bodyA.node!.name != "ball" ? contact.bodyA.node! : contact.bodyB.node!
		if let heartNode = otherNode as? Heart {
			if ball.color == .purple {
				let bonus = 100
				score += bonus
				heartNode.score(bonus)
				if achievementLocked(with: "upgradeOverflow") {
					achieve(identifier: "upgradeOverflow")
				}
			} else {
				didUpgrade = true
				ball.oneUp()
				heartNode.collect()
				switch ball.color {
					case .orange:
						if achievementLocked(with: "orangeUpgrade") {
							achieve(identifier: "orangeUpgrade")
						}
						break
					case .yellow:
						if achievementLocked(with: "yellowUpgrade") {
							achieve(identifier: "yellowUpgrade")
						}
						break
					case .green:
						if achievementLocked(with: "greenUpgrade") {
							achieve(identifier: "greenUpgrade")
						}
						break
					case .blue:
						if achievementLocked(with: "blueUpgrade") {
							achieve(identifier: "blueUpgrade")
						}
						break
					case .purple:
						if achievementLocked(with: "purpleUpgrade") {
							achieve(identifier: "purpleUpgrade")
						}
						break
					default:
						break
				}
			}
		} else if let lineNode = otherNode as? Line {
			if lineNode.scored {
				if ball.fillColor != lineNode.fillColor && achievementLocked(with: "scoreAgain") {
					achieve(identifier: "scoreAgain")
				}
				return
			}
			lineNode.score(ball.fillColor)
			score += ball.color.rawValue
			if !didUpgrade && score >= 100 && achievementLocked(with: "oneHundRed") {
				achieve(identifier: "oneHundRed")
			}
		}
	}
	
	func form() {
		score = 0
		
		didUpgrade = false

		cam.position = CGPoint(x: frame.midX, y: frame.midY)
		camSpeed = minCamSpeed
		lines.camSpeed = Double(camSpeed)
		
		ball.position = CGPoint(x: cam.position.x, y: cam.position.y + ballOffset)
		ball.physicsBody!.velocity = CGVector.zero
		
		lines.nextY = cam.position.y
		lines.shouldSpawnHeart = 10
		lines.place()
		
		if !loginSuccess {
			highscore = localStorage.integer(forKey: "highscore")
		}
	}
	
	func achievementLocked(with identifier: String) -> Bool {
		guard loginSuccess else {
			return false
		}
		
		return !achievements["\(idPrefix).\(identifier)"]!.isCompleted
	}
	
	func achieve(identifier: String, progress: Double = 100) {
		let achievement = achievements["\(idPrefix).\(identifier)"]!
		achievement.percentComplete = progress
		GKAchievement.report([achievement]) { error in
			guard error == nil else {
				return
			}
		}
	}
	
	func updateLeaderboard() {
		guard loginSuccess else {
			return
		}
		
		GKLeaderboard.submitScore(score, context: 0, player: localPlayer, leaderboardIDs: ["\(idPrefix).scores"]) { error in
			guard error == nil else {
				return
			}
		}
	}
	
	func updateAchievements() {
		guard loginSuccess else {
			return
		}
		
		if achievementLocked(with: "firstGame") {
			achieve(identifier: "firstGame")
		}
		
		if achievementLocked(with: "score1000") {
			let scorePercent = trunc(Double(score) / 1000 * 100)
			if scorePercent > achievements["\(idPrefix).score1000"]!.percentComplete {
				achieve(identifier: "score1000", progress: scorePercent)
			}
		}
		
		if achievementLocked(with: "score5000") {
			let scorePercent = trunc(Double(score) / 5000 * 100)
			if scorePercent > achievements["\(idPrefix).score5000"]!.percentComplete {
				achieve(identifier: "score5000", progress: scorePercent)
			}
		}
		
		if Date() < Calendar.current.date(byAdding: .second, value: 10, to: startTime)! && achievementLocked(with: "quickGame") {
			achieve(identifier: "quickGame")
		}
	}
	
	func pause() {
		playing = false
		physicsWorld.speed = 0
		for child in children {
			child.isPaused = true
		}
	}
	
	func resume() {
		playing = true
		physicsWorld.speed = 1
		for child in children {
			child.isPaused = false
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		guard playing else {
			return
		}
		
		cam.position.y -= camSpeed
		if camSpeed < maxCamSpeed {
			camSpeed += camSpeedDelta
			lines.camSpeed = Double(camSpeed)
		}
		
		lines.wrap(center: cam.position.y)
		
		if cam.contains(ball) {
			return
		}
		
		if ball.color == .red {
			if score > highscore {
				highscore = score
				localStorage.set(highscore, forKey: "highscore")
			}
			updateLeaderboard()
			updateAchievements()
			ui.showOver()
			pause()
			return
		}
		
		ball.die()
		ball.physicsBody!.velocity = CGVector.zero
		ball.position = CGPoint(x: cam.position.x, y: cam.position.y + ballOffset)
		
		if !ball.physicsBody!.allContactedBodies().isEmpty {
			ball.position.y += 10
		}
	}
}
